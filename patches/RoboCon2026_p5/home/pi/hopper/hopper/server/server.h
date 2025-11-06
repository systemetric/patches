#ifndef server_h_INCLUDED
#define server_h_INCLUDED

#include <unistd.h>

#define MAX_EVENTS 64
#define MAX_COPY_SIZE 1024 * 1024
#define MAX_BUF_SIZE MAX_COPY_SIZE

struct HopperBuffer {
    void *buf;
    void *buf_end;
    void *wr_ptr;
    void *last_wr_ptr;
    ssize_t buf_len;
};

struct HopperData {
    struct PipeSet *pipes;
    struct PipeSet **outputs;
    struct HopperBuffer **buffers;
    int n_pipes;
    int epoll_fd;
    int inotify_fd;
    int inotify_root_watch_fd;
    int devnull;
    const char *pipe_dir;
};

void pipe_set_status_inactive(struct PipeSet *set, struct HopperData *data);
void pipe_set_status_active(struct PipeSet *set, struct HopperData *data);
void *get_high_read_ptr(struct HopperData *data, short handler);
void *get_low_read_ptr(struct HopperData *data, short handler);

#endif // server_h_INCLUDED
