#define _GNU_SOURCE

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/inotify.h>

#include "handler.h"
#include "pipe.h"
#include "server.h"

// Data value used for inotify in epoll. PipeSet FDs use their pointers, so set
// this to a value that would never be a valid pointer. NULL is used for other
// things, 0x1 is low and probably won't be used by a PipeSet pointer.
#define INOTIFY_DATA 0x1

void free_pipe_list(struct PipeSet *head) {
    struct PipeSet *set;
    while (head) {
        set = head->next;
        free(head);
        head = set;
    }
}

void prepend_pipe_list(struct PipeSet **head, struct PipeSet *set) {
    set->next = *head;
    *head = set;
}

/// Safely free a HopperData structure
void free_hopper_data(struct HopperData *data) {
    if (!data)
        return;

    free_pipe_list(data->pipes);

    if (data->outputs)
        free(data->outputs);
}

void close_hopper_fds(struct HopperData *data) {
    if (!data)
        return;

    close(data->epoll_fd);
    close(data->inotify_fd);
    close(data->devnull);

    struct PipeSet *set = data->pipes;

    do {
        close(set->fd);
        close(set->buf[0]);
        close(set->buf[1]);
        set = set->next;
    } while (set);
}

/// Allocate a new HopperData structure
struct HopperData *alloc_hopper_data() {
    struct HopperData *data =
        (struct HopperData *)malloc(sizeof(struct HopperData));
    if (!data)
        goto err_alloc;

    data->outputs =
        (struct PipeSet **)calloc(MAX_HANDLER_ID + 1, sizeof(struct PipeSet *));
    if (!data->outputs)
        goto err_alloc;

    return data;

err_alloc:
    perror("alloc");
    free_hopper_data(data);
    return NULL;
}

int epoll_add_src_pipe(struct HopperData *data, struct PipeSet *set) {
    struct epoll_event ev = {};
    ev.events = EPOLLIN | EPOLLET;
    ev.data.ptr = (void *)set;

    int res;
    if ((res = epoll_ctl(data->epoll_fd, EPOLL_CTL_ADD, set->fd, &ev)) != 0)
        perror("epoll_ctl ADD");

    return res;
}

int load_new_pipe(struct HopperData *data, const char *path) {
    struct PipeSet *set = open_pipe_set(path);
    if (!set)
        return 1;

    prepend_pipe_list(&data->pipes, set);

    if (set->info->type == PIPE_DST) {
        set->next_output = data->outputs[set->info->handler];
        data->outputs[set->info->handler] = set;
    }

    printf("added fifo '%s'\n", path);

    reopen_pipe_set(set, data);

    return 0;
}

void pipe_set_status_inactive(struct PipeSet *set, struct HopperData *data) {
    if (set->status == PIPE_INACTIVE)
        return;

    if (set->info->type == PIPE_SRC)
        if (epoll_ctl(data->epoll_fd, EPOLL_CTL_DEL, set->fd, NULL) != 0)
            perror("epoll_ctl DEL");

    close(set->fd);
    set->fd = -1;
    set->status = PIPE_INACTIVE;
    printf("%d/%s set to INACTIVE\n", set->info->handler, set->info->id);
}

void pipe_set_status_active(struct PipeSet *set, struct HopperData *data) {
    if (set->status == PIPE_ACTIVE)
        return;

    if (set->info->type == PIPE_SRC)
        epoll_add_src_pipe(data, set);

    if (set->info->type == PIPE_DST && set->fd != -1)
        flush_pipe_set_buffers(set);

    set->status = PIPE_ACTIVE;

    printf("%d/%s set to ACTIVE\n", set->info->handler, set->info->id);
}

int load_pipes_directory(struct HopperData *data) {
    struct dirent **entries;
    int n;

    if ((n = scandir(data->pipe_dir, &entries, NULL, alphasort)) < 0) {
        perror("scandir");
        return 1;
    }

    for (int i = 0; i < n; i++) {
        struct dirent *entry = entries[i];

        if (entry->d_type == DT_FIFO || entry->d_type == DT_UNKNOWN) {

            char path[PATH_MAX];
            snprintf(path, sizeof(path), "%s/%s", data->pipe_dir,
                     entry->d_name);

            load_new_pipe(data, path);
        }
        free(entry);
    }

    free(entries);

    return 0;
}

int handle_inotify_event(struct HopperData *data) {
    struct inotify_event *ev = (struct inotify_event *)malloc(
        sizeof(struct inotify_event) + NAME_MAX + 1);

    if (read(data->inotify_fd, ev,
             sizeof(struct inotify_event) + NAME_MAX + 1) < 0) {
        perror("read");
        return 1;
    }

    if (ev->mask & IN_DELETE_SELF) {
        // The pipes directory got deleted, hopper can't continue, exit
        // immediately.
        printf("pipes directory disappeared, exiting...\n");
        _exit(1);
    }

    if (ev->mask & IN_CREATE) {
        char path[PATH_MAX];
        snprintf(path, sizeof(path), "%s/%s", data->pipe_dir, ev->name);

        if (load_new_pipe(data, path) < 0) {
            free(ev);
            return 1;
        }
    }

    if (ev->mask & IN_DELETE) {
        char path[PATH_MAX];
        snprintf(path, sizeof(path), "%s/%s", data->pipe_dir, ev->name);

        struct PipeInfo *info = get_pipe_info(path);

        if (!info)
            return 1;

        struct PipeSet **tgt = &data->pipes;

        while (*tgt) {
            if (!strcmp((*tgt)->info->name, info->name)) {
                struct PipeSet *to_free = *tgt;
                *tgt = (*tgt)->next;
                free(to_free);
                break;
            }

            tgt = &(*tgt)->next;
        }

        if (tgt)
            printf("removed %d/%s\n", info->handler, info->name);
        else
            printf("pipe %d/%s not found\n", info->handler, info->name);
    }

    free(ev);
    return 0;
}

int rescan_pipes(struct HopperData *data) {
    struct PipeSet *set = data->pipes;

    while (set) {
        if (set->status == PIPE_INACTIVE && set->info->type == PIPE_DST)
            reopen_pipe_set(set, data);

        set = set->next;
    }

    return 0;
}

int run_epoll_cycle(struct HopperData *data) {
    struct epoll_event events[MAX_EVENTS];
    int res;

    int n = epoll_wait(data->epoll_fd, events, MAX_EVENTS, 250);
    if (n < 0) {
        perror("epoll_wait");
        return n;
    }

    for (int i = 0; i < n; i++) {
        if (events[i].data.u64 == INOTIFY_DATA) {
            handle_inotify_event(data);
            continue;
        }

        struct PipeSet *set = (struct PipeSet *)events[i].data.ptr;

        if (events[i].events & EPOLLIN)
            if ((res = transfer_buffers(data, set, MAX_COPY_SIZE)) < 0)
                return res;
    }

    rescan_pipes(data);

    return n;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <pipes directory>\n", argv[0]);
        return 1;
    }

    int ret = 0;

    // Writing to a closed FIFO gives us a SIGPIPE, this is internally handled
    // so ignore it.
    signal(SIGPIPE, SIG_IGN);

    struct HopperData *data = alloc_hopper_data();
    if (!data) {
        ret = 1;
        goto cleanup;
    }

    data->pipe_dir = argv[1];

    if ((data->devnull = open("/dev/null", O_WRONLY)) < 0) {
        perror("open");
        ret = 1;
        goto cleanup;
    }

    if ((data->epoll_fd = epoll_create1(0)) < 0) {
        perror("epoll_create");
        ret = 1;
        goto cleanup;
    }

    if ((data->inotify_fd = inotify_init()) < 0) {
        perror("inotify_init");
        ret = 1;
        goto cleanup;
    }

    struct epoll_event ev = {};
    ev.events = EPOLLIN;
    ev.data.u64 =
        INOTIFY_DATA; // Ensure u64 is used here, not u32, which could be shared
                      // with a pointer due to size differences. e.g. ptr could
                      // be 0x7fffffff{INOTIFY_DATA}, using u64 prevents this!!

    if (epoll_ctl(data->epoll_fd, EPOLL_CTL_ADD, data->inotify_fd, &ev) != 0) {
        perror("epoll_ctl ADD");
        ret = 1;
        goto cleanup;
    }

    if ((data->inotify_root_watch_fd =
             inotify_add_watch(data->inotify_fd, data->pipe_dir,
                               IN_CREATE | IN_DELETE | IN_DELETE_SELF)) < 0) {
        perror("inotify_add_watch");
        ret = 1;
        goto cleanup;
    }

    if (load_pipes_directory(data) != 0) {
        ret = 1;
        goto cleanup;
    }

    int res = 0;
    while (res >= 0) {
        res = run_epoll_cycle(data);
        if (res < 0 && errno == EINTR)
            res = 0;
    }

cleanup:
    close_hopper_fds(data);
    free_hopper_data(data);
    return ret;
}
