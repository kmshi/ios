
#import "XMLTracklist.h"

@implementation XMLTracklist

@synthesize station = _station;
@synthesize imageurl = _imageurl;
@synthesize livemediaurl = _livemediaurl;
@synthesize stopGuid = _stopGuid;
@synthesize session = _session;
@synthesize banner = _banner;
@synthesize adindex = _adindex;
@synthesize stationid = _stationid;
@synthesize bitrate = _bitrate;
@synthesize startindex = _startindex;
@synthesize autoplay = _autoplay;
@synthesize continuing = _continuing;
@synthesize shuffleable = _shuffleable;
@synthesize deleteable = _deleteable;
@synthesize podcasting = _podcasting;
@synthesize shoutcasting = _shoutcasting;
@synthesize flycasting = _flycasting;
@synthesize flybacking = _flybacking;
@synthesize recording = _recording;
@synthesize offline = _offline;
@synthesize cached = _cached;
@synthesize saved = _saved;
@synthesize live = _live;
@synthesize throwaway = _throwaway;
@synthesize shuffled = _shuffled;
@synthesize autohide = _autohide;
@synthesize autoshuffle = _autoshuffle;
@synthesize users = _users;
@synthesize video = _video;
@synthesize expdays = _expdays;
@synthesize expplays = _expplays;
@synthesize bannerfreq = _bannerfreq;
@synthesize interfreq = _interfreq;
@synthesize original = _original;
@synthesize albumfile = _albumfile;
@synthesize basealbum = _basealbum;
@synthesize adbannerzone = _adbannerzone;
@synthesize adbannerwidth = _adbannerwidth; 
@synthesize adbannerheight = _adbannerheight;
@synthesize adbannerfreq = _adbannerfreq;
@synthesize adprerollzone = _adprerollzone; 
@synthesize adprerollwidth = _adprerollwidth;
@synthesize adprerollheight = _adprerollheight; 
@synthesize adprerollfreq = _adprerollfreq; 
@synthesize adpopupzone = _adpopupzone;
@synthesize adpopupwidth = _adpopupwidth;
@synthesize adpopupheight = _adpopupheight; 
@synthesize adpopupfreq = _adpopupfreq;
@synthesize adinterzone = _adinterzone;
@synthesize adinterwidth = _adinterwidth;
@synthesize adinterheight = _adinterheight; 
@synthesize adinterfreq = _adinterfreq;
@synthesize adsignupzone = _adsignupzone;
@synthesize adsignupwidth = _adsignupwidth;
@synthesize adsignupheight = _adsignupheight; 
@synthesize adsignupfreq = _adsignupfreq;
@synthesize timecode = _timecode;

- (id)init
{
	self = [super init];
	type = TRACKLIST;
	return self;
}

- (void)copy:(XMLTracklist *)tracklist
{
	_station      = tracklist.station;
	_imageurl     = tracklist.imageurl;
	_livemediaurl = tracklist.livemediaurl;
	_stopGuid     = tracklist.stopGuid;
	_session      = tracklist.session;
	_stationid    = tracklist.stationid;
	_bitrate      = tracklist.bitrate;
	_startindex   = tracklist.startindex;
	_autoplay     = tracklist.autoplay;
	_continuing   = tracklist.continuing;
	_shuffleable  = tracklist.shuffleable;
	_deleteable   = tracklist.deleteable;
	_podcasting   = tracklist.podcasting;
	_shoutcasting = tracklist.shoutcasting;
	_flycasting   = tracklist.flycasting;
	_flybacking   = tracklist.flybacking;
	_recording    = tracklist.recording;
	_offline      = tracklist.offline;
	_throwaway    = tracklist.throwaway;
	_shuffled     = tracklist.shuffled;
	_autohide     = tracklist.autohide;
	_autoshuffle  = tracklist.autoshuffle;
	_users        = tracklist.users;
	_video        = tracklist.video;
	_expdays      = tracklist.expdays;
	_expplays     = tracklist.expplays;
	_original     = tracklist.original;
	_albumfile    = tracklist.albumfile;
	_basealbum    = tracklist.basealbum;
	_timecode     = tracklist.timecode;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt:_stationid forKey:@"stationid"];
	[coder encodeInt:_startindex forKey:@"startindex"];
	[coder encodeInt:_bitrate forKey:@"bitrate"];
	[coder encodeDouble:_timecode forKey:@"timecode"];
	[coder encodeObject:_station forKey:@"station"];
	[coder encodeBool:_shuffleable forKey:@"shuffleable"];
	[coder encodeBool:_deleteable forKey:@"deleteable"];
	[coder encodeBool:_autoshuffle forKey:@"autoshuffle"];
	[coder encodeBool:_autohide forKey:@"autohide"];
	[coder encodeBool:_video forKey:@"video"];
	[coder encodeBool:_flycasting forKey:@"flycasting"];
	[coder encodeBool:_recording forKey:@"recording"];
	[coder encodeBool:_podcasting forKey:@"podcasting"];
	[coder encodeBool:_shoutcasting forKey:@"shoutcasting"];
	[coder encodeBool:_saved forKey:@"saved"];
	[coder encodeObject:_stopGuid forKey:@"stopguid"];	
	[coder encodeObject:_adbannerzone forKey:@"adbannerzone"];
	[coder encodeObject:_adbannerwidth forKey:@"adbannerwidth"];
	[coder encodeObject:_adbannerheight forKey:@"adbannerheight"];
	[coder encodeObject:_adbannerfreq forKey:@"adbannerfreq"];
	[coder encodeObject:_adprerollzone forKey:@"adprerollzone"];
	[coder encodeObject:_adprerollwidth forKey:@"adprerollwidth"];
	[coder encodeObject:_adprerollheight forKey:@"adprerollheight"];
	[coder encodeObject:_adprerollfreq forKey:@"adprerollfreq"];
	[coder encodeObject:_adpopupzone forKey:@"adpopupzone"];
	[coder encodeObject:_adpopupwidth forKey:@"adpopupwidth"];
	[coder encodeObject:_adpopupheight forKey:@"adpopupheight"];
	[coder encodeObject:_adpopupfreq forKey:@"adpopupfreq"];
	[coder encodeObject:_adinterzone forKey:@"adinterzone"];
	[coder encodeObject:_adinterwidth forKey:@"adinterwidth"];
	[coder encodeObject:_adinterheight forKey:@"adinterheight"];
	[coder encodeObject:_adinterfreq forKey:@"adinterfreq"];
	[coder encodeObject:_adsignupzone forKey:@"adsignupzone"];	
	[coder encodeObject:_adsignupwidth forKey:@"adsignupwidth"];	
	[coder encodeObject:_adsignupheight forKey:@"adsignupheight"];	
	[coder encodeObject:_adsignupfreq forKey:@"adsignupfreq"];	
	[coder encodeObject:_children forKey:@"children"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	type = TRACKLIST;
	_children = nil;

	_stationid  = [coder decodeIntForKey:@"stationid"];
	_startindex  = [coder decodeIntForKey:@"startindex"];
	_bitrate  = [coder decodeIntForKey:@"bitrate"];
	_timecode = [coder decodeDoubleForKey:@"timecode"];
	_station = [[coder decodeObjectForKey:@"station"] retain];
	_shuffleable = [coder decodeBoolForKey:@"shuffleable"];
	_deleteable = [coder decodeBoolForKey:@"deleteable"];
	_autoshuffle = [coder decodeBoolForKey:@"autoshuffle"];
	_autohide = [coder decodeBoolForKey:@"autohide"];
	_video = [coder decodeBoolForKey:@"video"];
	_flycasting = [coder decodeBoolForKey:@"flycasting"];
	_recording = [coder decodeBoolForKey:@"recording"];
	_podcasting = [coder decodeBoolForKey:@"podcasting"];
	_shoutcasting = [coder decodeBoolForKey:@"shoutcasting"];
	_saved = [coder decodeBoolForKey:@"saved"];
	_stopGuid = [[coder decodeObjectForKey:@"stopguid"] retain];	
	_adbannerzone = [[coder decodeObjectForKey:@"adbannerzone"] retain];
	_adbannerwidth = [[coder decodeObjectForKey:@"adbannerwidth"] retain];
	_adbannerheight = [[coder decodeObjectForKey:@"adbannerheight"] retain];
	_adbannerfreq = [[coder decodeObjectForKey:@"adbannerfreq"] retain];
	_adprerollzone = [[coder decodeObjectForKey:@"adprerollzone"] retain];
	_adprerollwidth = [[coder decodeObjectForKey:@"adprerollwidth"] retain];
	_adprerollheight = [[coder decodeObjectForKey:@"adprerollheight"] retain];
	_adprerollfreq = [[coder decodeObjectForKey:@"adprerollfreq"] retain];
	_adpopupzone = [[coder decodeObjectForKey:@"adpopupzone"] retain];
	_adpopupwidth = [[coder decodeObjectForKey:@"adpopupwidth"] retain];
	_adpopupheight = [[coder decodeObjectForKey:@"adpopupheight"] retain];
	_adpopupfreq = [[coder decodeObjectForKey:@"adpopupfreq"] retain];
	_adinterzone = [[coder decodeObjectForKey:@"adinterzone"] retain];
	_adinterwidth = [[coder decodeObjectForKey:@"adinterwidth"] retain];
	_adinterheight = [[coder decodeObjectForKey:@"adinterheight"] retain];
	_adinterfreq = [[coder decodeObjectForKey:@"adinterfreq"] retain];
	_adsignupzone = [[coder decodeObjectForKey:@"adsignupzone"] retain];	
	_adsignupwidth = [[coder decodeObjectForKey:@"adsignupwidth"] retain];	
	_adsignupheight = [[coder decodeObjectForKey:@"adsignupheight"] retain];	
	_adsignupfreq = [[coder decodeObjectForKey:@"adsignupfreq"] retain];	
	_children = [[coder decodeObjectForKey:@"children"] retain];
	_offline = YES;

	return self;
}

@end
