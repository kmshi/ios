
#import "XMLDirectory.h"

@implementation XMLDirectory

@synthesize dirname = _name;
@synthesize dirprompt = _prompt;
@synthesize dirdesc = _desc;
@synthesize dirimg = _img;
@synthesize dirid = _id;
@synthesize dircolor = _color;
@synthesize dirtitle = _title;
@synthesize dirurl = _url;
@synthesize dirvalue = _value;
@synthesize dirmessage = _message;
@synthesize diricon = _icon;
@synthesize diradimg = _adimg;
@synthesize diradid = _adid;
@synthesize diradart = _adart;
@synthesize diraddart = _addart;
@synthesize dirpid = _pid;
@synthesize dirguideid = _guideid;
@synthesize diralign = _align;
@synthesize dirheight = _height;
@synthesize dirwidth = _width;
@synthesize dirversion = _version;
@synthesize dirtimecode = _timecode;
@synthesize dirisRecording = _isRecording;
@synthesize dirbRefresh = _bRefresh;

- (id)init
{
	self = [super init];
	type = DIRECTORY;
	return self;
}

- (void)dealloc
{
	[_name release];
	[_prompt release];
	[_desc release];
	[_img release];
	[_id release];
	[_pid release];
	[_guideid release];
	[_color release];
	[_title release];
	[_url release];
	[_value release];
	[_adimg release];
	[_adid release];
	[_adart release];
	[super dealloc];
}

@end
