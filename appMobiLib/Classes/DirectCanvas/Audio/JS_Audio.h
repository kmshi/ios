#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"

#import "OpenALManager.h"
#import "OpenALSource.h"
#import "AVAudioPlayerSource.h"

// Max size of audio effects using OpenAL; beyond that, the AVAudioPlayer is used
#define JS_AUDIO_OPENAL_MAX_SIZE 512 * 1024 // 512kb

@interface JS_Audio : JS_BaseClass {
	NSString * path;
	NSObject<SoundSource> * source;
	
	BOOL loop;
	float volume;
}

@end
