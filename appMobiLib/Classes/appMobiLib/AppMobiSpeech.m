
//
//  AppMobiSpeech.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppMobiSpeech.h"
#import "AppConfig.h"
#import "AppMobiWebView.h"
#import "AppMobiDelegate.h"
#import "TargetConditionals.h"

@implementation AppMobiSpeech

- (id)initWithWebView:(AppMobiWebView *)webview
{
	self = (AppMobiSpeech *) [super initWithWebView:webview];
	
	[[AppMobiDelegate sharedDelegate] initSpeech];
	
	return self;
}

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
	bRecording = NO;
	NSString *suc = (bCancelled == NO)?@"true":@"false";
	NSString *can = (bCancelled == YES)?@"true":@"false";
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.speech.record',true,true);e.success=%@;e.cancelled=%@;document.dispatchEvent(e);", suc, can];
	AMLog(@"%@",js);
	[webView injectJS:js];	
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)recognition
{
	AMLog(@"didFinishWithResults -- %@ -- %@", recognition.results, recognition.scores);
	
    [_recnuance release];
	_recnuance = nil;
	
	NSString *jsResults = @"[";
	for( int i = 0; i < [recognition.results count]; i++ )
	{
		NSString *result = [[recognition.results objectAtIndex:i] stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
		NSString *jsResult = [NSString stringWithFormat:@"{ text:'%@', score:%f }, ", result, [[recognition.scores objectAtIndex:i] floatValue]];
		jsResults = [jsResults stringByAppendingString:jsResult];
	}
	jsResults = [jsResults stringByAppendingString:@"]"];

	NSString *suc = ([recognition.results count] > 0)?@"true":@"false";
	NSString *can = (bCancelled == YES)?@"true":@"false";
	NSString *sug = (recognition.suggestion == nil)?@"":recognition.suggestion;
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.speech.recognize',true,true);e.success=%@;e.results=%@;e.suggestion='%@';e.error='';e.cancelled=%@;document.dispatchEvent(e);", suc, jsResults, sug, can];
	AMLog(@"%@",js);
	[webView injectJS:js];
	bBusy = NO;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
	AMLog(@"didFinishWithError -- %@", error);
	
    [_recnuance release];
	_recnuance = nil;

	NSString *can = (bCancelled == YES)?@"true":@"false";
	NSString *sug = (suggestion == nil)?@"":suggestion;
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.speech.recognize',true,true);e.success=false;e.results=[];e.suggestion='%@';e.error='%@';e.cancelled=%@;document.dispatchEvent(e);", sug, [error localizedDescription], can];
	AMLog(@"%@",js);
	[webView injectJS:js];
	bBusy = NO;
}

- (void)doRecognize:(id)sender
{
	_recnuance = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType detection:detection language:language delegate:self];
}

- (void)recognize:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasSpeech) return;
	
	if( bBusy == YES || _vocnuance != nil || _recnuance != nil )
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.speech.busy',true,true);e.success=false;e.message='busy';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
		return;
	}

	BOOL longPause = [(NSString *)[arguments objectAtIndex:0] boolValue];
	language = [[(NSString *)[arguments objectAtIndex:1] copy] retain];
	
	bRecording = YES;
	bCancelled = NO;
	bBusy = YES;
	detection = (longPause==YES)?SKLongEndOfSpeechDetection:SKShortEndOfSpeechDetection;
	[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(doRecognize:) userInfo:nil repeats:NO];
}

- (void)stopRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasSpeech) return;
	
	if( _recnuance != nil && bRecording == YES )
		[_recnuance stopRecording];
}

- (void)vocalizer:(SKVocalizer *)vocalizer willBeginSpeakingString:(NSString *)text;
{
}

- (void)vocalizer:(SKVocalizer *)vocalizer didFinishSpeakingString:(NSString *)text withError:(NSError *)error;
{
	AMLog(@"didFinishSpeakingString -- %@", error);
	
    [_vocnuance release];
	_vocnuance = nil;
	
	NSString *suc = (error == nil)?@"true":@"false";
	NSString *can = (bCancelled == YES)?@"true":@"false";
	NSString *err = (error == nil)?@"":[error localizedDescription];
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.speech.vocalize',true,true);e.success=%@;e.error='%@';e.cancelled=%@;document.dispatchEvent(e);", suc, err, can];
	AMLog(@"%@",js);
	[webView injectJS:js];
	bBusy = NO;
}

- (void)doVocalize:(id)sender
{
	_vocnuance = [[SKVocalizer alloc] initWithVoice:voice delegate:self];
	//_vocnuance = [[SKVocalizer alloc] initWithLanguage:language delegate:self];
	[_vocnuance speakString:text];
}

- (void)vocalize:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasSpeech) return;
	
	if( bBusy == YES || _vocnuance != nil || _recnuance != nil )
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.speech.busy',true,true);e.success=false;e.message='busy';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
		return;
	}
	
	text = [[(NSString *)[arguments objectAtIndex:0] copy] retain];
	voice = [[(NSString *)[arguments objectAtIndex:1] copy] retain];
	language = [[(NSString *)[arguments objectAtIndex:2] copy] retain];

	bCancelled = NO;
	bBusy = YES;
	[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(doVocalize:) userInfo:nil repeats:NO];
}

- (void)cancel:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasSpeech) return;
	
	if( _vocnuance != nil )
	{
		[_vocnuance cancel];
		bCancelled = YES;
	}

	if( _recnuance != nil )
	{
		[_recnuance cancel];
		bCancelled = YES;
	}
}

- (void) dealloc
{
	[super dealloc];
}

@end
