#ifndef handler_h_INCLUDED
#define handler_h_INCLUDED

#define HANDLER_UNKNOWN 0
#define HANDLER_GENERIC {1, "generic"}
#define HANDLER_LOG {2, "log"}

#ifdef UNUSED_HANDLERS

#define HANDLER_FULL_LOG {3, "fulllog"}
#define HANDLER_COMPLETE_LOG {4, "complog"}

#endif

#define HANDLER_START_BUTTON {5, "start-button"}
#define HANDLER_STARTER {6, "starter"}
#define HANDLER_HARDWARE {7, "hardware"}

#define MAX_HANDLER_ID 7

short map_handler_to_id(char *handler);


#endif // handler_h_INCLUDED
