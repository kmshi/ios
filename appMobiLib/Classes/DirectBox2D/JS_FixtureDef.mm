//
//  JS_FixtureDef.m
//  appLab
//

#import "JS_FixtureDef.h"
#import "JS_PolygonShape.h"
#import "JS_CircleShape.h"

@implementation JS_FixtureDef

@synthesize m_b2FixtureDef;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2FixtureDef = (b2FixtureDef *) internal;
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		m_b2FixtureDef=new b2FixtureDef();
		// shape initially set to polygon, can change in set if needed
		m_shape = [DirectCanvas copyConstructor:ctx forClass:[JS_PolygonShape class] withCopy:&m_b2FixtureDef->shape shouldDelete:NO];
	}
	return self;
}

- (void)dealloc {
	if( shouldDelete == YES ) delete m_b2FixtureDef;
	[super dealloc];
}

// -- API --

JS_FUNC(JS_FixtureDef, Log, ctx, argc, argv ) {
	
	NSLog(@"FixtureDef={}\n");
	return NULL;
}

// -- properties --

JS_GET(JS_FixtureDef, shape, ctx) {
	return m_shape;
}

JS_GET(JS_FixtureDef, friction, ctx) {
	return JSValueMakeNumber(ctx, m_b2FixtureDef->friction);
}

JS_GET(JS_FixtureDef, density, ctx) {
	return JSValueMakeNumber(ctx, m_b2FixtureDef->density);
}

JS_GET(JS_FixtureDef, restitution, ctx) {
	return JSValueMakeNumber(ctx, m_b2FixtureDef->restitution);
}

//

JS_SET(JS_FixtureDef, shape, ctx, value) {
	
	JSObjectRef obj = JSValueToObject(ctx, value, NULL);	
	id sh = (id) JSObjectGetPrivate(obj);
	if([sh isMemberOfClass: [JS_PolygonShape class]]) {
		id shTemp = (id) JSObjectGetPrivate(m_shape);
		if(![shTemp isMemberOfClass: [JS_PolygonShape class]]) {
			m_shape = [DirectCanvas copyConstructor:ctx forClass:[JS_PolygonShape class] withCopy:&m_b2FixtureDef->shape shouldDelete:NO];
		}
//		JS_PolygonShape * sh2= (JS_PolygonShape *) JSObjectGetPrivate(m_shape);
		JS_PolygonShape * sh3 = sh;
		m_b2FixtureDef->shape = (b2PolygonShape*) sh3.m_b2PolygonShape; // set shape with actual type
//		*sh2.m_b2PolygonShape = *sh3.m_b2PolygonShape;
	}
	if([sh isMemberOfClass: [JS_CircleShape class]]) {
		id shTemp = (id) JSObjectGetPrivate(m_shape);
		if(![shTemp isMemberOfClass: [JS_CircleShape class]]) {
			m_shape = [DirectCanvas copyConstructor:ctx forClass:[JS_CircleShape class] withCopy:&m_b2FixtureDef->shape shouldDelete:NO];
		}
//		JS_CircleShape * sh2= (JS_CircleShape *) JSObjectGetPrivate(m_shape);
		JS_CircleShape * sh3 = sh;
		m_b2FixtureDef->shape = (b2CircleShape*) sh3.m_b2CircleShape; // set shape with actual type
//		*sh2.m_b2CircleShape = *sh3.m_b2CircleShape;
	}
}

JS_SET(JS_FixtureDef, friction, ctx, value) {
	m_b2FixtureDef->friction = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_FixtureDef, density, ctx, value) {
	m_b2FixtureDef->density = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_FixtureDef, restitution, ctx, value) {
	m_b2FixtureDef->restitution = JSValueToNumber(ctx, value, NULL);
}

@end
