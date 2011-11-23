
#import "XMLNode.h"

@implementation XMLNode

@synthesize nodename = _name;
@synthesize nodeid = _id;
@synthesize nodeurl = _url;
@synthesize nodeurlid = _urlid;
@synthesize nodesid = _sid;
@synthesize nodeplayer = _player;
@synthesize nodeimg = _img;
@synthesize nodedesc = _desc;
@synthesize nodefav = _fav;
@synthesize nodeauthor = _author;
@synthesize nodecolor = _color;
@synthesize nodebcolor = _bcolor;
@synthesize nodeskip = _skip;
@synthesize nodeinfo = _info;
@synthesize nodetype = _type;
@synthesize nodeshout = _shout;
@synthesize nodetitle = _title;
@synthesize nodeadurl = _adurl;
@synthesize nodeicon = _icon;
@synthesize nodeadimg = _adimg;
@synthesize nodeadid = _adid;
@synthesize nodeaddart = _addart;
@synthesize nodeadart = _adart;
@synthesize nodeadpage = _adpage;
@synthesize nodeadheight = _adheight;
@synthesize nodeadwidth = _adwidth;
@synthesize nodepodcast = _podcast;
@synthesize nodeplaylist = _playlist;
@synthesize nodeprerollad = _prerollad;
@synthesize nodeprerollheight = _prerollheight;
@synthesize nodeprerollwidth = _prerollwidth;
@synthesize noderawurl = _rawurl;
@synthesize nodemeta = _meta;
@synthesize noderotator = _rotator;
@synthesize nodeshouturl = _shouturl;
@synthesize nodelocal = _local;
@synthesize nodevalue = _value;
@synthesize nodepid = _pid;
@synthesize nodeguideid = _guideid;
@synthesize nodealign = _align;
@synthesize nodeminback = _minback;
@synthesize nodeduration = _duration;
@synthesize nodepath = _path;
@synthesize nodebanner = _banner;
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
@synthesize nodeheight = _height;
@synthesize nodewidth = _width;
@synthesize nodeexpdays = _expdays;
@synthesize nodeexpplays = _expplays;
@synthesize nodebannerfreq = _bannerfreq;
@synthesize nodeinterfreq = _interfreq;
@synthesize nodeallowdelete = _allowdelete;
@synthesize nodeallowshuffle = _allowshuffle;
@synthesize nodeautohide = _autohide;
@synthesize nodeautoshuffle = _autoshuffle;
@synthesize noderating = _rating;
@synthesize nodeadindex = _adindex;
@synthesize nodeoffline = _offline;
@synthesize nodeisLast = _isLast;
@synthesize nodetimecode = _timecode;
@synthesize nodeisRecording = _isRecording;
@synthesize nodeisFlyBack = _isFlyBack;
@synthesize nodeisJumping = _isJumping;
@synthesize nodeisAudioPodcast = _isAudioPodcast;
@synthesize nodeisVideoPodcast = _isVideoPodcast;
@synthesize tracklist = _tracklist;

- (id)init
{
	self = [super init];
	type = NODE;
	return self;
}

- (void)dealloc
{
	[_name release];
	[_id release];
	[_url release];
	[_urlid release];
	[_sid release];
	[_player release];
	[_img release];
	[_desc release];
	[_fav release];
	[_author release];
	[_color release];
	[_bcolor release];
	[_skip release];
	[_info release];
	[_type release];
	[_shout release];
	[_title release];
	[_adurl release];
	[_adimg release];
	[_adid release];
	[_pid release];
	[_guideid release];
	[_adpage release];
	[_addart release];
	[_adwidth release];
	[_adheight release];
	[_podcast release];
	[_playlist release];
	[_prerollad release];
	[_prerollwidth release];
	[_prerollheight release];
	[_adbannerzone release];
	[_adbannerwidth release];
	[_adbannerheight release];
	[_adbannerfreq release];
	[_adprerollzone release];
	[_adprerollwidth release];
	[_adprerollheight release];
	[_adprerollfreq release];
	[_adpopupzone release];
	[_adpopupwidth release];
	[_adpopupheight release];
	[_adpopupfreq release];
	[_adinterzone release];
	[_adinterwidth release];
	[_adinterheight release];
	[_adinterfreq release];
	[_adsignupzone release];
	[_adsignupwidth release];
	[_adsignupheight release];
	[_adsignupfreq release];		
	[_adart release];
	[super dealloc];
}

@end
