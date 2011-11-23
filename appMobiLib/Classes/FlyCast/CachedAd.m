
#import <UIKit/UIKit.h>
#import "CachedAd.h"

@implementation CachedAd

@synthesize image = _image;
@synthesize audio = _audio;
@synthesize strAdImgURL = _strAdImgURL;
@synthesize strImageURL = _strImageURL;
@synthesize strAudioURL = _strAudioURL;
@synthesize strClickURL = _strClickURL;
@synthesize strBaseImage = _strBaseImage;
@synthesize strImagePath = _strImagePath;
@synthesize strBaseAudio = _strBaseAudio;
@synthesize strAudioPath = _strAudioPath;
@synthesize strGoogleID = _strGoogleID;
@synthesize duration = _duration;
@synthesize number = _number;
@synthesize googleaudio = _googleaudio;
@synthesize googledisplay = _googledisplay;
@synthesize preroll = _preroll;
@synthesize cached = _cached;
@synthesize clicked = _clicked;
@synthesize signup = _signup;

- (id)init
{
	self = [super init];
	_googleaudio = NO;
	_googledisplay = NO;
	_duration = 0;
	_number = 0;
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_strAdImgURL forKey:@"strAdImgURL"];
	[coder encodeObject:_strImageURL forKey:@"strImageURL"];
	[coder encodeObject:_strAudioURL forKey:@"strAudioURL"];
	[coder encodeObject:_strClickURL forKey:@"strClickURL"];
	[coder encodeObject:_strBaseImage forKey:@"strBaseImage"];
	[coder encodeObject:_strBaseAudio forKey:@"strBaseAudio"];
}

- (id)initWithCoder:(NSCoder *)coder
{	
	_strAdImgURL = [[coder decodeObjectForKey:@"strAdImgURL"] retain];
	_strImageURL = [[coder decodeObjectForKey:@"strImageURL"] retain];
	_strAudioURL = [[coder decodeObjectForKey:@"strAudioURL"] retain];
	_strClickURL = [[coder decodeObjectForKey:@"strClickURL"] retain];
	_strBaseImage = [[coder decodeObjectForKey:@"strBaseImage"] retain];
	_strBaseAudio = [[coder decodeObjectForKey:@"strBaseAudio"] retain];
	
	return self;
}

@end
