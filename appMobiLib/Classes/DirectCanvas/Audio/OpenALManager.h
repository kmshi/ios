#import <Foundation/Foundation.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface OpenALManager : NSObject {
	ALCcontext * context;
	ALCdevice * device;
	NSMutableDictionary *sources;
}

+ (OpenALManager *)instance;

@property (readonly) NSMutableDictionary * sources;

@end
