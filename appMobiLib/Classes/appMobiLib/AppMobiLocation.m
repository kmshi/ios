
#import "AppMobiLocation.h"
#import "AppMobiDelegate.h"
#import "AppMobiViewController.h"
#import "AppMobiWebView.h"

@implementation AppMobiLocation

@synthesize locationManager;

-(id) initWithWebView:(AppMobiWebView *)webview
{
    self = (AppMobiLocation *) [super initWithWebView:webview];
    if (self) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self; // Tells the location manager to send updates to this object
    }
    return self;
}

- (BOOL) hasHeadingSupport
{
	 // check whether headingAvailable property is avail (for 2.x devices)
	if ([self.locationManager respondsToSelector:@selector(headingAvailable)] == NO)
        return NO;

#ifdef __IPHONE_4_0	
	if ([CLLocationManager headingAvailable] == NO)
#else
	if ([self.locationManager headingAvailable] == NO) 
#endif			
		return NO;
	
	return YES;
}

- (void)startLocation:(NSMutableArray*)arguments
     withDict:(NSMutableDictionary*)options
{
    if (__locationStarted == YES)
        return;
#ifdef __IPHONE_4_0	
			if ([CLLocationManager locationServicesEnabled] != YES)
#else
			if ([self.locationManager locationServicesEnabled] != YES)
#endif			
        return;
    
    // Tell the location manager to start notifying us of location updates
    [self.locationManager startUpdatingLocation];
    __locationStarted = YES;

    if ([options objectForKey:@"distanceFilter"]) {
        CLLocationDistance distanceFilter = [(NSString *)[options objectForKey:@"distanceFilter"] doubleValue];
        self.locationManager.distanceFilter = distanceFilter;
    }
    
    if ([options objectForKey:@"desiredAccuracy"]) {
        int desiredAccuracy_num = [(NSString *)[options objectForKey:@"desiredAccuracy"] integerValue];
        CLLocationAccuracy desiredAccuracy = kCLLocationAccuracyBest;
        if (desiredAccuracy_num < 10)
            desiredAccuracy = kCLLocationAccuracyBest;
        else if (desiredAccuracy_num < 100)
            desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        else if (desiredAccuracy_num < 1000)
            desiredAccuracy = kCLLocationAccuracyHundredMeters;
        else if (desiredAccuracy_num < 3000)
            desiredAccuracy = kCLLocationAccuracyKilometer;
        else
            desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        
        self.locationManager.desiredAccuracy = desiredAccuracy;
    }
}

- (void)stopLocation:(NSMutableArray*)arguments
    withDict:(NSMutableDictionary*)options
{
    if (__locationStarted == NO)
        return;
#ifdef __IPHONE_4_0	
		if ([CLLocationManager locationServicesEnabled] != YES)
#else
    if ([self.locationManager locationServicesEnabled] != YES)
#endif			
        return;
    
    [self.locationManager stopUpdatingLocation];
    __locationStarted = NO;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    int epoch = [newLocation.timestamp timeIntervalSince1970];
    float course = -1.0f;
    float speed  = -1.0f;
#ifdef __IPHONE_2_2
    course = newLocation.course;
    speed  = newLocation.speed;
#endif
	NSString* coords =  [NSString stringWithFormat:@"coords: { latitude: %f, longitude: %f, altitude: %f, heading: %f, speed: %f, accuracy: {horizontal: %f, vertical: %f}, altitudeAccuracy: null }",
							newLocation.coordinate.latitude,
							newLocation.coordinate.longitude,
							newLocation.altitude,
							course,
							speed,
							newLocation.horizontalAccuracy,
							newLocation.verticalAccuracy
						 ];
	
    NSString * js = [NSString stringWithFormat:@"AppMobi.geolocation.setLocation({ timestamp: %d, %@ });", epoch, coords];
    //AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void)startHeading:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
#ifdef __IPHONE_3_0
    if (__headingStarted == YES)
        return;
    if ([self hasHeadingSupport] == NO) 
        return;
	
    // Tell the location manager to start notifying us of heading updates
    [self.locationManager startUpdatingHeading];
    __headingStarted = YES;
#endif	
}	

- (void)stopHeading:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
#ifdef __IPHONE_3_0
    if (__headingStarted == NO)
        return;
    if ([self hasHeadingSupport] == NO) 
		return;
    
    [self.locationManager stopUpdatingHeading];
    __headingStarted = NO;
#endif
}	

#ifdef __IPHONE_3_0

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager
	   didUpdateHeading:(CLHeading *)heading
{
	int epoch = [heading.timestamp timeIntervalSince1970];
	
    NSString * js = [NSString stringWithFormat:@"AppMobi.compass.setHeading({ timestamp: %d, magneticHeading: %f, trueHeading: %f, headingAccuracy: %f });", 
					 epoch, heading.magneticHeading, heading.trueHeading, heading.headingAccuracy];
	// AMLog(@"%@", js);
	[webView injectJS:js];
}

#endif

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSString* js = @"";
	
	#ifdef __IPHONE_3_0
	if ([error code] == kCLErrorHeadingFailure) {
		js = [NSString stringWithFormat:@"AppMobi.compass.setError(\"%s\");", [error localizedDescription]];
	} else 
	#endif
	{
		js = [NSString stringWithFormat:@"AppMobi.geolocation.setError(\"%s\");", [error localizedDescription]];
	}
	
    AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void)dealloc {
    [self.locationManager release];
	[super dealloc];
}

@end
