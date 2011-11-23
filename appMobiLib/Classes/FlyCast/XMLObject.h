
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define NONE      0
#define DIRECTORY 1
#define NODE      2
#define PLAYLIST  3
#define TRACK     4
#define PODCAST   5
#define ITEM      6
#define TIMEBLOCK 7
#define TRACKLIST 8

@interface XMLObject : NSObject <NSCoding>
{
	int type;
	NSMutableArray *_children;
}

@property (nonatomic) int type;
@property (nonatomic, retain) NSMutableArray *children;

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

@end
