
#import "XMLObject.h"

@interface XMLDirectory : XMLObject
{
    NSString *_name;
    NSString *_prompt;
    NSString *_desc;
    NSString *_img;
	NSString *_id;
	NSString *_color;
	NSString *_title;
	NSString *_url;
	NSString *_value;
	NSString *_message;
	NSString *_adimg;
	NSString *_icon;
	NSString *_adid;
	NSString *_addart;
	NSString *_pid;
	NSString *_guideid;
	NSString *_align;
	int _height;
	int _width;
	int _version;
	double _timecode;
	BOOL _isRecording;
	BOOL _bRefresh;
	UIImage *_adart;
}

@property (nonatomic, retain) NSString *dirname;
@property (nonatomic, retain) NSString *dirprompt;
@property (nonatomic, retain) NSString *dirdesc;
@property (nonatomic, retain) NSString *dirimg;
@property (nonatomic, retain) NSString *dirid;
@property (nonatomic, retain) NSString *dircolor;
@property (nonatomic, retain) NSString *dirtitle;
@property (nonatomic, retain) NSString *dirurl;
@property (nonatomic, retain) NSString *dirvalue;
@property (nonatomic, retain) NSString *diradimg;
@property (nonatomic, retain) NSString *diricon;
@property (nonatomic, retain) NSString *diradid;
@property (nonatomic, retain) NSString *dirmessage;
@property (nonatomic, retain) NSString *diraddart;
@property (nonatomic, retain) NSString *dirpid;
@property (nonatomic, retain) NSString *dirguideid;
@property (nonatomic, retain) NSString *diralign;
@property (nonatomic) int dirheight;
@property (nonatomic) int dirwidth;
@property (nonatomic) int dirversion;
@property (nonatomic) double dirtimecode;
@property (nonatomic) BOOL dirisRecording;
@property (nonatomic) BOOL dirbRefresh;
@property (nonatomic, retain) UIImage  *diradart;

@end
