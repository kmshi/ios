#import "AVAudioPlayerSource.h"


@implementation AVAudioPlayerSource

- (id)initWithPath:(NSString *)pathp {
	if( self = [super init] ) {
		path = [pathp retain];
	}
	return self;
}


- (void)load {
	if( player || !path ) return; // already loaded or no path set?
	
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
}


- (void)play {
	[self load];
	[player play];
}


- (void)pause {
	[player pause];
}


- (void)setLooping:(BOOL)loop {
	player.numberOfLoops = loop ? -1 : 0;
}


- (void)setVolume:(float)volume {
	player.volume = volume;
}

- (float)getCurrentTime {
	return player.currentTime;
}

- (void)setCurrentTime:(float)time {
	if( time == 0 ) {
		[player stop];
	}
	else {
		player.currentTime = time;
	}
}


- (void)dealloc {
	[path release];
	[player release];
	
	[super dealloc];
}

@end
