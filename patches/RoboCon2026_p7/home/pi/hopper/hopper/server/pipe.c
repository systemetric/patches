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
    close(set->fd);
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
    set->rd_ptr = NULL;

    return set;
}

ssize_t nb_read(int fd, void *buf, ssize_t max) {
    if (max == 0)
        return 0;

    ssize_t bytes_copied = 0;

    while (bytes_copied < max) {
        ssize_t res = read(fd, buf + bytes_copied, max - bytes_copied);
        if (res == -1 && (errno == EAGAIN || errno == EINTR))
            return bytes_copied;
        else if (res == -1) {
            perror("read");
            return -1;
        }
        else if (res == 0)
            break;

        bytes_copied += res;
    }
    
    return bytes_copied;
}

ssize_t nb_write(int fd, void *buf, ssize_t max) {
    if (max == 0)
        return 0;
    
    ssize_t bytes_copied = 0;

    while (bytes_copied < max) {
        ssize_t res = write(fd, buf + bytes_copied, max - bytes_copied);
        if (res == -1 && (errno == EAGAIN || errno == EINTR))
            return bytes_copied;
        else if (res == -1) {
            perror("write");
            return -1;
        }

        bytes_copied += res;
    }

    return bytes_copied;
}

ssize_t read_fifo(struct HopperData *data, struct PipeSet *src) {
    void *high_read_ptr = get_high_read_ptr(data, src->info->handler);
    void *low_read_ptr = get_low_read_ptr(data, src->info->handler);
    void *wr_ptr = data->buffers[src->info->handler]->wr_ptr;
    ssize_t max_read = 0;

    if (!low_read_ptr || !high_read_ptr || wr_ptr >= high_read_ptr)
        max_read = data->buffers[src->info->handler]->buf_end - wr_ptr;
    else if (wr_ptr < low_read_ptr)
        max_read = low_read_ptr - wr_ptr;    

    if (max_read == 0)
        return 0;

    ssize_t res = nb_read(src->fd, wr_ptr, max_read);
    if (res == -1)
        return -1;

    wr_ptr += res;

    if (wr_ptr >= data->buffers[src->info->handler]->buf_end)
        wr_ptr = data->buffers[src->info->handler]->buf;

    data->buffers[src->info->handler]->last_wr_ptr = data->buffers[src->info->handler]->wr_ptr;
    data->buffers[src->info->handler]->wr_ptr = wr_ptr;

    if (res > 0)
        printf("%d/%s -> %zd bytes\n", src->info->handler, src->info->id, res);

    return res;
}

ssize_t write_fifo(struct HopperData *data, struct PipeSet *dst) {
    ssize_t max_write = 0;

    if (dst->rd_ptr > data->buffers[dst->info->handler]->wr_ptr)
        max_write = data->buffers[dst->info->handler]->buf_end - dst->rd_ptr;
    else if (dst->rd_ptr < data->buffers[dst->info->handler]->wr_ptr)
        max_write = data->buffers[dst->info->handler]->wr_ptr - dst->rd_ptr;

    if (max_write == 0)
        return 0;

    ssize_t res = nb_write(dst->fd, dst->rd_ptr, max_write);
    if (res == -1 && errno == EPIPE)
        pipe_set_status_inactive(dst, data);
    if (res == -1)
        return -1;

    dst->rd_ptr += res;

    if (dst->rd_ptr >= data->buffers[dst->info->handler]->buf_end)
        dst->rd_ptr = data->buffers[dst->info->handler]->buf;

    if (res > 0)
        printf("%d/%s <- %zd bytes\n", dst->info->handler, dst->info->id, res);

    return res;
}
