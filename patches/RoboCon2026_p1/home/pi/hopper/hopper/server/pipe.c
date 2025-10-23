#define _GNU_SOURCE

#include <errno.h>
#include <fcntl.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "handler.h"
#include "pipe.h"

/// Close all file descriptors in a PipeSet object
/// Threads should be joined first
void close_pipe_set(struct PipeSet *set) {
    close(set->buf[0]);
    close(set->buf[1]);
    close(set->fd);

    set->buf[0] = -1;
    set->buf[1] = -1;
    set->fd = -1;
}

/// Free a PipeSet, file descriptors should be closed first
void free_pipe_set(struct PipeSet **set) {
    if (!set)
        return;

    struct PipeSet *_set = *set;
    free(_set->info->id);
    free(_set->info);
    free(_set);

    // Set the pointer to NULL so it isn't reused
    (*set) = NULL;
}

/// Generate a PipeInfo object from a file path
struct PipeInfo *get_pipe_info(const char *path) {
    struct PipeInfo *info = (struct PipeInfo *)malloc(sizeof(struct PipeInfo));
    if (!info) {
        perror("malloc");
        return NULL;
    }

    info->path = strdup(path);

    char *filename = basename((char *)path);

    info->name = strdup(filename);

    char *type = strtok(filename, "_");
    if (!type)
        goto err_bad_fname;

    switch (*type) {
        case 'I':
            info->type = PIPE_SRC;
            break;
        case 'O':
            info->type = PIPE_DST;
            break;
        default:
            goto err_bad_fname;
    }

    char *handler = strtok(NULL, "_");
    if (!handler)
        goto err_bad_fname;

    info->handler = map_handler_to_id(handler);

    char *id = strtok(NULL, "_");
    if (!id)
        goto err_bad_fname;

    int len = strlen(id) + 1;

    info->id = (char *)malloc(sizeof(char) * len);
    if (!info->id) {
        free(info);
        perror("malloc");
        return NULL;
    }

    strcpy(info->id, id);

    return info;

err_bad_fname:
    printf("Badly formatted filename: '%s'\n", filename);
    free(info);
    return NULL;
}

int flush_pipe_set_buffers(struct PipeSet *set) {
    return splice(set->buf[0], NULL, set->fd, NULL, MAX_COPY_SIZE, 0);
}

/// Try to reopen a previously closed pipe
int reopen_pipe_set(struct PipeSet *set, struct HopperData *data) {
    if (set->status == PIPE_ACTIVE)
        return 0;

    if ((set->fd = open(set->info->path,
                        (set->info->type == PIPE_SRC ? O_RDONLY : O_WRONLY) |
                            O_NONBLOCK)) < 0) {
        if (errno == ENXIO && set->info->type == PIPE_DST) {
            pipe_set_status_inactive(set, data);
            return 1;
        }

        pipe_set_status_inactive(set, data);
        perror("open");
        return 1;
    }

    pipe_set_status_active(set, data);

    return 0;
}

/// Open a PipeSet object from a file
struct PipeSet *open_pipe_set(const char *path) {
    char *path_copy = strdup(path);

    struct PipeSet *set = (struct PipeSet *)malloc(sizeof(struct PipeSet));
    if (!set) {
        perror("malloc");
        return NULL;
    }

    struct PipeInfo *info = get_pipe_info(path_copy);
    if (!info)
        return NULL;

    set->info = info;
    set->status = PIPE_INACTIVE;
    set->next = NULL;
    set->next_output = NULL;
    set->fd = -1;

    if (pipe(set->buf) < 0) {
        free_pipe_set(&set);
        perror("pipe");
        return NULL;
    }

    return set;
}

ssize_t nb_splice(int src, int dst, ssize_t max) {
    ssize_t bytes_copied = 0;

    while ((bytes_copied = splice(src, NULL, dst, NULL, max, 0)) < 0) {
        if (errno == EAGAIN)
            return 0;
        if (errno == EINTR)
            continue;
        if (errno == EPIPE)
            return -1;

        perror("splice");
        return -1;
    }

    return bytes_copied;
}

ssize_t nb_tee(int src, int dst, ssize_t max) {
    ssize_t bytes_copied = 0;

    while ((bytes_copied = tee(src, dst, max, 0)) < 0) {
        if (errno == EAGAIN)
            return 0;
        if (errno == EINTR)
            continue;

        perror("tee");
        return -1;
    }

    return bytes_copied;
}

ssize_t transfer_buffers(struct HopperData *data, struct PipeSet *src,
                         ssize_t max) {
    struct PipeSet *dst = NULL;
    ssize_t bytes_copied = 0;
    short handler_id = src->info->handler;

    if ((bytes_copied = nb_splice(src->fd, src->buf[1], max)) < 0) {
        pipe_set_status_inactive(src, data);
        return bytes_copied;
    }

    dst = data->outputs[handler_id];
    while (dst) {
        if (dst->status == PIPE_INACTIVE) {
            dst = dst->next_output;
            continue;
        }

        if (nb_tee(src->buf[0], dst->buf[1], max) < 0)
            break;

        dst = dst->next_output;
    }

    dst = data->outputs[handler_id];
    while (dst) {
        if (dst->status == PIPE_INACTIVE) {
            dst = dst->next_output;
            continue;
        }

        ssize_t remaining = bytes_copied, done;
        while (remaining > 0) {
            done = nb_splice(dst->buf[0], dst->fd, max);
            if (done <= 0) {
                if (errno == EPIPE)
                    pipe_set_status_inactive(dst, data);
                break;
            }

            remaining -= done;
        }
        dst = dst->next_output;
    }

    splice(src->buf[0], NULL, data->devnull, NULL, max, 0);

    printf("%d/%s copied %zd bytes\n", src->info->handler, src->info->id,
           bytes_copied);

    return bytes_copied;
}
