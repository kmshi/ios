//
//  AppMobiAudio.h
//  AppMobiLib
//

#import <Foundation/Foundation.h>
#import "AppMobiCommand.h"

#import <AVFoundation/AVFoundation.h>

@interface AppMobiAudio : AppMobiCommand <AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
	
	AVAudioPlayer *audioPlayer;
	AVAudioRecorder *audioRecorder;
	NSMutableDictionary* recordingList;
	NSString *recordingsDirectory;
	NSURL *fileURL;
	NSString *recordingFilename;
}

@property (nonatomic, retain) NSMutableDictionary* recordingList;

- (void) startPlaying:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) stopPlaying:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) pausePlaying:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) continuePlaying:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)startRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)stopRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)pauseRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)continueRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void) deleteRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) clearRecordings:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)fireEvent:(NSString *)jsevent withText:(NSString *)text withURL:(NSURL *)url;
- (void)fireEvent:(NSString *)jsevent withText:(NSString *)text;
-(id) initWithWebView:(UIWebView*)theWebView;
- (NSDictionary*) makeRecordingList;

@end
