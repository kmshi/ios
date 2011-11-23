
#import "XMLDirectoryReader.h"
#import "XMLDirectory.h"
#import "XMLNode.h"

#import <CoreFoundation/CFUrl.h>
#import <CFNetwork/CFNetwork.h>

struct XMLTestInfo
{
	BOOL bDoneXMLStream;
	BOOL bTimeout;
	int mXMLDownloaded;
	UInt8 *buffer;
	int bufferSize;

	NSString *serverurl;
	BOOL bDownloading;
};

void myReadXMLPackets(CFReadStreamRef stream, CFStreamEventType event, void *inUserData)
{
	XMLTestInfo *infoPtr = (XMLTestInfo *) inUserData;
	if( infoPtr->bDoneXMLStream == YES ) return;

	CFIndex bytesRead;
	@try
	{
		switch(event)
		{
			case kCFStreamEventHasBytesAvailable:
				UInt8 buf[65535];

				bytesRead = CFReadStreamRead(stream, buf, 65535);
				while( bytesRead > 0 )
				{
					if( infoPtr->bufferSize < ( infoPtr->mXMLDownloaded + bytesRead ) )
					{
						UInt8 *newbuffer =  new UInt8[infoPtr->bufferSize + 65535];
						memcpy( newbuffer, infoPtr->buffer, infoPtr->bufferSize );
						UInt8 *tempbuffer = infoPtr->buffer;
						infoPtr->buffer = newbuffer;
						infoPtr->bufferSize += 65535;
						delete tempbuffer;
					}
					memcpy(infoPtr->buffer + infoPtr->mXMLDownloaded, buf, bytesRead );
					infoPtr->mXMLDownloaded += bytesRead;
					bytesRead = CFReadStreamRead(stream, buf, 65535);
				}
				break;
			case kCFStreamEventErrorOccurred:
				infoPtr->bDoneXMLStream = YES;
				break;
			case kCFStreamEventEndEncountered:
				infoPtr->bDoneXMLStream = YES;
				break;
		}
	}
	@catch (NSException *theErr)
	{
		infoPtr->bDoneXMLStream = YES;
	}
}

@implementation XMLDirectoryReader

@synthesize directory = _directory;

- (id)init
{
	self = [super init];
	_directory = nil;

	return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	_tempStack = [[NSMutableArray alloc] init];
}

- (void)doneXML:(id)sender
{
	XMLTestInfo *infoPtr = (XMLTestInfo *) myInfo;
	NSData *data = [NSData dataWithBytes:infoPtr->buffer length:infoPtr->mXMLDownloaded];
	[self parseXMLData:data];
	delete infoPtr->buffer;
	if( bKeep )
	{
		keepdata = [data retain];
	}
	infoPtr->bDownloading = NO;
}

- (NSData *)parseXMLURL:(NSString *)url andKeepData:(BOOL)keep;
{
	myInfo = new XMLTestInfo();
	XMLTestInfo *infoPtr = (XMLTestInfo *) myInfo;
	infoPtr->bDoneXMLStream = NO;
	infoPtr-> mXMLDownloaded = 0;
	infoPtr->buffer = new UInt8[65535];
	infoPtr->bufferSize = 65535;
	infoPtr->serverurl = url;
	infoPtr->bDownloading = YES;
	infoPtr->bTimeout = NO;

	keepdata = nil;
	bKeep = keep;

	printf(" --- %s\n", [url cStringUsingEncoding:NSASCIIStringEncoding]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	[NSThread detachNewThreadSelector:@selector(threadWorker:) toTarget:self withObject:nil];
	do {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.2, false);
	} while ( infoPtr->bDownloading );
	delete infoPtr;

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	return keepdata;
}

- (void)parseXMLData:(NSData *)data
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	if( parser == nil ) return;

    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];

    [parser parse];
    [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if(qName)
	{
        elementName = qName;
    }

    if([elementName isEqualToString:@"DIR"])
	{
		XMLDirectory *dir = [[[XMLDirectory alloc] init] autorelease];
		dir.children = [[[NSMutableArray alloc] init] autorelease];
		dir.dirname = [[[attributeDict valueForKey:@"name"] copy] autorelease];
		dir.dirprompt = [[[attributeDict valueForKey:@"prompt"] copy] autorelease];
		dir.dirimg = [[[attributeDict valueForKey:@"img"] copy] autorelease];
		dir.dirdesc = [[[attributeDict valueForKey:@"description"] copy] autorelease];
		dir.dirid = [[[attributeDict valueForKey:@"id"] copy] autorelease];
		dir.dirmessage = [[[attributeDict valueForKey:@"message"] copy] autorelease];
		dir.dircolor = [[[attributeDict valueForKey:@"color"] copy] autorelease];
		dir.dirtitle = [[[attributeDict valueForKey:@"title"] copy] autorelease];
		dir.dirurl = [[[attributeDict valueForKey:@"url"] copy] autorelease];
		dir.dirvalue = [[[attributeDict valueForKey:@"value"] copy] autorelease];
		dir.diradimg = [[[attributeDict valueForKey:@"adimg"] copy] autorelease];
		dir.diricon = [[[attributeDict valueForKey:@"icon"] copy] autorelease];
		dir.diraddart = [[[attributeDict valueForKey:@"addart"] copy] autorelease];
		dir.diradid = [[[attributeDict valueForKey:@"adid"] copy] autorelease];
		dir.dirpid = [[[attributeDict valueForKey:@"pid"] copy] autorelease];
		dir.dirguideid = [[[attributeDict valueForKey:@"guideid"] copy] autorelease];
		dir.diralign = [[[attributeDict valueForKey:@"align"] copy] autorelease];
		dir.dirheight = [[attributeDict valueForKey:@"height"] intValue];
		dir.dirwidth = [[attributeDict valueForKey:@"width"] intValue];
		dir.dirversion = [[attributeDict valueForKey:@"version"] intValue];
		dir.dirtimecode = CFAbsoluteTimeGetCurrent();
		[_tempStack addObject:dir];

		if( _directory == nil )
		{
			_directory = dir;
			[_directory retain];
		}
		else
		{
			int last = [_tempStack count] - 2;
			XMLDirectory *curdir = (XMLDirectory *) [_tempStack objectAtIndex:last];
			[curdir.children addObject:dir];
		}
    }
	else if([elementName isEqualToString:@"NOD"])
	{
		if( _directory == nil ) return;
		int last = [_tempStack count] - 1;
		XMLDirectory *dir = (XMLDirectory *) [_tempStack objectAtIndex:last];
		XMLNode *node = [[[XMLNode alloc] init] autorelease];
		node.nodename = [[[[attributeDict valueForKey:@"name"] stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""] copy] autorelease];
		node.nodeid = [[[attributeDict valueForKey:@"id"] copy] autorelease];
		node.nodeurl = [[[attributeDict valueForKey:@"url"] copy] autorelease];
		node.nodesid = [[[attributeDict valueForKey:@"sid"] copy] autorelease];
		node.nodeplayer = [[[attributeDict valueForKey:@"player"] copy] autorelease];
		node.nodeimg = [[[attributeDict valueForKey:@"img"] copy] autorelease];
		node.nodedesc = [[[[attributeDict valueForKey:@"description"] stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""] copy] autorelease];
		node.nodefav = [[[attributeDict valueForKey:@"favorite"] copy] autorelease];
		node.nodeauthor = [[[attributeDict valueForKey:@"author"] copy] autorelease];
		node.nodecolor = [[[attributeDict valueForKey:@"color"] copy] autorelease];
		node.nodebcolor = [[[attributeDict valueForKey:@"bcolor"] copy] autorelease];
		node.nodeskip = [[[attributeDict valueForKey:@"skip"] copy] autorelease];
		node.nodeinfo = [[[attributeDict valueForKey:@"info"] copy] autorelease];
		node.nodetype = [[[attributeDict valueForKey:@"type"] copy] autorelease];
		node.nodevalue = [[[attributeDict valueForKey:@"value"] copy] autorelease];
		node.nodeshout = [[[attributeDict valueForKey:@"shout"] copy] autorelease];
		node.nodetitle = [[[attributeDict valueForKey:@"title"] copy] autorelease];
		node.nodeadurl = [[[attributeDict valueForKey:@"adurl"] copy] autorelease];
		node.nodeadimg = [[[attributeDict valueForKey:@"adimg"] copy] autorelease];
		node.nodeicon = [[[attributeDict valueForKey:@"icon"] copy] autorelease];
		node.nodeadid = [[[attributeDict valueForKey:@"adid"] copy] autorelease];
		node.nodepath = [[[attributeDict valueForKey:@"path"] copy] autorelease];
		node.nodebanner = [[[attributeDict valueForKey:@"bannerAdBucket"] copy] autorelease];
		node.nodeadpage = [[[attributeDict valueForKey:@"adpage"] copy] autorelease];
		node.nodepid = [[[attributeDict valueForKey:@"pid"] copy] autorelease];
		node.nodeguideid = [[[attributeDict valueForKey:@"guideid"] copy] autorelease];
		node.nodeaddart = [[[attributeDict valueForKey:@"addart"] copy] autorelease];
		node.nodeadheight = [[[attributeDict valueForKey:@"adheight"] copy] autorelease];
		node.nodeadwidth = [[[attributeDict valueForKey:@"adwidth"] copy] autorelease];
		node.nodelocal = [[[attributeDict valueForKey:@"local"] copy] autorelease];
		node.nodeminback = [[[attributeDict valueForKey:@"minback"] copy] autorelease];
		node.nodeadpage = [[[attributeDict valueForKey:@"adpage"] copy] autorelease];
		node.nodepodcast = [[[attributeDict valueForKey:@"podcast"] copy] autorelease];
		node.nodeplaylist = [[[attributeDict valueForKey:@"playlist"] copy] autorelease];
		node.nodeheight = [[attributeDict valueForKey:@"height"] intValue];
		node.nodewidth = [[attributeDict valueForKey:@"width"] intValue];
		node.nodeprerollad = [[[attributeDict valueForKey:@"prerollad"] copy] autorelease];
		node.nodeprerollheight = [[[attributeDict valueForKey:@"prerollheight"] copy] autorelease];
		node.nodeprerollwidth = [[[attributeDict valueForKey:@"prerollwidth"] copy] autorelease];
		node.nodeexpdays = [[attributeDict valueForKey:@"expdays"] intValue];
		node.nodeexpplays = [[attributeDict valueForKey:@"expplays"] intValue];
		node.nodebannerfreq = [[attributeDict valueForKey:@"bannerInterval"] intValue];
		node.nodeinterfreq = [[attributeDict valueForKey:@"interstitalInterval"] intValue];
		node.adbannerzone = [[[attributeDict valueForKey:@"ad.banner.zone"] copy] autorelease];
		node.adbannerwidth = [[[attributeDict valueForKey:@"ad.banner.width"] copy] autorelease];
		node.adbannerheight = [[[attributeDict valueForKey:@"ad.banner.height"] copy] autorelease];
		node.adbannerfreq = [[[attributeDict valueForKey:@"ad.banner.frequency"] copy] autorelease];
		node.adprerollzone = [[[attributeDict valueForKey:@"ad.preroll.zone"] copy] autorelease];
		node.adprerollwidth = [[[attributeDict valueForKey:@"ad.preroll.width"] copy] autorelease];
		node.adprerollheight = [[[attributeDict valueForKey:@"ad.preroll.height"] copy] autorelease];
		node.adprerollfreq = [[[attributeDict valueForKey:@"ad.preroll.frequency"] copy] autorelease];
		node.adpopupzone = [[[attributeDict valueForKey:@"ad.popup.zone"] copy] autorelease];
		node.adpopupwidth = [[[attributeDict valueForKey:@"ad.popup.width"] copy] autorelease];
		node.adpopupheight = [[[attributeDict valueForKey:@"ad.popup.height"] copy] autorelease];
		node.adpopupfreq = [[[attributeDict valueForKey:@"ad.popup.frequency"] copy] autorelease];
		node.adinterzone = [[[attributeDict valueForKey:@"ad.interstitial.zone"] copy] autorelease];
		node.adinterwidth = [[[attributeDict valueForKey:@"ad.interstitial.width"] copy] autorelease];
		node.adinterheight = [[[attributeDict valueForKey:@"ad.interstitial.height"] copy] autorelease];
		node.adinterfreq = [[[attributeDict valueForKey:@"ad.interstitial.frequency"] copy] autorelease];
		node.adsignupzone = [[[attributeDict valueForKey:@"ad.signup.zone"] copy] autorelease];
		node.adsignupwidth = [[[attributeDict valueForKey:@"ad.signup.width"] copy] autorelease];
		node.adsignupheight = [[[attributeDict valueForKey:@"ad.signup.height"] copy] autorelease];
		node.adsignupfreq = [[[attributeDict valueForKey:@"ad.signup.frequency"] copy] autorelease];
		node.nodeallowdelete = [[attributeDict valueForKey:@"deleteOK"] intValue];
		node.nodeallowshuffle = [[attributeDict valueForKey:@"shuffleOK"] intValue];
		node.nodeautohide = [[attributeDict valueForKey:@"autoHide"] intValue];
		node.nodeautoshuffle = [[attributeDict valueForKey:@"autoShuffle"] intValue];
		node.noderating = [[attributeDict valueForKey:@"rating"] intValue];
		node.nodeisFlyBack = [[attributeDict valueForKey:@"flyback"] intValue];
		node.nodetimecode = CFAbsoluteTimeGetCurrent();

		[dir.children addObject:node];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if(qName)
	{
        elementName = qName;
    }

    if([elementName isEqualToString:@"DIR"])
	{
		[_tempStack removeLastObject];
    }

	if( _tempStack != nil && [_tempStack count] == 0 )
	{
		[_tempStack release];
		_tempStack = nil;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}

- (void)threadWorker:(id)anObject
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	XMLTestInfo *infoPtr = (XMLTestInfo *) myInfo;
	infoPtr->bDoneXMLStream = NO;

	const UInt8 bodyData = 0;
	CFStringRef url = CFStringCreateWithCString( NULL, [infoPtr->serverurl cStringUsingEncoding:NSUTF8StringEncoding], kCFStringEncodingUTF8);
	CFURLRef myURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
	CFStringRef requestMethod = CFSTR("GET");
	CFHTTPMessageRef myRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, myURL, kCFHTTPVersion1_1);
	CFDataRef myData = CFDataCreate(NULL, &bodyData, 0);
	NSString *agentStr = [NSString stringWithFormat:@"appMobi/1.0 (iPhone; U; CPU like Mac OS X; en)"];
	CFStringRef headerFieldName = CFSTR("User-Agent");
	CFStringRef headerFieldValue = CFStringCreateWithCString( NULL, [agentStr cStringUsingEncoding:NSUTF8StringEncoding], kCFStringEncodingUTF8);
	CFHTTPMessageSetHeaderFieldValue(myRequest, headerFieldName, headerFieldValue);
	CFHTTPMessageSetBody(myRequest, myData);
	CFStreamClientContext clientContext = { 0, myInfo, NULL, NULL, NULL };
	CFReadStreamRef myReadStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, myRequest);
	CFRelease( myRequest );
	CFRelease( myURL );
	CFRelease( myData );
	CFRelease( url );
	CFRelease( headerFieldValue );
	CFReadStreamSetProperty(myReadStream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);
	CFOptionFlags myStreamEvents = kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
	CFReadStreamSetClient( myReadStream, myStreamEvents, myReadXMLPackets, &clientContext );
	CFReadStreamScheduleWithRunLoop( myReadStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes );
	bool bOpen = CFReadStreamOpen( myReadStream );
	NSDate *ref = [NSDate date];
	if( bOpen == NO )
	{
		infoPtr->bDoneXMLStream = YES;
		[self performSelectorOnMainThread:@selector(doneXML:) withObject:nil waitUntilDone:NO];
	}

	do {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false);
		if( [[NSDate date] timeIntervalSinceDate:ref] > 25.0 )
		{
			infoPtr->bTimeout = YES;
			infoPtr->bDoneXMLStream = YES;
		}
	} while ( !infoPtr->bDoneXMLStream );

	if( bOpen == YES )
	{
		CFReadStreamUnscheduleFromRunLoop( myReadStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes );
		CFReadStreamSetClient( myReadStream, myStreamEvents, NULL, &clientContext );
		CFReadStreamClose( myReadStream );
		CFRelease( myReadStream );
	}

    [pool release];
	if( infoPtr->bTimeout == YES )
		infoPtr->bDownloading = NO;
	else
		[self performSelectorOnMainThread:@selector(doneXML:) withObject:nil waitUntilDone:NO];
}

@end
