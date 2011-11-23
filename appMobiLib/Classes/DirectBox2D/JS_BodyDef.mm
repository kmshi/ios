//
//  JS_BodyDef.m
//  appLab
//

#import "JS_BodyDef.h"
#import "JS_Vec2.h"

@implementation JS_BodyDef

@synthesize m_b2BodyDef;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2BodyDef = (b2BodyDef *) internal;
		m_position = [DirectCanvas copyConstructor:ctxp forClass:[JS_Vec2 class] withCopy:&m_b2BodyDef->position shouldDelete:NO];
		m_linearVelocity = [DirectCanvas copyConstructor:ctxp forClass:[JS_Vec2 class] withCopy:&m_b2BodyDef->linearVelocity shouldDelete:NO];
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		m_b2BodyDef=new b2BodyDef();
		m_position = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:&m_b2BodyDef->position shouldDelete:NO];
		m_linearVelocity = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:&m_b2BodyDef->linearVelocity shouldDelete:NO];
	}
	return self;
}

- (void)dealloc {
	if( shouldDelete == YES ) delete m_b2BodyDef;
	[super dealloc];
}

// -- API --

JS_FUNC(JS_BodyDef, Log, ctx, argc, argv ) {
	
	NSLog(@"BodyDef={}\n");
	return NULL;
}

// -- properties --

JS_GET(JS_BodyDef, type, ctx) {
	return JSValueMakeNumber(ctx, m_b2BodyDef->type);
}

JS_GET(JS_BodyDef, position, ctx) {
	return m_position;
}

JS_GET(JS_BodyDef, angle, ctx) {
	return JSValueMakeNumber(ctx, m_b2BodyDef->angle);
}

JS_GET(JS_BodyDef, linearVelocity, ctx) {
	return m_linearVelocity;
}

JS_GET(JS_BodyDef, angularVelocity, ctx) {
	return JSValueMakeNumber(ctx, m_b2BodyDef->angularVelocity);
}

JS_GET(JS_BodyDef, linearDamping, ctx) {
	return JSValueMakeNumber(ctx, m_b2BodyDef->linearDamping);
}

JS_GET(JS_BodyDef, angularDamping, ctx) {
	return JSValueMakeNumber(ctx, m_b2BodyDef->angularDamping);
}

JS_GET(JS_BodyDef, allowSleep, ctx) {
	return JSValueMakeBoolean(ctx, m_b2BodyDef->allowSleep);
}

JS_GET(JS_BodyDef, awake, ctx) {
	return JSValueMakeBoolean(ctx, m_b2BodyDef->awake);
}

JS_GET(JS_BodyDef, fixedRotation, ctx) {
	return JSValueMakeBoolean(ctx, m_b2BodyDef->fixedRotation);
}

JS_GET(JS_BodyDef, bullet, ctx) {
	return JSValueMakeBoolean(ctx, m_b2BodyDef->bullet);
}

JS_GET(JS_BodyDef, active, ctx) {
	return JSValueMakeBoolean(ctx, m_b2BodyDef->active);
}

// This is not defined in latest version of box2D
JS_GET(JS_BodyDef, inertiaScale, ctx) {
	return JSValueMakeNumber(ctx, m_b2BodyDef->inertiaScale);
}

JS_SET(JS_BodyDef, type, ctx, value) {
	m_b2BodyDef->type = (b2BodyType) JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_BodyDef, position, ctx, value) {
	
	JSObjectRef obj = JSValueToObject(ctx, value, NULL);	
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
	JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(m_position);
	*vec2.m_b2Vec2 = *vec.m_b2Vec2;
}

JS_SET(JS_BodyDef, angle, ctx, value) {
	m_b2BodyDef->angle = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_BodyDef, linearVelocity, ctx, value) {
	
	JSObjectRef obj = JSValueToObject(ctx, value, NULL);	
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
	JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(m_linearVelocity);
	*vec2.m_b2Vec2 = *vec.m_b2Vec2;
}

JS_SET(JS_BodyDef, angularVelocity, ctx, value) {
	m_b2BodyDef->angularVelocity = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_BodyDef, linearDamping, ctx, value) {
	m_b2BodyDef->linearDamping = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_BodyDef, angularDamping, ctx, value) {
	m_b2BodyDef->angularDamping = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_BodyDef, allowSleep, ctx, value) {
	m_b2BodyDef->allowSleep = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_BodyDef, awake, ctx, value) {
	m_b2BodyDef->awake = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_BodyDef, fixedRotation, ctx, value) {
	m_b2BodyDef->fixedRotation = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_BodyDef, bullet, ctx, value) {
	m_b2BodyDef->bullet = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_BodyDef, active, ctx, value) {
	m_b2BodyDef->active = JSValueToNumber(ctx, value, NULL);
}

// This is not defined in latest version of box2D
JS_SET(JS_BodyDef, inertiaScale, ctx, value) {
	m_b2BodyDef->inertiaScale = JSValueToNumber(ctx, value, NULL);
}


@end
