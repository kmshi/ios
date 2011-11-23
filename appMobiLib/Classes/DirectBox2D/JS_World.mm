//
//  JS_World.mm
//

#import "JS_World.h"
#import "JS_Vec2.h"
#import "JS_BodyDef.h"
#import "JS_Body.h"
#import "JS_ContactListener.h"

@implementation JS_World

@synthesize m_b2World;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2World = (b2World *) internal;
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		if(argc<2) {
			b2Vec2 gravity(0, 0);
			m_b2World=new b2World(gravity, false);
		} else if(argc==3) {	// this is for compatiblity with box2D 2.0- ignore first parameter that's a boundingBox
			JSObjectRef obj = JSValueToObject(ctx, argv[1], NULL);
			JS_Vec2 * pri= (JS_Vec2 *) JSObjectGetPrivate(obj);
			b2Vec2 * gravity = pri.m_b2Vec2;
			bool doSleep = JSValueToNumber(ctx, argv[2], NULL);
			m_b2World=new b2World(*gravity, doSleep);
		} else {			
			JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
			JS_Vec2 * pri= (JS_Vec2 *) JSObjectGetPrivate(obj);
			b2Vec2 * gravity = pri.m_b2Vec2;
			bool doSleep = JSValueToNumber(ctx, argv[1], NULL);
			m_b2World=new b2World(*gravity, doSleep);
		}
	}
	return self;
}

- (void)dealloc {
	if( shouldDelete == YES ) delete m_b2World;
    if(m_jsContactListener!=NULL) JSValueUnprotect([DirectCanvas instance].ctx, m_jsContactListener);
	[super dealloc];
}

// -- API --

JS_FUNC(JS_World, CreateBody, ctx, argc, argv ) {
	if(argc<1) {
	} else {			
		JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);	
		JS_BodyDef * bodyDef = (JS_BodyDef *) JSObjectGetPrivate(obj);
		b2Body *body = m_b2World->CreateBody(bodyDef.m_b2BodyDef);

        JSStringRef userData = JSStringCreateWithUTF8CString("userData");
        JSValueRef userDataValue = JSObjectGetProperty(ctx, obj, userData, NULL);
        JSObjectRef userDataObject = JSValueToObject(ctx, userDataValue, NULL);
        
        if(userDataObject!=nil) {
            body->SetUserData(userDataObject);
        }

	JSObjectRef obj2 = [DirectCanvas copyConstructor:ctx forClass:[JS_Body class] withCopy:body shouldDelete:YES];
        return obj2;	
	}
	
	return NULL;
}

JS_FUNC(JS_World, DestroyBody, ctx, argc, argv ) {
	if(argc<1) {
	} else {			
		JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);	
		JS_Body * body = (JS_Body *) JSObjectGetPrivate(obj);
		m_b2World->DestroyBody(body.m_b2Body);
	}
	
	return NULL;
}

JS_FUNC(JS_World, SetContactListener, ctx, argc, argv ) {
	if(argc<1) {
	} else {			
		JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);	
		JS_ContactListener * cl = (JS_ContactListener *) JSObjectGetPrivate(obj);
        
        if(m_jsContactListener!=NULL) JSValueUnprotect([DirectCanvas instance].ctx, m_jsContactListener);
        
        m_jsContactListener = obj;
        JSValueProtect([DirectCanvas instance].ctx, m_jsContactListener);
		m_b2World->SetContactListener(cl.m_b2ContactListener);
	}
	
	return NULL;
}

JS_FUNC(JS_World, Step, ctx, argc, argv ) {
	if(argc<2) {
		NSLog(@"Warning World Step called without enough args");
	} else {
		float32 timeStep = JSValueToNumber(ctx, argv[0], NULL);
		int32 velocityIterations = JSValueToNumber(ctx, argv[1], NULL);
		int32 positionIterations;
		if(argc==2)
			positionIterations = velocityIterations;
		else
			positionIterations = JSValueToNumber(ctx, argv[2], NULL);
		
		m_b2World->Step(timeStep, velocityIterations, positionIterations);
	}
	
	return NULL;
}

JS_FUNC(JS_World, ClearForces, ctx, argc, argv ) {

	m_b2World->ClearForces();
	return NULL;
}

JS_FUNC(JS_World, Log, ctx, argc, argv ) {
	
	NSLog(@"World={}\n");
	return NULL;
}

// -- properties --

JS_GET(JS_World, e_locked, ctx) { // this is private in b2World C++
	return JSValueMakeNumber(ctx, 2);
}

JS_GET(JS_World, e_newFixture, ctx) { // this is private in b2World C++
	return JSValueMakeNumber(ctx, 1);
}

@end
