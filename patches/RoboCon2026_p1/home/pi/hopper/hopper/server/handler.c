#include <stdio.h>
#include <string.h>

#include "handler.h"

/// A mapping between a handler ID and name
struct HandlerMapping {
    short handler;
    char *name;
};

/// An array of handler mappings
static struct HandlerMapping HANDLER_MAP[] = {
    HANDLER_GENERIC,      HANDLER_LOG,

#ifdef UNUSED_HANDLERS
    HANDLER_FULL_LOG,     HANDLER_COMPLETE_LOG,
#endif

    HANDLER_START_BUTTON, HANDLER_STARTER,      HANDLER_HARDWARE,
};

/// Maps a handler string to an ID number
short map_handler_to_id(char *handler) {
    int n_handlers = sizeof(HANDLER_MAP) / sizeof(struct HandlerMapping);

    for (int i = 0; i < n_handlers; i++)
        if (!strcmp(handler, HANDLER_MAP[i].name))
            return HANDLER_MAP[i].handler;

    printf("pipe handler '%s' is not recognised\n", handler);

    return HANDLER_UNKNOWN;
}
