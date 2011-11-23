#import "JS_Button.h"


@implementation JS_Button

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		if( argc < 6 ) return self;
		
		x = JSValueToNumber(ctx, argv[0], NULL);
		y = JSValueToNumber(ctx, argv[1], NULL) + ([DirectCanvas statusBarHidden] ? 0 : 20);
		w = JSValueToNumber(ctx, argv[2], NULL);
		h = JSValueToNumber(ctx, argv[3], NULL);
		
		callbackDown = JSValueToObject(ctx, argv[4], NULL);
		JSValueProtect(ctx, callbackDown);
		
		callbackUp = JSValueToObject(ctx, argv[5], NULL);
		JSValueProtect(ctx, callbackUp);
		
		NSLog(@"Button: bind %f, %f, %f, %f", x, y, w, h);
		
		//button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		//[button setTitle:@"test" forState:UIControlStateNormal];
		
		//UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0,0,100,100)];
		//[button setBackgroundImage:[UIImage imageNamed:@"Default.png"] forState:UIControlStateNormal];
		//button.alpha = 0.2;
		
		button = [UIButton buttonWithType:UIButtonTypeCustom];		
		
		if( [DirectCanvas landscapeMode] ) {
			// We only need to watch for orientation changes in landscape mode
			orientation = UIInterfaceOrientationLandscapeRight;
			UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
			if( UIDeviceOrientationIsLandscape(currentOrientation) ) {
				orientation = currentOrientation;
			}
			[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
			[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(orientationChange:)
				name:@"UIDeviceOrientationDidChangeNotification" object:nil];
		}
		else {
			orientation = UIInterfaceOrientationPortrait;
		}
		
		[self layoutAccordingToOrientation];
		
		
		[button addTarget:self action:@selector(onButtonDown:) forControlEvents:UIControlEventTouchDown];
		[button addTarget:self action:@selector(onButtonUp:) forControlEvents:UIControlEventTouchUpInside];
		[button addTarget:self action:@selector(onButtonUp:) forControlEvents:UIControlEventTouchUpOutside];
		[button addTarget:self action:@selector(onButtonUp:) forControlEvents:UIControlEventTouchCancel];
		[[DirectCanvas instance] addSubview:button];
	}
	return self;
}


- (IBAction)onButtonDown:(UIButton*)button {
	[[DirectCanvas instance] invokeCallback:callbackDown thisObject:NULL argc:0 argv:NULL];
}


- (IBAction)onButtonUp:(UIButton*)button {
	[[DirectCanvas instance] invokeCallback:callbackUp thisObject:NULL argc:0 argv:NULL];
}


- (void)layoutAccordingToOrientation {
//	if( orientation == UIDeviceOrientationLandscapeLeft ) {
//		button.frame = CGRectMake( 320-y-h, x, h, w );
//	}
//	else if( orientation == UIDeviceOrientationLandscapeRight ) {
//		button.frame = CGRectMake( y, 480-x-w, h, w );
//	}
//	else {
		button.frame = CGRectMake( x, y, w, h );
//	}
//	NSLog(@"%@", NSStringFromCGRect(button.frame));
}


- (void)orientationChange:(NSNotification *)notification {	
	UIDeviceOrientation newOrientation = [[UIDevice currentDevice] orientation];
	if( 
		newOrientation != orientation &&
		UIDeviceOrientationIsLandscape(newOrientation) 
	) {
		orientation = newOrientation;
		[self layoutAccordingToOrientation];
	}
}


- (void)dealloc {
	// FIXME: Unprotect callbacks!?
	[button removeFromSuperview];
	[button release];
	[super dealloc];
}


@end
