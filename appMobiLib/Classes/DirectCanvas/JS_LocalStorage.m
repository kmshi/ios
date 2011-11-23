#import "JS_LocalStorage.h"
#import "AppMobiDelegate.h"
#import "AppConfig.h"
#import "AppMobiWebView.h"

@implementation JS_LocalStorage

JS_FUNC( JS_LocalStorage, getItem, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
	
    NSString * key = [NSString stringWithFormat:@"js.%@.", [[AppMobiDelegate sharedDelegate] webView].config.appName]; // add prefix to distinguish from app's own properties
    key = [key stringByAppendingString: JSValueToNSString( ctx, argv[0] )];
	NSString * value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if( !value ) {
		return NULL;
	}
	JSStringRef jsValue = JSStringCreateWithUTF8CString( [value UTF8String] );
	JSValueRef ret = JSValueMakeString( ctx, jsValue );
	JSStringRelease( jsValue );
	return ret;
}

JS_FUNC( JS_LocalStorage, setItem, ctx, argc, argv ) {
	if( argc < 2 ) return NULL;
	
    NSString * key = [NSString stringWithFormat:@"js.%@.", [[AppMobiDelegate sharedDelegate] webView].config.appName]; // add prefix to distinguish from app's own properties
	key = [key stringByAppendingString: JSValueToNSString( ctx, argv[0] )];
	NSString * value = JSValueToNSString( ctx, argv[1] );
	
	if( !key || !value ) return NULL;
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return NULL;
}

JS_FUNC( JS_LocalStorage, removeItem, ctx, argc, argv ) {
	if( argc < 1 ) return NULL;
	
    NSString * key = [NSString stringWithFormat:@"js.%@.", [[AppMobiDelegate sharedDelegate] webView].config.appName]; // add prefix to distinguish from app's own properties
	key = [key stringByAppendingString: JSValueToNSString( ctx, argv[0] )];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return NULL;
}

JS_FUNC( JS_LocalStorage, clear, ctx, argc, argv ) {
    
    NSDictionary * defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSString * prefix = [NSString stringWithFormat:@"js.%@.", [[AppMobiDelegate sharedDelegate] webView].config.appName]; // add prefix to distinguish from app's own properties
    for (NSString *key in defaults)
       if([key hasPrefix:prefix])
           [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];

	[[NSUserDefaults standardUserDefaults] synchronize];
    
	return NULL;
}


@end
