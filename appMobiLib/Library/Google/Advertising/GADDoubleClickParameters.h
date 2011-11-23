//
//  GADDoubleClickParameters.h
//  Google Ads iPhone publisher SDK.
//
//  Copyright 2009 Google Inc. All rights reserved.
//

///////////////////////////////////////////////////////////////////////////////
// DoubleClick ad attributes
///////////////////////////////////////////////////////////////////////////////

// Keyname (required). Example site/zone;kw=keyword;key=value;sz=300x50
extern NSString* const kGADDoubleClickKeyname;

// Size profile. 'xl' - extra large. 'l' - large. 'm' - medium. 's' - small.
// 't' - text. Defaults to 'xl'.
extern NSString* const kGADDoubleClickSizeProfile;

// Background color (used if the ad creative is smaller than the GADAdSize).
// Defaults to FFFFFF.
extern NSString* const kGADDoubleClickBackgroundColor;

// Keyword for AdSense requests via DoubleClick for Publishers (DFP).
extern NSString* const kGADDoubleClickAdSenseKeyword;
