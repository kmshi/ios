//
//  GADAdSenseAudioParameters.h
//  Google Ads iPhone publisher SDK.
//
//  Copyright 2009 Google Inc. All rights reserved.
//

#import "GADAdSenseParameters.h"

// Audio AdSense ad type
extern NSString* const kGADAdSenseAudioImageAdType;

///////////////////////////////////////////////////////////////////////////////
// AdSense audio ad attributes
///////////////////////////////////////////////////////////////////////////////


// These specify the minimum and maximum duration of the ad (in milliseconds).
extern NSString* const kGADAdSenseMinDuration; // NSNumber
extern NSString* const kGADAdSenseMaxDuration; // NSNumber

// These are used for specifying song title and artist (if known) for audio ads.
extern NSString* const kGADAdSenseAudioTitle;
extern NSString* const kGADAdSenseAudioArtist;

// This is used for additional information about the audio that is playing.
// This is free-form text. For example, it could be "Songs like Peter Gabriel",
// or "Rush Limbaugh Show" or the name of a playlist.
extern NSString* const kGADAdSenseAudioDescription;

// The following key is returned in the dictionary parameter in
// -(void)loadSucceeded:withResults: for audio ads. The associated object
// contains the duration of the ad (in milliseconds).
extern NSString* const kGADAdSenseAdDuration; // NSNumber
