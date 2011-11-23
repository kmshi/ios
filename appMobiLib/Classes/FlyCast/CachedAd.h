
@interface CachedAd : NSObject
{
	UIImage  *_image;
	NSData   *_audio;
	NSString *_strAdImgURL;
	NSString *_strImageURL;
	NSString *_strAudioURL;
	NSString *_strClickURL;
	NSString *_strBaseImage;
	NSString *_strImagePath;
	NSString *_strBaseAudio;
	NSString *_strAudioPath;
	NSString *_strGoogleID;
	int       _duration;
	BOOL      _googleaudio;
	BOOL      _googledisplay;
	BOOL      _preroll;
	BOOL      _cached;
	BOOL      _clicked;
	BOOL      _signup;
	int       _number;
}

@property (nonatomic, retain) UIImage  *image;
@property (nonatomic, retain) NSData   *audio;
@property (nonatomic, retain) NSString *strAdImgURL;
@property (nonatomic, retain) NSString *strImageURL;
@property (nonatomic, retain) NSString *strAudioURL;
@property (nonatomic, retain) NSString *strClickURL;
@property (nonatomic, retain) NSString *strBaseImage;
@property (nonatomic, retain) NSString *strImagePath;
@property (nonatomic, retain) NSString *strBaseAudio;
@property (nonatomic, retain) NSString *strAudioPath;
@property (nonatomic, retain) NSString *strGoogleID;
@property (nonatomic) int duration;
@property (nonatomic) int number;
@property (nonatomic) BOOL googleaudio;
@property (nonatomic) BOOL googledisplay;
@property (nonatomic) BOOL preroll;
@property (nonatomic) BOOL cached;
@property (nonatomic) BOOL clicked;
@property (nonatomic) BOOL signup;

@end
