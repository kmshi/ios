//
//  AppMobiSpeech.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMobiCommand.h"
#import <SpeechKit/SpeechKit.h>

@interface AppMobiSpeech : AppMobiCommand <SKRecognizerDelegate, SKVocalizerDelegate>
{
	SKRecognizer *_recnuance;
	SKVocalizer *_vocnuance;
	
	BOOL bCancelled;
	BOOL bRecording;
	BOOL bBusy;
	
	NSString *voice;
	NSString *language;
	NSString *text;
	SKEndOfSpeechDetection detection;
}

- (void)recognize:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)stopRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)vocalize:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)cancel:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
