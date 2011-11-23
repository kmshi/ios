
#import "AdImageDownload.h"

@implementation AdImageDownload

@synthesize dir = _dir;
@synthesize node = _node;
@synthesize cell = _cell;
@synthesize adUrl = _adUrl;
@synthesize addart = _addart;
@synthesize width = _width;
@synthesize height = _height;
@synthesize bRefresh = _bRefresh;

- (id)init
{
	self = [super init];
	_dir = nil;
	_node = nil;
	_cell = nil;
	_adUrl = nil;
	_addart	= nil;
	_width = 320;
	_height = 43;
	_bRefresh = NO;
	return self;
}

@end
