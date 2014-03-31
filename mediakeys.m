#import <Cocoa/Cocoa.h>
#import <libwebsockets.h>
#import <signal.h>
#import <stdlib.h>

#define MAX_CLIENTS 32 // Arbitrary limit
int num_clients = 0;
struct libwebsocket *clients[MAX_CLIENTS];

/**
 * Protocol callback
 */
int callback_media_keys(struct libwebsocket_context *this,
                        struct libwebsocket *wsi,
                        enum libwebsocket_callback_reasons reason,
                        void *user,
                        void *incoming,
                        size_t len) {
	switch (reason) {
		// Called before sending a response to the client
		case LWS_CALLBACK_FILTER_PROTOCOL_CONNECTION: {
			if (num_clients >= MAX_CLIENTS) {
				return 1; // Disallow connection
			}
			break;
		}
		// Called when a connection closes
		case LWS_CALLBACK_CLOSED: {
			printf("A client has left\n");
			for (int i = 0; i < num_clients; i++) {
				if (clients[i] == wsi) {
					num_clients--;
					printf("Removed client\n");
					while (i < num_clients) {
						// Shift everyone down
						clients[i] = clients[i + 1];
						i++;
					}
				}
			}
			printf("%d client(s) remain\n", num_clients);
			break;
		}
		// Called when a connection is made
		case LWS_CALLBACK_ESTABLISHED: {
			printf("New client connected\n");
			clients[num_clients] = wsi;
			printf("Client %d added\n", num_clients);
			num_clients++;
			break;
		}
		default: {
			// Do nothing
			break;
		}
	}
	return 0;
}

struct per_session_data__media_keys { int code; };

/**
 * List of the supported protocols and their callback fns
 */
struct libwebsocket_protocols protocols[] = {
	// { name, callback, per_session_data_size, max frame size }
	{ "media-keys", callback_media_keys, sizeof(struct per_session_data__media_keys), 10 },
	{ NULL, NULL, 0, 0 }
};

/**
 * Runloop variable
 */
BOOL shouldKeepRunning = YES;

CFRunLoopSourceRef eventPortSource = NULL;

/**
 * Prototype for key event callback
 */
CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType eventType, CGEventRef eventRef, void *ref);

/**
 * Interface for MediaKeys class
 */
@interface MediaKeys: NSApplication
- (void)listenForKeyEvents;
- (void)eventTapThread;
- (void)handleKeyCode:(int)code withKeyState:(int)state;
@end

/**
 * Implementation of the MediaKeys class
 */
@implementation MediaKeys
- (void)listenForKeyEvents
{
	CFMachPortRef eventPort = CGEventTapCreate(
	                              kCGSessionEventTap,
	                              kCGHeadInsertEventTap,
	                              kCGEventTapOptionDefault,
	                              CGEventMaskBit(NX_SYSDEFINED),
	                              tapEventCallback,
	                              self
	);
	assert(eventPort != NULL);
	eventPortSource = CFMachPortCreateRunLoopSource(kCFAllocatorSystemDefault, eventPort, 0);
	assert(eventPortSource != NULL);
	// Start a new thread on which to watch for events
	[NSThread detachNewThreadSelector:@selector(eventTapThread) toTarget:self withObject:nil];
}
- (void)eventTapThread
{
	CFRunLoopRef tapThreadRunLoop = CFRunLoopGetCurrent();
	CFRunLoopAddSource(tapThreadRunLoop, eventPortSource, kCFRunLoopCommonModes);
	CFRunLoopRun();
}
- (void)handleKeyCode:(int)code withKeyState:(int)state
{
	if (state) {
		// Key down
		return;
	}
	// Key up
	int len = 1;
	unsigned char data[LWS_SEND_BUFFER_PRE_PADDING + len + LWS_SEND_BUFFER_POST_PADDING];
	data[LWS_SEND_BUFFER_PRE_PADDING] = code;
	for (int i = 0; i < num_clients; i++) {
		libwebsocket_write(clients[i], &data[LWS_SEND_BUFFER_PRE_PADDING], len, LWS_WRITE_TEXT);
		NSLog(@"Sent %d", code);
	}
}
- (void)run
{
	int log_level = 1; // Errors only
	lws_set_log_level(log_level, lwsl_emit_syslog);
	struct libwebsocket_context *context;
	struct lws_context_creation_info info;
	memset(&info, 0, sizeof(info));

	info.port = 9331; // Arbitrary port number
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

	NSLog(@"Server started");
	[self listenForKeyEvents];
	while (shouldKeepRunning) {
		libwebsocket_service(context, 50);
	}

	libwebsocket_context_destroy(context);
	NSLog(@"End run");
}
- (void)terminate:(id)sender
{
	shouldKeepRunning = NO;
}
@end

/**
 * Callback for key events
 */
CGEventRef tapEventCallback(CGEventTapProxy proxy, CGEventType eventType, CGEventRef eventRef, void *ref)
{
	NSEvent *event = nil;
	@try {
		// Attempt to convert to NSEvent
		event = [NSEvent eventWithCGEvent:eventRef];
	}
	@catch (NSException *e) {
		return eventRef;
	}

	// Heavy wizardry
	int keyCode = ([event data1] & 0xffff0000) >> 16;
	int keyState = ((([event data1] & 0x0000ffff) & 0xff00) >> 8) == 0xa;
	if (eventType != NSSystemDefined || [event subtype] != 8 || (keyCode != 16 && keyCode != 19 && keyCode != 20)) {
		return eventRef; // Not the key we're looking for
	}

	MediaKeys *keys = ref;
	[keys handleKeyCode:keyCode withKeyState:keyState];
	[event dealloc];
	return nil; // Do not pass along the event
}

/**
 * Signal handler
 */
void signal_handler(int sig)
{
	printf("\n");
	shouldKeepRunning = NO;
}

/**
 * Main method
 */
int main(int argc, char **argv)
{
	printf("Start main\n");
	signal(SIGINT, signal_handler);
	MediaKeys *keys = [[MediaKeys alloc] init];
	[keys run];
	[keys dealloc];
	printf("After dealloc\n");
	return 0;
}
