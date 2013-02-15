#include <stdlib.h>
#include <string.h>

// ObjC
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/ev_keymap.h>

// libwebsockets
#include <libwebsockets.h>

static struct libwebsocket *wso = NULL;
static BOOL shouldKeepRunning = YES;
static BOOL shouldInterceptMediaKeyEvents = NO;

struct per_session_data__media_keys {
	int number;
};

// callback function for HTTP requests
static int callback_http(struct libwebsocket_context *this,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason,
                         void *user,
                         void *incoming,
                         size_t len) {
	return 0;
}

// callback function for WS requests
static int callback_media_keys(struct libwebsocket_context *this,
                               struct libwebsocket *wsi,
                               enum libwebsocket_callback_reasons reason,
                               void *user,
                               void *incoming,
                               size_t len) {
	switch (reason) {
		case LWS_CALLBACK_ESTABLISHED:
			NSLog(@"Connection established.");
			// use this new connection to send outgoing messages
			// the issue this causes occurs when multiple
			// connections are made - only the newest is sent the
			// data. Maybe I can use an array? and that way I could
			// loop over all the connections and send the data.
			wso = wsi;
			// start capturing keystrokes
			shouldInterceptMediaKeyEvents = YES;
			break;
		case LWS_CALLBACK_RECEIVE:
			NSLog(@"%s", incoming);
			break;
		default:
			// do nothing
			break;
	}
	return 0;
}

// list of supported protocols and their callbacks
static struct libwebsocket_protocols protocols[] = {
	// { name, callback, per_session_data_size, max frame size / rx buffer }
	{ "http-only", callback_http, 0, 0 },
	{ "media-keys", callback_media_keys, sizeof(struct per_session_data__media_keys), 10 },
	// terminator
	{ NULL, NULL, 0, 0 }
};

@interface MediaKeys : NSApplication
@end

@implementation MediaKeys
- (void) sendEvent:(NSEvent*)event {
	if ([event type] == NSSystemDefined && [event subtype] == 8) {
		int kcode   = ([event data1] & 0xffff0000) >> 16;
		int kflags  =  [event data1] & 0x0000ffff;
		int kstate  = ((kflags & 0xff00) >> 8) == 0xa;
		int krepeat = kflags * 0x1;
		[self mediaKeysEvent:kcode state:kstate repeat:krepeat];
	}
}
- (void) mediaKeysEvent:(int)key state:(BOOL)state repeat:(BOOL)repeat {
	unsigned char *data = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + 1 + LWS_SEND_BUFFER_POST_PADDING);
	data[LWS_SEND_BUFFER_PRE_PADDING] = 42;
	switch (key) {
		case NX_KEYTYPE_REWIND:
			if (state == 0) {
				NSLog(@"Previous song. %d.", key);
				data[LWS_SEND_BUFFER_PRE_PADDING] = key;
			}
			break;
		case NX_KEYTYPE_PLAY:
			if (state == 0) {
				NSLog(@"Play/pause. %d.", key);
				data[LWS_SEND_BUFFER_PRE_PADDING] = key;
			}
			break;
		case NX_KEYTYPE_FAST:
			if (state == 0) {
				NSLog(@"Next song. %d.", key);
				data[LWS_SEND_BUFFER_PRE_PADDING] = key;
			}
			break;
		default:
			// do nothing
			break;
	}
	if (data[LWS_SEND_BUFFER_PRE_PADDING] != 42) {
		// the data has changed && it needs sending
		libwebsocket_write(wso, &data[LWS_SEND_BUFFER_PRE_PADDING], /* length of the actual data */ 1, LWS_WRITE_TEXT);
	}
	free(data);
}
- (void) run {
	// create the context for the web sockets
	struct libwebsocket_context *context;
	struct lws_context_creation_info info;
	memset(&info, 0, sizeof(info));
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
		return;
	}
	// woot!
	NSLog(@"Server started.");
	shouldKeepRunning = YES;
	shouldInterceptMediaKeyEvents = NO;
	do {
		libwebsocket_service(context, 50);
		if (shouldInterceptMediaKeyEvents) {
			// using [NSDate distantFuture] doesn't return until either an event is captured, or the world ends. unacceptable.
			// 0.5s seems like long enough for an event to be captured, and if not it returns
			NSEvent *event = [self nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.5] inMode:NSDefaultRunLoopMode dequeue:YES];
			// and send it to myself
			[self sendEvent:event];
		}
	} while (shouldKeepRunning);
	// clean up time
	libwebsocket_context_destroy(context);
}
- (void) terminate:(id)sender {
	shouldKeepRunning = NO;
}
@end

int main(int argc, char **argv) {
	// create and run the application
	[[[MediaKeys alloc] init] run];
	// all the success
	return EXIT_SUCCESS;
}
