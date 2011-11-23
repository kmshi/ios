
@interface CachedImage : NSObject
{
	NSString *_url;
	UIImage *_image;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy)   NSString *url;

@end
