//
//  AppMobiAudio.m
//  AppMobiLib
//

#import "AppMobiAudio.h"
#import "AppMobiDelegate.h"
#import "AppConfig.h"
#import "AppMobiWebView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AppMobiAudio

@synthesize	recordingList;

#pragma mark
#pragma mark Audio playback

// arguments: filename - events: error, interrupt, stop
- (void) startPlaying:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	
	NSString *urlString=nil, *filePath, *filename;
	NSError *error;
	
	if([arguments count] > 0) 
		urlString = [[NSString alloc] initWithString:(NSString *)[arguments objectAtIndex:0]];	
	if( urlString == nil || [urlString length] == 0 ) return;
	
	if(audioPlayer != nil) {
		[self fireEvent:@"appMobi.audio.play.busy" withText:@"Other playback in progress"];
		return;
	}
	
	if( urlString != nil && [urlString length] != 0 ) {
		int loc = [urlString rangeOfString:@"/" options:NSBackwardsSearch].location;
		if(loc != NSNotFound) {
			filename = [urlString substringFromIndex:loc+1];
			filePath = [NSString stringWithFormat:@"%@/%@", recordingsDirectory, filename];
			fileURL=[NSURL fileURLWithPath:filePath];
		}
	}
			

	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
	if (error) {
		[self fireEvent:@"appMobi.audio.play.error" withText:[error localizedDescription]];
		return;
	}
	
	audioPlayer.delegate = self;
	BOOL success = [audioPlayer play];
	if (success == NO) {
		[self fireEvent:@"appMobi.audio.play.error" withText:@"Could not start playing"];
		return;
	}
	[self fireEvent:@"appMobi.audio.play.start" withText:@"Playback Started Successfully!"];
}

- (void) continuePlaying:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	
	if(audioPlayer==nil)
		return;
	
	BOOL success = [audioPlayer play];
	if (success == NO) {
		[self fireEvent:@"appMobi.audio.play.error" withText:@"Could not start playing"];
		return;
	}
	[self fireEvent:@"appMobi.audio.play.start" withText:@"Playback Started Successfully!"];
}

- (void) stopPlaying:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	if(audioPlayer)
		[audioPlayer stop];
	[audioPlayer release];
	audioPlayer = nil;
	[self fireEvent:@"appMobi.audio.play.stop" withText:@"Playing Finished successfully!"];
}

- (void) pausePlaying:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	if(audioPlayer)
		[audioPlayer pause];
	[self fireEvent:@"appMobi.audio.play.pause" withText:@"Playback Paused!"];
}

#pragma mark
#pragma mark Audio recording

// arguments: format, [samplingRate], [channels] - events: error, interrupt, stop
- (void) startRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	
	NSString *filePath, *format=nil, *samplingRate=nil, *channels=nil;
	int formatID=0;
	NSDictionary *recSettings;
	NSError *error;

	if([arguments count] > 0) 
		format = [arguments objectAtIndex:0];
	if( format == nil || [format length] == 0 ) return;
	
	if([arguments count] > 1) 
		samplingRate = [arguments objectAtIndex:1];
	if( samplingRate == nil || [samplingRate length] == 0 ) return;
	
	if([arguments count] > 2)
		channels = [arguments objectAtIndex:2];
	if( channels == nil || [channels length] == 0 ) return;

	if(![format caseInsensitiveCompare:@"ilbc"])
		formatID = 'ilbc';
	else if(![format caseInsensitiveCompare:@"aac"])
		formatID = 'aac ';
	else if(![format caseInsensitiveCompare:@"lpcm"])
		formatID = 'lpcm';
	
	if(audioRecorder != nil) {
		[self fireEvent:@"appMobi.audio.record.busy" withText:@"Other recording in progress"];
		return;
	}
	
	int i=0;
	do {
		filePath = [NSString stringWithFormat:@"%@/recording_%03d.%@", recordingsDirectory, ++i, format];
	} while([[NSFileManager defaultManager] fileExistsAtPath: filePath]);
	
	recordingFilename = [[filePath substringFromIndex:[filePath rangeOfString:@"/" options:NSBackwardsSearch].location+1] retain];
	fileURL = [NSURL fileURLWithPath:filePath];

	recSettings = [NSDictionary dictionaryWithObjectsAndKeys:
				   [NSNumber numberWithInt: formatID], AVFormatIDKey,  // const defined in CoreAudioTypes.h
				   [NSNumber numberWithFloat: [samplingRate intValue]], AVSampleRateKey,
				   [NSNumber numberWithInt: [channels intValue]], AVNumberOfChannelsKey, nil];
	
	audioRecorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:recSettings error:&error]; 
	if (error) {
		[[NSFileManager defaultManager] removeItemAtPath: filePath error:nil];
		[self fireEvent:@"appMobi.audio.record.error" withText:[error localizedDescription]];
		return;
	}
	
	audioRecorder.delegate = self;
	BOOL success = [audioRecorder record];
	if (success == NO) {
		[[NSFileManager defaultManager] removeItemAtPath: filePath error:nil];
		[self fireEvent:@"appMobi.audio.record.error" withText:@"Could not start recording"];
		audioRecorder = nil;
		return;
	}
	[self fireEvent:@"appMobi.audio.record.start" withText:@"Recording Started Successfully!"];
}

- (void) pauseRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

	if(audioRecorder==nil)
		return;
	
	[audioRecorder pause];
	[self fireEvent:@"appMobi.audio.record.pause" withText:@"Recording Paused!"];
}

- (void) continueRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

	if(audioRecorder==nil)
		return;
	
	BOOL success = [audioRecorder record];
	if (success == NO) {
		[self fireEvent:@"appMobi.audio.record.error" withText:@"Could not start recording"];
		return;
	}
	[self fireEvent:@"appMobi.audio.record.start" withText:@"Recording Started Successfully!"];
}

- (void) stopRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	if(audioRecorder)
		[audioRecorder stop];
}

#pragma mark 
#pragma mark file Manipulation methods

- (void) deleteRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	BOOL removed = FALSE;
	NSString *js, *filename=@"none", *filePath=@"none";
	
	NSString *url = [[NSString alloc] initWithString:(NSString *)[arguments objectAtIndex:0]];	
	if( url != nil && [url length] != 0 ) {
		int loc = [url rangeOfString:@"/" options:NSBackwardsSearch].location;
		if(loc != NSNotFound) {
			filename = [url substringFromIndex:loc+1];
			filePath = [NSString stringWithFormat:@"%@/%@", recordingsDirectory, filename];
			removed =[[NSFileManager defaultManager] removeItemAtPath: filePath error:nil];
		}
	}
	
	if(removed) {
		//update the dictionary
		[recordingList removeObjectForKey:filename];
		NSString *audioJar = [NSString stringWithFormat:@"%@.audio", webView.config.appName];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:recordingList forKey:audioJar];
		[defaults synchronize];
		
		//update js object and fire an event
		js = [NSString stringWithFormat:@"var i = 0; while (i < AppMobi.recordinglist.length) { if (AppMobi.recordinglist[i] == '%@') { AppMobi.recordinglist.splice(i, 1); } else { i++; }};", filename];
		AMLog(@"%@", js);
		[webView injectJS:js];
		[self fireEvent:@"appMobi.audio.record.remove" withText:filename];
		
	} else 
		[self fireEvent:@"appMobi.audio.record.error" withText:[NSString stringWithFormat:@"Could not remove recording file %@", filename]];

}

- (void) clearRecordings:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	[[NSFileManager defaultManager] removeItemAtPath:recordingsDirectory error:nil];
	//empty the dictionary
	// do we need to do this to prevent memory leak? [recordingList release]; ?
	recordingList = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
	//create an empty directory
	[[NSFileManager defaultManager] createDirectoryAtPath:recordingsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
	//
	NSString *audioJar = [NSString stringWithFormat:@"%@.audio", webView.config.appName];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:recordingList forKey:audioJar];
	[defaults synchronize];
	
	//update js object and fire an event
	NSString *js = @"AppMobi.recordinglist = new Array();";
	AMLog(@"%@", js);
	[webView injectJS:js];
	[self fireEvent:@"appMobi.audio.record.clear" withText:@"cleared recordings list"];
}


#pragma mark 
#pragma mark AVAudioPlayerDelegate methods

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	
	if(player != audioPlayer)
		return;
	
	if (flag==YES)
		[self fireEvent:@"appMobi.audio.play.stop" withText:@"Playing Finished successfully!" withURL:fileURL];
	else
		[self fireEvent:@"appMobi.audio.play.stop" withText:@"Playing Finished with error!"];
	
	[audioPlayer release];
	audioPlayer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	
	if(player != audioPlayer)
		return;
	
	[self fireEvent:@"appMobi.audio.play.stop" withText:[NSString stringWithFormat:@"Audio player decoding error:%@!", [error localizedDescription]]];
	
	[audioPlayer release];
	audioPlayer = nil;
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	
	if(player != audioPlayer)
		return;
	
	[self fireEvent:@"appMobi.audio.play.pause" withText:@"Playing Paused Due to Interruption!"];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags {
	
	if(player != audioPlayer)
		return;
	
	if(flags & AVAudioSessionInterruptionFlags_ShouldResume)
		[self fireEvent:@"appMobi.audio.play.resume" withText:@"Playing Ready to Resume After Interruption!"];
}

#pragma mark 
#pragma mark AVAudioRecorderDelegate methods

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
	
	if(recorder != audioRecorder)
		return;
	
	if (flag==YES) {
		if([recordingList objectForKey:recordingFilename]==nil) {
			[recordingList setObject:[NSDictionary dictionaryWithObjectsAndKeys: [fileURL absoluteString], @"file", nil] forKey:recordingFilename];
			NSString *audioJar = [NSString stringWithFormat:@"%@.audio", webView.config.appName];
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:recordingList forKey:audioJar];
			[defaults synchronize];
			
			//update js object 
			NSString *js = [NSString stringWithFormat:@"AppMobi.recordinglist.push('%@');", recordingFilename];
			AMLog(@"%@",js);
			[webView injectJS:js];
		}
		[self fireEvent:@"appMobi.audio.record.stop" withText:@"Recording Finished successfully!" withURL:fileURL];
	} else
		[self fireEvent:@"appMobi.audio.record.stop" withText:@"Recording Finished with audio encoding error!"];
	
	[audioRecorder release];
	audioRecorder = nil;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
	
	if(recorder != audioRecorder)
		return;
	
	[self fireEvent:@"appMobi.audio.record.stop" withText:[NSString stringWithFormat:@"Recording caused audio encoding error:%@!", [error localizedDescription]]];
	
	[audioRecorder release];
	audioRecorder = nil;
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
	
	if(recorder != audioRecorder)
		return;
	
	[self fireEvent:@"appMobi.audio.record.pause" withText:@"Recording Paused Due to Interruption!"];
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags {
	
	if(recorder != audioRecorder)
		return;
	
	if(flags & AVAudioSessionInterruptionFlags_ShouldResume)
		[self fireEvent:@"appMobi.audio.record.resume" withText:@"Recording Ready to Resume After Interruption!"];
}


#pragma mark 
#pragma mark private methods 

- (void)fireEvent:(NSString *)jsevent withText:(NSString *)text withURL:(NSURL *)url
{
	NSString *strEvent =  [NSString stringWithFormat:@"var ev = document.createEvent('Events');ev.initEvent('%@',true,true);ev.text='%@';ev.url='%@';document.dispatchEvent(ev);", jsevent, text, url];
	AMLog(@"%@", strEvent);
	[webView stringByEvaluatingJavaScriptFromString:strEvent];
}

- (void)fireEvent:(NSString *)jsevent withText:(NSString *)text
{
	[self fireEvent:jsevent withText:text withURL:nil];
}


-(id) initWithWebView:(AppMobiWebView *)webview
{
	self = (AppMobiAudio *) [super initWithWebView:webview];
	if (!self)
		return self;
	audioPlayer = nil;
	audioRecorder = nil;
	
	// get recordings directory, create if does not exist
	recordingsDirectory = [[webView.config.appDirectory stringByAppendingPathComponent:@"_recordings"] retain];
	if(![[NSFileManager defaultManager] fileExistsAtPath:recordingsDirectory isDirectory:nil])
		[[NSFileManager defaultManager] createDirectoryAtPath:recordingsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	
	return self;
}

// This gets called at startup time, so init stuff happens in here
- (NSDictionary*) makeRecordingList
{
	if( webView.config == nil && recordingsDirectory == nil ) return [NSMutableDictionary dictionaryWithCapacity:1];
	
	NSError *err = nil;
	NSArray *recordingFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:recordingsDirectory error:&err];
	AMLog(@"****recording files****: %@",[recordingFiles description]);
	
	if(recordingList==nil) {
		recordingList = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
		
		NSString *audioJar = [NSString stringWithFormat:@"%@.audio", webView.config.appName];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];		
		if([defaults objectForKey:audioJar]!=nil) {
			[recordingList setDictionary:(NSDictionary *)[defaults objectForKey:audioJar]];
		}
	}
	[self retain];
	return recordingList;
}

- (void)dealloc
{
	[audioRecorder release];
	[audioPlayer release];
	[recordingsDirectory release];
	[recordingList release];
	[recordingFilename release];
	[super dealloc];
}

@end
