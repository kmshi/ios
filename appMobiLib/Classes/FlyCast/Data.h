
#import <Foundation/Foundation.h>

@interface Data : NSObject
{
	UInt8 *buffer;
	UInt32 byte;
}

@property (assign) UInt8 *buffer;
@property (assign) UInt32 byte;

@end
