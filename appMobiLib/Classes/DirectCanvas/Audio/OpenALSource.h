#import <Foundation/Foundation.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#import "SoundSource.h"

@interface OpenALSource : NSObject <SoundSource> {
	NSString * path;
	NSUInteger bufferId, sourceId;
}

- (void*)getAudioDataWithURL:(NSURL *)inFileURL size:(ALsizei *)outDataSize format:(ALenum *)outDataFormat rate:(ALsizei *)outSampleRate;

@end
