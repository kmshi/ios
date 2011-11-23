
#import <Foundation/Foundation.h>

@class XMLDirectory;
@class XMLNode;

@interface XMLDirectoryReader : NSObject <NSXMLParserDelegate>
{
    NSMutableArray *_tempStack;
	XMLDirectory *_directory;
	NSData *keepdata;
	BOOL bKeep;
	void *myInfo;
}

@property (nonatomic, retain) XMLDirectory *directory;

- (NSData *)parseXMLURL:(NSString *)url andKeepData:(BOOL)keep;
- (void)parseXMLData:(NSData *)data;

@end
