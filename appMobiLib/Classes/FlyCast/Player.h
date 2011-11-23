
#import <Foundation/Foundation.h>

@class AppDelegate;
@class XMLNode;
@class XMLTrack;
@class XMLTracklist;
@class CachedAd;

@interface Player : NSObject
{
	AppDelegate *myApp;
	NSMutableArray *mirrors;
	NSString *filename;
	CachedAd *_nextAd;
	XMLNode *node;
	XMLTracklist *_tracklist;

	BOOL bPlaying;
	BOOL bStopping;
	BOOL bPaused;
	BOOL bReady;
	BOOL bLinger;
	BOOL bError;
	BOOL bLingering;
	BOOL bLocked;
	BOOL bInter;
	BOOL bMute;
	BOOL bShoutcast;
	BOOL bRecorded;
	BOOL bCalling;
	BOOL bOffline;
	float fVolume;
	void *myInfo;
	NSString *station;
}

@property (nonatomic, retain) XMLNode *node;
@property (nonatomic, retain) XMLTracklist *tracklist;
@property (nonatomic, retain) NSMutableArray *mirrors;
@property (nonatomic) BOOL bPlaying;
@property (nonatomic) BOOL bStopping;
@property (nonatomic) BOOL bPaused;
@property (nonatomic) BOOL bReady;
@property (nonatomic) BOOL bError;
@property (nonatomic) BOOL bLinger;
@property (nonatomic) BOOL bLingering;
@property (nonatomic) BOOL bLocked;
@property (nonatomic) BOOL bInter;
@property (nonatomic) BOOL bMute;
@property (nonatomic) BOOL bOffline;
@property (nonatomic) BOOL bShoutcast;
@property (nonatomic) BOOL bRecorded;
@property (nonatomic) float fVolume;
@property (nonatomic, retain) NSString *station;

//- (id)initWithApp:(AppDelegate *)app;
- (void)parseHeaders:(NSString*)headers;
- (void)parseMetadata:(NSString*)headers;
- (int)parseResponse:(NSString*)headers;
- (void)parsefcResponse:(NSString*)headers;
- (void)parsescResponse:(NSString*)headers;
- (NSString *)getHeaderValue:(NSString *)headers forKey:(NSString *)key;
- (int)getHeaderValueInt:(NSString *)headers forKey:(NSString *)key;

- (void)startStream:(XMLTracklist *)trackList withType:(BOOL)isShoutcast;
- (void)startStream:(NSString *)filename;
- (void)stopStream:(id)sender;
- (void)closereadfile:(XMLTrack *)track;
- (void)closewritefile:(XMLTrack *)track;
- (void)openwritefile:(XMLTrack *)track;
- (void)openreadfile:(XMLTrack *)track;
- (void)addtrack;
- (void)switchtrack:(int)index;
- (void)adjusttrack:(int)time;
- (int)getPlayingIndex;
- (int)getPlayingOffset;
- (void)setIntersitial:(CachedAd *)ad;
- (void)interDone:(id)sender;

- (void)adjustVolume:(double)level;
- (void)toggleMute;
- (void)togglePause;

- (void)pause;
- (void)resume;

#define EVENT_TRACKBUFFERED     11
#define EVENT_TRACKCACHED       22
#define EVENT_TRACKCOVERED      33
#define EVENT_TRACKADDED        44
#define EVENT_TRACKPLAYING      55
#define EVENT_TRACKLISTRECORDED 66
#define EVENT_SCREENUPDATE      77
#define EVENT_TRACKUPDATED      88

@end
