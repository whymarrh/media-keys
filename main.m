#include <stdlib.h>
#include <string.h>

// ObjC
#import <Foundation/Foundation.h>

// libwebsockets
#include "../../../.bin/libwebsockets/include/libwebsockets.h"

static int callback_http(struct libwebsocket_context *this,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason,
                         void *user,
                         void *in,
                         size_t len) {
	return 0;
}

struct per_session_data__dumb_increment {
	int number;
};

static int callback_dumb_increment(struct libwebsocket_context *this,
                                   struct libwebsocket *wsi,
                                   enum libwebsocket_callback_reasons reason,
                                   void *user,
                                   void *in,
                                   size_t len) {
	switch (reason) {
		case LWS_CALLBACK_ESTABLISHED:
			NSLog(@"Connection established.");
			break;
		case LWS_CALLBACK_RECEIVE:
			NSLog(@"%s", in);
			break;
		default:
			// do nothing
			break;
	}
	return 0;
}

static struct libwebsocket_protocols protocols[] = {
	// { name, callback, per_session_data_size }
	{ "http-only", callback_http, 0, 0 },
	{ "dumb-increment-protocol", callback_dumb_increment, sizeof(struct per_session_data__dumb_increment), 10 },
	// terminator
	{ NULL, NULL, 0, 0 }
};

int main(int argc, char **argv) {
	// create the context for the web sockets
	struct libwebsocket_context *context;
	struct lws_context_creation_info info;
	memset(&info, 0, sizeof info);
	info.port = 8800;
	info.iface = NULL;
	info.protocols = protocols;
	info.extensions = libwebsocket_get_internal_extensions();
	info.ssl_cert_filepath = NULL;
	info.ssl_private_key_filepath = NULL;
	info.gid = -1;
	info.uid = -1;
	info.options = 0;
	context = libwebsocket_create_context(&info);
	if (context == NULL) {
		NSLog(@"Error creating websocket server.");
		return EXIT_FAILURE;
	}
	NSLog(@"Starting server on port %d.", info.port);
	for (;;) {
		libwebsocket_service(context, 50);
	}
	// cleanup
	libwebsocket_context_destroy(context);
	// success
	return EXIT_SUCCESS;
}
