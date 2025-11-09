#ifndef pipe_h_INCLUDED
#define pipe_h_INCLUDED

#include <unistd.h>

#include "server.h"

#define PIPE_SRC 1
#define PIPE_DST 2

#define PIPE_INACTIVE 0
#define PIPE_ACTIVE 1

/// A structure containing file information about a I/O pipe
struct PipeInfo {
    short type;
    short handler;
    char *id;
    char *name;
    char *path;
};

/// A structure for holding I/O pipe data
struct PipeSet {
    void *rd_ptr;
    int fd;
    int inotify_fd;
    short status;
    struct PipeInfo *info;
    struct PipeSet *next;
    struct PipeSet *next_output;
};

void close_pipe_set(struct PipeSet *set);
void free_pipe_set(struct PipeSet **set);
struct PipeInfo *get_pipe_info(const char *path);
struct PipeSet *open_pipe_set(const char *path);
int reopen_pipe_set(struct PipeSet *set, struct HopperData *data);
ssize_t read_fifo(struct HopperData *data, struct PipeSet *src);
ssize_t write_fifo(struct HopperData *data, struct PipeSet *dst);

#endif // pipe_h_INCLUDED
