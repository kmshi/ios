//
//  JS_ContactListener.m
//

#import "JS_ContactListener.h"
#import "JS_Contact.h"

void b2CListener::BeginContact(b2Contact * contact) {
	
	if(beginFunction == NULL)
		return;
    
    JSContextRef ctx = [DirectCanvas instance].ctx;
	JSObjectRef obj = [DirectCanvas copyConstructor:ctx forClass:[JS_Contact class] withCopy:contact shouldDelete:YES];
    JSValueRef args[1];
    args[0] = obj;
	JSObjectCallAsFunction(ctx, beginFunction, NULL, 1, args, NULL);
};

@implementation JS_ContactListener

@synthesize m_b2ContactListener;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2ContactListener = (b2CListener *) internal;
        m_b2ContactListener->beginFunction = NULL;
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		m_b2ContactListener=new b2CListener();
        m_b2ContactListener->beginFunction = NULL;
	}
	return self;
}

- (void)dealloc {
    if(m_b2ContactListener->beginFunction!=NULL) {
        JSValueUnprotect([DirectCanvas instance].ctx, m_b2ContactListener->beginFunction);
    }
	if( shouldDelete == YES ) delete m_b2ContactListener;
	[super dealloc];
}

// -- API --

JS_FUNC(JS_ContactListener, Log, ctx, argc, argv ) {
	
	NSLog(@"ContactListener={}\n");
	return NULL;
}

// -- properties --

JS_GET(JS_ContactListener, BeginContact, ctx) {
	return m_b2ContactListener->beginFunction;
}

JS_SET(JS_ContactListener, BeginContact, ctx, value) {
	
	if(!JSValueIsObject(ctx, value))
		return;
	JSObjectRef obj = JSValueToObject(ctx, value, NULL);
	if(!JSObjectIsFunction(ctx, obj)) {
		return;
    } 
    if(m_b2ContactListener->beginFunction!=NULL) {
        JSValueUnprotect([DirectCanvas instance].ctx, m_b2ContactListener->beginFunction);
    }
	m_b2ContactListener->beginFunction = obj;
    JSValueProtect([DirectCanvas instance].ctx, m_b2ContactListener->beginFunction);
}

@end
