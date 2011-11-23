
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Buffer : NSObject
{
	AudioQueueBufferRef handle;
	NSData *data;
}

@property (assign) AudioQueueBufferRef handle;
@property (assign) NSData *data;

@end
