//
//  GADRequestError.h
//  Google Ads iPhone publisher SDK.
//
//  Copyright 2009 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kGADErrorDomain;

// NSError codes for GAD error domain.
typedef enum {
  GAD_NO_ERROR = 0,
  GAD_UNKNOWN_REQUEST_TYPE,
  GAD_ADSENSE_INVALID_COMPANY_APP_NAME_REQUEST_TYPE,
  GAD_ADSENSE_INVALID_APPLICATION_APPLE_ID,
  GAD_DCLK_INVALID_SIZE_PROFILE,
  GAD_DCLK_NO_MATCHING_AD,
  GAD_APPLICATION_INACTIVE,
  GAD_INVALID_REQUEST,
  GAD_ALTERNATE_AD_URL_REQUEST
} GADErrorCode;

// This class represents the error generated due to invalid request parameters.
@interface GADRequestError : NSError

// If the error is a GAD_INVALID_REQUEST, the localizedFailureReason method will
// provide more details about the invalid parameter and description of the
// error.

@end

