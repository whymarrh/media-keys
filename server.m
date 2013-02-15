#include <stdlib.h>

// ObjC
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/ev_keymap.h>

// libwebsockets
#include <libwebsockets.h>

static CFRunLoopRef tapThreadRunLoop = NULL;
static CFRunLoopSourceRef eventPortSource = NULL;
static CFMachPortRef eventPort = NULL;
static struct libwebsocket *wso = NULL;
static BOOL shouldKeepRunning = YES;

struct per_session_data__media_keys {
	int number;
};

// callback function for WS requests
static int callback_media_keys(struct libwebsocket_context *this,
                               struct libwebsocket *wsi,
                               enum libwebsocket_callback_reasons reason,
                               void *user,
                               void *incoming,
                               size_t len) {
	switch (reason) {
		case LWS_CALLBACK_ESTABLISHED:
			NSLog(@"New connection established.");
			// use this new connection to send outgoing messages
			// this may cause issues when multiple connections
			// are made - only the newest is sent the data.
			wso = wsi;
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
	{ "media-keys", callback_media_keys, sizeof(struct per_session_data__media_keys), 10 },
	// terminator
	{ NULL, NULL, 0, 0 }
};

@interface MediaKeys : NSApplication
- (void) handleMediaKeyEvent:(NSEvent*)event;
@end

static CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
	NSEvent *nsEvent = nil;
	@try {
		nsEvent = [NSEvent eventWithCGEvent:event];
	}
	@catch (NSException *e) {
		return event;
	}
	// we have an NSEvent and the type
	if (type != NSSystemDefined || [nsEvent subtype] != 8) {
		// this probably is not a media key
		return event;
	}
	int kcode = ([nsEvent data1] & 0xffff0000) >> 16;
	if (kcode != NX_KEYTYPE_REWIND && kcode != NX_KEYTYPE_PLAY && kcode != NX_KEYTYPE_FAST) {
		// we only want certain media keys
		return event;
	}
	MediaKeys *self = (__bridge MediaKeys*) refcon;
	// this feels very wrong
	[self handleMediaKeyEvent:nsEvent];
	// handle the event on the main thread
	// [self performSelectorOnMainThread:@selector(handleMediaKeyEvent:) withObject:nsEvent waitUntilDone:NO];
	// pass nothing along
	return NULL;
}

@implementation MediaKeys
- (void) startWatchingMediaKeys {
	eventPort = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, CGEventMaskBit(NX_SYSDEFINED), tapEventCallback, (__bridge void*) self);
	assert(eventPort != NULL);
	eventPortSource = CFMachPortCreateRunLoopSource(kCFAllocatorSystemDefault, eventPort, 0);
	assert(eventPortSource != NULL);
	// start a new thread on which to watch for events
	[NSThread detachNewThreadSelector:@selector(eventTapThread) toTarget:self withObject:nil];
}
- (void) eventTapThread {
	tapThreadRunLoop = CFRunLoopGetCurrent();
	CFRunLoopAddSource(tapThreadRunLoop, eventPortSource, kCFRunLoopCommonModes);
	CFRunLoopRun();
}
- (void) handleMediaKeyEvent:(NSEvent*)event {
	// the key code from the event
	int kcode = ([event data1] & 0xffff0000) >> 16;
	// the state of the the event
	int kstate  = ((([event data1] & 0x0000ffff) & 0xff00) >> 8) == 0xa;
	// the length of, and the data to be sent across
	int len = 1;
	unsigned char *data = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + len + LWS_SEND_BUFFER_POST_PADDING);
	data[LWS_SEND_BUFFER_PRE_PADDING] = 42; // default value
	switch (kcode) {
		case NX_KEYTYPE_REWIND:
			if (kstate == 0) {
				NSLog(@"Previous song.");
				data[LWS_SEND_BUFFER_PRE_PADDING] = kcode;
			}
			break;
		case NX_KEYTYPE_PLAY:
			if (kstate == 0) {
				NSLog(@"Play/pause.");
				data[LWS_SEND_BUFFER_PRE_PADDING] = kcode;
			}
			break;
		case NX_KEYTYPE_FAST:
			if (kstate == 0) {
				NSLog(@"Next song.");
				data[LWS_SEND_BUFFER_PRE_PADDING] = kcode;
			}
			break;
		default:
			// do nothing
			break;
	}
	if (data[LWS_SEND_BUFFER_PRE_PADDING] != 42) {
		// the data has changed && it needs sending
		libwebsocket_write(wso, &data[LWS_SEND_BUFFER_PRE_PADDING], len, LWS_WRITE_TEXT);
	}
	free(data);
}
- (void) run {
	// create the context for the web sockets
	struct libwebsocket_context *context;
	struct lws_context_creation_info info;
	memset(&info, 0, sizeof(info));
	info.port = 9331;
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
	// start watching for media key activity
	[self startWatchingMediaKeys];
	while (shouldKeepRunning) {
		libwebsocket_service(context, 50);
	}
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
