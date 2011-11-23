#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "SoundSource.h"

@interface AVAudioPlayerSource : NSObject <SoundSource> {
	NSString * path;
	AVAudioPlayer * player;
}

@end
