
#import "PhoneGapModule.h"
#import "AppMobiWebView.h"
#import "JSON.h"

#import "Accelerometer.h"
#import "Camera.h"
#import "Capture.h"
#import "Connection.h"
#import "Contacts.h"
#import "DebugConsole.h"
#import "Device.h"
#import "File.h"
#import "FileTransfer.h"
#import "Location.h"
#import "Notification.h"
#import "PGSplashScreen.h"
#import "Sound.h"

PGAccelerometer *myaccelerometer = nil;
PGCamera *mycamera = nil;
PGCapture *mycapture = nil;
PGContacts *mycontacts = nil;
PGConnection *myconnection = nil;
PGDebugConsole *mydebug = nil;
PGDevice *mydevice = nil;
PGFile *myfile = nil;
PGFileTransfer *myfiletransfer = nil;
PGLocation *mylocation = nil;
PGNotification *mynotification = nil;
PGSound *mysound = nil;
PGSplashScreen *mysplashscreen = nil;

@implementation PhoneGapModule

- (void)setup:(AppMobiWebView *)webview
{
	myaccelerometer = (PGAccelerometer *) [[PGAccelerometer alloc] initWithWebView:webview];
	mycamera = (PGCamera *) [[PGCamera alloc] initWithWebView:webview];
	mycapture = (PGCapture *) [[PGCapture alloc] initWithWebView:webview];
	myconnection = (PGConnection *) [[PGConnection alloc] initWithWebView:webview];
	mycontacts = (PGContacts *) [[PGContacts alloc] initWithWebView:webview];
	mydebug = (PGDebugConsole *) [[PGDebugConsole alloc] initWithWebView:webview];
	mydevice = (PGDevice *) [[PGDevice alloc] initWithWebView:webview];
	myfile = (PGFile *) [[PGFile alloc] initWithWebView:webview];
	myfiletransfer = (PGFileTransfer *) [[PGFileTransfer alloc] initWithWebView:webview];
	mylocation = (PGLocation *) [[PGLocation alloc] initWithWebView:webview];
	mynotification = (PGNotification *) [[PGNotification alloc] initWithWebView:webview];
	mysound = (PGSound *) [[PGSound alloc] initWithWebView:webview];
	mysplashscreen = (PGSplashScreen *) [[PGSplashScreen alloc] initWithWebView:webview];
		
	[webview registerCommand:myaccelerometer forName:@"com.phonegap.accelerometer"];
	[webview registerCommand:mycamera forName:@"com.phonegap.camera"];
	[webview registerCommand:mycapture forName:@"com.phonegap.mediacapture"];
	[webview registerCommand:myconnection forName:@"com.phonegap.connection"];
	[webview registerCommand:mycontacts forName:@"com.phonegap.contacts"];
	[webview registerCommand:mydebug forName:@"com.phonegap.debugconsole"];
	[webview registerCommand:mydevice forName:@"com.phonegap.device"];
	[webview registerCommand:myfile forName:@"com.phonegap.file"];
	[webview registerCommand:myfiletransfer forName:@"com.phonegap.filetransfer"];
	[webview registerCommand:mylocation forName:@"com.phonegap.geolocation"];
	[webview registerCommand:mynotification forName:@"com.phonegap.notification"];
	[webview registerCommand:mysound forName:@"com.phonegap.media"];
	[webview registerCommand:mysplashscreen forName:@"com.phonegap.splashscreen"];
}

- (void)initialize:(AppMobiWebView *)webview
{
	PGDevice *device = [[PGDevice alloc] init];
	
	NSDictionary *deviceProperties = [device deviceProperties];
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"DeviceInfo = %@;", [deviceProperties JSONFragment]];

	[webview stringByEvaluatingJavaScriptFromString:[result stringByAppendingString:@"PhoneGapLoaded();"]];
}

@end
