#import "JS_BaseClass.h"
#import <objc/runtime.h>


void _js_class_finalize(JSObjectRef object) {
	id instance = (id)JSObjectGetPrivate(object);
	[instance release];
}

//debug to find missing props in scripts
JSValueRef _js_class_getter(JSContextRef ctx, JSObjectRef object, JSStringRef propertyNameJS, JSValueRef* exception) {
	//CFStringRef propName = JSStringCopyCFString( kCFAllocatorDefault, propertyNameJS );
	
    //handle props assigned in script
    JSPropertyNameArrayRef props = JSObjectCopyPropertyNames(ctx, object);
    size_t count = JSPropertyNameArrayGetCount(props);
    //loop over property names
    for(int i=0;i<count;i++) {
        JSStringRef name = JSPropertyNameArrayGetNameAtIndex(props,i);
        if(JSStringIsEqual(propertyNameJS, name)) {
            //if there is a match, return NULL to make default behavior happen
            return NULL;
        }
    }
    
    
    //NSLog(@"Missing property requested: %@ from class: %@", propName, @"???");//class_getName([JSO class])
    
    return NULL;
}



@implementation JS_BaseClass


- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
    self  = [super init];
	if( self ) {
		objectCtx = ctxp;
		object = obj;
		shouldDelete = delflag;
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctxp object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
    self  = [super init];
	if( self ) {
		objectCtx = ctxp;
		object = obj;
		shouldDelete = YES;
	}
	return self;
}

- (void)postInit:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
    
}

static void CopyStringToCString(NSString *str, char **cStr) {
	const char *utf8Str = [str UTF8String];
	int len = strlen(utf8Str) + 1;
	*cStr = malloc(len);
	strlcpy(*cStr, utf8Str, len);
}


+ (JSClassRef)getJSClass {	
	NSMutableArray * methods = [[NSMutableArray alloc] init];
	NSMutableArray * properties = [[NSMutableArray alloc] init];
	
	// Gather all class methods that return C callbacks for this class or it's parents
	id base = [JS_BaseClass class];
	for( id sc = [self class]; sc != base && [sc isSubclassOfClass:base]; sc = [sc superclass] ) {
		u_int count;
		Method * methodList = class_copyMethodList(sc, &count);
		for (int i = 0; i < count ; i++) {
			SEL selector = method_getName(methodList[i]);
			NSString * name = NSStringFromSelector(selector);
			
			if( [name hasPrefix:@"_func_"] ) {
				NSString * shortName = [[[name componentsSeparatedByString:@":"] objectAtIndex:0] 
					substringFromIndex:sizeof("_func_")-1];
				[methods addObject:shortName];
			}
			else if( [name hasPrefix:@"_get_"] ) {
				NSString * shortName = [[[name componentsSeparatedByString:@":"] objectAtIndex:0] 
					substringFromIndex:sizeof("_get_")-1];
				[properties addObject:shortName];
			}
		}
		free(methodList);
	}

	// Set up the JSStaticValue struct array
	JSStaticValue * values = malloc( sizeof(JSStaticValue) * (properties.count+1) );
	memset( values, 0, sizeof(JSStaticValue) * (properties.count+1) );
	for( int i = 0; i < properties.count; i++ ) {
		NSString * name = [properties objectAtIndex:i];
		
		CopyStringToCString(name, (char **)&values[i].name); // FIXME: Leaks!?
		values[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL get = NSSelectorFromString([NSString stringWithFormat:@"_callback_for_get_%@", name]);
		values[i].getProperty = (JSObjectGetPropertyCallback)[self performSelector:get];
		
		SEL set = NSSelectorFromString([NSString stringWithFormat:@"_callback_for_set_%@", name]);
		if( [self respondsToSelector:set] ) {
			values[i].setProperty = (JSObjectSetPropertyCallback)[self performSelector:set];
		}
	}
	
	// Set up the JSStaticFunction struct array
	JSStaticFunction * functions = malloc( sizeof(JSStaticFunction) * (methods.count+1) );
	memset( functions, 0, sizeof(JSStaticFunction) * (methods.count+1) );
	for( int i = 0; i < methods.count; i++ ) {
		NSString * name = [methods objectAtIndex:i];
		CopyStringToCString(name, (char **)&functions[i].name); // FIXME: Leaks!?
		functions[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL call = NSSelectorFromString([NSString stringWithFormat:@"_callback_for_func_%@", name]);
		functions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[self performSelector:call];
	}
	
	JSClassDefinition classDef = kJSClassDefinitionEmpty;
	classDef.finalize = _js_class_finalize;
	classDef.staticValues = values;
	classDef.staticFunctions = functions;
    //classDef.getProperty = _js_class_getter;
	JSClassRef class = JSClassCreate(&classDef);
	
	free( values );
	free( functions );
	
	[properties release];
	[methods release];
	
	return class;
}

@end
