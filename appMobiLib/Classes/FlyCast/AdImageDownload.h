
#import "XMLNode.h"
#import "XMLDirectory.h"

@interface AdImageDownload : NSObject
{
    XMLDirectory *_dir;
	XMLNode *_node;
	NSString *_adUrl;
	NSString *_addart;
	UITableViewCell *_cell;
	BOOL _bRefresh;
	int _width;
	int _height;
}

@property (nonatomic, retain) XMLDirectory *dir;
@property (nonatomic, retain) XMLNode *node;
@property (nonatomic, copy)   NSString *adUrl;
@property (nonatomic, copy)   NSString *addart;
@property (nonatomic, retain) UITableViewCell *cell;
@property (nonatomic) BOOL bRefresh;
@property (nonatomic) int width;
@property (nonatomic) int height;

@end
