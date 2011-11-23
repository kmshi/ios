
#import "XMLTrack.h"

@implementation XMLTrack

@synthesize artist = _artist;
@synthesize title = _title;
@synthesize album = _album;
@synthesize metadata = _metadata;
@synthesize imageurl = _imageurl;
@synthesize mediaurl = _mediaurl;
@synthesize redirect = _redirect;
@synthesize mediatype = _mediatype;
@synthesize starttime = _starttime;
@synthesize guidIndex = _guidIndex;
@synthesize guidSong = _guidSong;
@synthesize adurl = _adurl;
@synthesize addart = _addart;
@synthesize timecode = _timecode;
@synthesize offset = _offset;
@synthesize length = _length;
@synthesize current = _current;
@synthesize readoff = _readoff;
@synthesize begin = _begin;
@synthesize start = _start;
@synthesize syncoff = _syncoff;
@synthesize metaint = _metaint;
@synthesize bitrate = _bitrate;
@synthesize seconds = _seconds;
@synthesize stationid = _stationid;
@synthesize expdays = _expdays;
@synthesize expplays = _expplays;
@synthesize numplay = _numplay;
@synthesize woffset = _woffset;
@synthesize roffset = _roffset;
@synthesize clickAd = _clickAd;
@synthesize audioAd = _audioAd;
@synthesize reloadAd = _reloadAd;
@synthesize buffered = _buffered;
@synthesize cached = _cached;
@synthesize covered = _covered;
@synthesize playing = _playing;
@synthesize flyback = _flyback;
@synthesize flylive = _flylive;
@synthesize delayed = _delayed;
@synthesize finished = _finished;
@synthesize listened = _listened;
@synthesize played = _played;
@synthesize flush = _flush;
@synthesize notfound = _notfound;
@synthesize redirecting = _redirecting;
@synthesize terminating = _terminating;
@synthesize redirected = _redirected;
@synthesize unsupported = _unsupported;
@synthesize synced = _synced;
@synthesize resuming = _resuming;
@synthesize original = _original;
@synthesize albumfile = _albumfile;
@synthesize filename = _filename;
@synthesize basealbum = _basealbum;
@synthesize basefile = _basefile;
@synthesize rmediafile = _rmediafile;
@synthesize wmediafile = _wmediafile;

- (id)init
{
	self = [super init];
	type = TRACK;
	return self;
}

- (void)copy:(XMLTrack *)track
{
	_artist      = track.artist;
	_title       = track.title;
	_album       = track.album;
	_metadata    = track.metadata;
	_imageurl    = track.imageurl;
	_mediaurl    = track.mediaurl;
	_redirect    = track.redirect;
	_mediatype   = track.mediatype;
	_starttime   = track.starttime;
	_guidIndex   = track.guidIndex;
	_guidSong    = track.guidSong;
	_adurl       = track.adurl;
	_addart      = track.addart;
	_timecode    = track.timecode;
	_offset      = track.offset;
	_length      = track.length;
	_current     = track.current;
	_start       = track.start;
	_bitrate     = track.bitrate;
	_seconds     = track.seconds;
	_stationid   = track.stationid;
	_expdays     = track.expdays;
	_expplays    = track.expplays;
	_numplay     = track.numplay;
	_woffset     = track.woffset;
	_roffset     = track.roffset;
	_clickAd     = track.clickAd;
	_audioAd     = track.audioAd;
	_reloadAd    = track.reloadAd;
	_buffered    = track.buffered;
	_cached      = track.cached;
	_covered     = track.covered;
	_playing     = track.playing;
	_flyback     = track.flyback;
	_flylive     = track.flylive;
	_delayed     = track.delayed;
	_finished    = track.finished;
	_listened    = track.listened;
	_played      = track.played;
	_flush       = track.flush;
	_redirecting = track.redirecting;
	_terminating = track.terminating;
	_redirected  = track.redirected;
	_unsupported = track.unsupported;
	_original    = track.original;
	_albumfile   = track.albumfile;
	_filename    = track.filename;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_artist forKey:@"artist"];
	[coder encodeObject:_title forKey:@"title"];
	[coder encodeObject:_album forKey:@"album"];
	[coder encodeObject:_metadata forKey:@"metadata"];
	[coder encodeObject:_imageurl forKey:@"imageurl"];
	[coder encodeObject:_mediaurl forKey:@"mediaurl"];
	[coder encodeObject:_redirect forKey:@"redirect"];
	[coder encodeObject:_mediatype forKey:@"mediatype"];
	[coder encodeObject:_starttime forKey:@"starttime"];
	[coder encodeObject:_guidIndex forKey:@"guidindex"];
	[coder encodeObject:_guidSong forKey:@"guidsong"];
	[coder encodeDouble:_timecode forKey:@"timecode"];
	[coder encodeInt:_offset forKey:@"offset"];
	[coder encodeInt:_length forKey:@"length"];
	[coder encodeInt:_current forKey:@"current"];
	[coder encodeInt:_start forKey:@"start"];
	[coder encodeInt:_bitrate forKey:@"bitrate"];
	[coder encodeInt:_seconds forKey:@"seconds"];
	[coder encodeInt:_stationid forKey:@"stationid"];
	[coder encodeBool:_buffered forKey:@"buffered"];
	[coder encodeBool:_cached forKey:@"cached"];
	[coder encodeBool:_covered forKey:@"covered"];
	[coder encodeBool:_flyback forKey:@"flyback"];
	[coder encodeBool:_delayed forKey:@"delayed"];
	[coder encodeBool:_listened forKey:@"listened"];
	[coder encodeBool:_played forKey:@"played"];
	[coder encodeInt:_expdays forKey:@"expdays"];
	[coder encodeInt:_expplays forKey:@"expplays"];
	[coder encodeInt:_numplay forKey:@"numplay"];
	[coder encodeInt:_woffset forKey:@"woffset"];
	[coder encodeInt:_roffset forKey:@"roffset"];
	[coder encodeBool:_clickAd forKey:@"clickAd"];
	[coder encodeBool:_audioAd forKey:@"audioAd"];
	[coder encodeBool:_reloadAd forKey:@"reloadAd"];
	[coder encodeObject:_addart forKey:@"addart"];
	[coder encodeObject:_adurl forKey:@"adurl"];
	[coder encodeBool:_synced forKey:@"synced"]; 
	[coder encodeInt:_syncoff forKey:@"syncoff"];
	[coder encodeInt:_resuming forKey:@"resuming"];
	[coder encodeObject:_basealbum forKey:@"basealbum"];
	[coder encodeObject:_basefile forKey:@"basefile"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	type = TRACK;
	_children = nil;

	_artist = [[coder decodeObjectForKey:@"artist"] retain];
	_title = [[coder decodeObjectForKey:@"title"] retain];
	_album = [[coder decodeObjectForKey:@"album"] retain];
	_metadata = [[coder decodeObjectForKey:@"metadata"] retain];
	_imageurl = [[coder decodeObjectForKey:@"imageurl"] retain];
	_mediaurl = [[coder decodeObjectForKey:@"mediaurl"] retain];
	_redirect = [[coder decodeObjectForKey:@"redirect"] retain];
	_mediatype = [[coder decodeObjectForKey:@"mediatype"] retain];
	_starttime = [[coder decodeObjectForKey:@"starttime"] retain];
	_guidIndex = [[coder decodeObjectForKey:@"guidindex"] retain];
	_guidSong = [[coder decodeObjectForKey:@"guidsong"] retain];
	_timecode = [coder decodeDoubleForKey:@"timecode"];
	_offset = [coder decodeIntForKey:@"offset"];
	_length = [coder decodeIntForKey:@"length"];
	_current = [coder decodeIntForKey:@"current"];
	_start = [coder decodeIntForKey:@"start"];
	_bitrate = [coder decodeIntForKey:@"bitrate"];
	_seconds = [coder decodeIntForKey:@"seconds"];
	_stationid = [coder decodeIntForKey:@"stationid"];
	_buffered = [coder decodeBoolForKey:@"buffered"];
	_cached = [coder decodeBoolForKey:@"cached"];
	_covered = [coder decodeBoolForKey:@"covered"];
	_flyback = [coder decodeBoolForKey:@"flyback"];
	_delayed = [coder decodeBoolForKey:@"delayed"];
	_listened = [coder decodeBoolForKey:@"listened"];
	_played = [coder decodeBoolForKey:@"played"];
	_expdays = [coder decodeIntForKey:@"expdays"];
	_expplays = [coder decodeIntForKey:@"expplays"];
	_numplay = [coder decodeIntForKey:@"numplay"];
	_woffset = [coder decodeIntForKey:@"woffset"];
	_roffset = [coder decodeIntForKey:@"roffset"];
	_clickAd = [coder decodeBoolForKey:@"clickAd"];
	_audioAd = [coder decodeBoolForKey:@"audioAd"];
	_reloadAd = [coder decodeBoolForKey:@"reloadAd"];
	_addart = [[coder decodeObjectForKey:@"addart"] retain];
	_adurl = [[coder decodeObjectForKey:@"adurl"] retain];
	_synced = [coder decodeBoolForKey:@"synced"]; 
	_syncoff = [coder decodeIntForKey:@"syncoff"];
	_resuming = [coder decodeIntForKey:@"resuming"];
	_basealbum = [[coder decodeObjectForKey:@"basealbum"] retain];
	_basefile = [[coder decodeObjectForKey:@"basefile"] retain];

	return self;
}

@end
