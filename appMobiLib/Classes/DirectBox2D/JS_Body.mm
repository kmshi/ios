//
//  JS_Body.m
//

#import "JS_Body.h"
#import "JS_FixtureDef.h"
#import "JS_Fixture.h"
#import "JS_PolygonShape.h"
#import "JS_CircleShape.h"
#import "JS_Vec2.h"

@implementation JS_Body

@synthesize m_b2Body;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
    self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag];
    if( self ) {
        m_b2Body = (b2Body *) internal;
        
        m_b2pos = new b2Vec2(0, 0);
        m_position = [DirectCanvas copyConstructor:ctxp forClass:[JS_Vec2 class] withCopy:m_b2pos shouldDelete:NO];
        JSValueProtect(ctxp, m_position);
        if(m_b2Body->GetUserData()) {
            m_userData = (JSObjectRef) m_b2Body->GetUserData();
            JSValueProtect(ctxp, m_userData);
        }
    }
    return self;
}
- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
    	self = [super initWithContext:ctx object:obj argc:argc argv:argv];
	if( self ) {
		///m_b2Body=new b2Body();
	}
	return self;
}

- (void)dealloc {
//	if( shouldDelete == YES ) delete m_b2Body;
	delete m_b2pos;
	[super dealloc];
}

// -- API --

JS_FUNC(JS_Body, ApplyForce, ctx, argc, argv ) {
	
	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	JS_Vec2 * force= (JS_Vec2 *) JSObjectGetPrivate(obj);
	JSObjectRef obj2 = JSValueToObject(ctx, argv[1], NULL);
	JS_Vec2 * point= (JS_Vec2 *) JSObjectGetPrivate(obj2);
    m_b2Body->ApplyForce(*force.m_b2Vec2, *point.m_b2Vec2);
	
	return NULL;	
}

// pass fixtureDef
JS_FUNC(JS_Body, CreateFixture, ctx, argc, argv ) {
	
	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	JS_FixtureDef * jsfdef= (JS_FixtureDef *) JSObjectGetPrivate(obj);
	b2FixtureDef *fdef = jsfdef.m_b2FixtureDef;
	
	b2Fixture * fix = m_b2Body->CreateFixture(fdef);
	JSObjectRef obj2 = [DirectCanvas copyConstructor:ctx forClass:[JS_Fixture class] withCopy:fix shouldDelete:NO]; //:TODO - check if OK or need to copy fixture
    
	return obj2;	
}

// pass shape
JS_FUNC(JS_Body, CreateFixture2, ctx, argc, argv ) {
	
	float32 density=0;
	if(argc==2)
		density = JSValueToNumber(ctx, argv[1], NULL);
	else if(argc!=1)
		return NULL;

	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	id sh = (id) JSObjectGetPrivate(obj);
	b2Fixture * fix;
	if([sh isMemberOfClass: [JS_PolygonShape class]]) {
		JS_PolygonShape * sh3 = sh;
		fix = m_b2Body->CreateFixture(sh3.m_b2PolygonShape, density);
	}
	if([sh isMemberOfClass: [JS_CircleShape class]]) {
		JS_CircleShape * sh3 = sh;
		fix = m_b2Body->CreateFixture(sh3.m_b2CircleShape, density);
	}
	
	JSObjectRef obj2 = [DirectCanvas copyConstructor:ctx forClass:[JS_Fixture class] withCopy:fix shouldDelete:NO]; //:TODO - check if OK or need to copy fixture
    
	return obj2;
}

JS_FUNC(JS_Body, GetAngle, ctx, argc, argv ) {
	
	float32 angle = m_b2Body->GetAngle();
	return JSValueMakeNumber(ctx, angle);	
}

JS_FUNC(JS_Body, GetRoundedAngle, ctx, argc, argv ) {
    JSValueRef js_x = JSValueToObject(ctx, argv[0], NULL);
    double x = JSValueToNumber(ctx, js_x, NULL);
	
	float32 angle = m_b2Body->GetAngle();
    int places = pow(10,x);
    float32 roundedAngle = round(angle*places)/places;

	return JSValueMakeNumber(ctx, roundedAngle);	
}

JS_FUNC(JS_Body, GetPosition, ctx, argc, argv ) {
    
    b2Vec2 position = m_b2Body->GetPosition();
    m_b2pos->Set(position.x,position.y);
    return m_position;
}

JS_FUNC(JS_Body, Log, ctx, argc, argv ) {
	
	NSLog(@"Body={}\n");
	return NULL;
}

JS_FUNC(JS_Body, SetTransform, ctx, argc, argv ) {
	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	JS_Vec2 * js_position= (JS_Vec2 *) JSObjectGetPrivate(obj);
    b2Vec2 position = *js_position.m_b2Vec2;
	
    JSValueRef js_angle = JSValueToObject(ctx, argv[1], NULL);
    double angle = JSValueToNumber(ctx, js_angle, NULL);
	
	m_b2Body->SetTransform(position, angle);
	return NULL;
}

JS_FUNC(JS_Body, ApplyLinearImpulse, ctx, argc, argv ) {
	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	JS_Vec2 * jsForce= (JS_Vec2 *) JSObjectGetPrivate(obj);
    b2Vec2 force = *jsForce.m_b2Vec2;
	
    JSObjectRef obj2 = JSValueToObject(ctx, argv[1], NULL);
	JS_Vec2 * jsPoint= (JS_Vec2 *) JSObjectGetPrivate(obj2);
    b2Vec2 point = *jsPoint.m_b2Vec2;
	
	m_b2Body->ApplyLinearImpulse(force, point);
	return NULL;
}

JS_FUNC(JS_Body, GetLinearVelocity, ctx, argc, argv) {
	b2Vec2 lv = m_b2Body->GetLinearVelocity();
	b2Vec2 *vec = new b2Vec2(lv.x, lv.y);
	JSObjectRef obj = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:vec shouldDelete:YES];
	return obj;	
}

JS_FUNC(JS_Body, GetAngularVelocity, ctx, argc, argv) {
	float av = m_b2Body->GetAngularVelocity();
	JSValueRef val = JSValueMakeNumber(ctx, av);
	return val;	
}

JS_FUNC(JS_Body, SetAngularVelocity, ctx, argc, argv) {
    JSValueRef js_angle = JSValueToObject(ctx, argv[0], NULL);
    double angle = JSValueToNumber(ctx, js_angle, NULL);
    m_b2Body->SetAngularVelocity(angle);
	return NULL;	
}

JS_FUNC(JS_Body, GetType, ctx, argc, argv) {
    //TO DO: should be b2bodyType
	int type = m_b2Body->GetType();
	JSValueRef val = JSValueMakeNumber(ctx, type);
	return val;	
}

JS_FUNC(JS_Body, SetUserData, ctx, argc, argv ) {
    m_userData = JSValueToObject(ctx, argv[0], NULL);
    m_b2Body->SetUserData(m_userData);
    return NULL;
}

JS_FUNC(JS_Body, GetUserData, ctx, argc, argv ) {
	return m_userData;
}

JS_FUNC(JS_Body, IsAwake, ctx, argc, argv ) {
	return JSValueMakeBoolean(ctx, m_b2Body->IsAwake());
}

// -- properties --

JS_GET(JS_Body, userData, ctx) {
    return m_userData;
}

JS_SET(JS_Body, userData, ctx, value) {
    m_userData = JSValueToObject(ctx, value, NULL);
    m_b2Body->SetUserData(m_userData);
}

@end
