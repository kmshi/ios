
// This is a placeholder to list all the plugins used by the app.  This is needed to enable linking with the plugin library files
// This file needs to be edited manually or as part of the build process.

// import the pluginModule.h files here.  For example uncomment the following line to use a plugin called MyPluginModule: 
// #import "MyPluginModule.h"

@interface Plugins : NSObject {}

@end

@implementation Plugins

- (void) loadPluginsDummy
{
	// List all Plugin Modules here, as in allocating them.  This is just for the Objective C runtime to load the classes.  
	// This method is not called, so no need to dealloc!
	// For example uncomment the following if you have class named MyPluginModule
	
	// [MyPluginModule alloc];
}

@end
