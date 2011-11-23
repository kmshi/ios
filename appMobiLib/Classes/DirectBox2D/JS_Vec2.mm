//
//  JS_b2Vec2.m
//  appLab
//

#import "JS_Vec2.h"

@implementation JS_Vec2

@synthesize m_b2Vec2;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2Vec2 = (b2Vec2 *) internal;
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		if(argc<2) {
			m_b2Vec2=new b2Vec2(0, 0);
		} else {
			float32 x = JSValueToNumber(ctx, argv[0], NULL);
			float32 y = JSValueToNumber(ctx, argv[1], NULL);
			
			m_b2Vec2=new b2Vec2(x,y);
		}
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj x:(float32)x y:(float32) y {
	if( self = [super initWithContext:ctx object:obj argc:2 argv:NULL] ) {			
		m_b2Vec2=new b2Vec2(x,y);
	}		
	return self;
}

- (void)dealloc {
	if( shouldDelete == YES ) delete m_b2Vec2;
	[super dealloc];
}

// -- API --

JS_FUNC(JS_Vec2, SetZero, ctx, argc, argv ) {

	m_b2Vec2->SetZero();
	return NULL;
}

JS_FUNC(JS_Vec2, Set, ctx, argc, argv ) {

	if(argc<2)
		return NULL;
	float32 x = JSValueToNumber(ctx, argv[0], NULL);
	float32 y = JSValueToNumber(ctx, argv[1], NULL);
	
	m_b2Vec2->Set(x, y);
	
	return NULL;
}

JS_FUNC(JS_Vec2, GetNegative, ctx, argc, argv ) {
	
	m_b2Vec2->Set(-m_b2Vec2->x, -m_b2Vec2->y);
	return object;
}

JS_FUNC(JS_Vec2, Add, ctx, argc, argv ) {
	
	if(argc<1)
		return NULL;
	
	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
	b2Vec2 *temp = vec.m_b2Vec2;
	float32 x = temp->x, y = temp->y;
	
	m_b2Vec2->x += x; m_b2Vec2->y += y;
	
	return NULL;
}

JS_FUNC(JS_Vec2, Subtract, ctx, argc, argv ) {
	
	if(argc<1)
		return NULL;
	
	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
	b2Vec2 *temp = vec.m_b2Vec2;
	float32 x = temp->x, y = temp->y;
		
	m_b2Vec2->x -= x; m_b2Vec2->y -= y;
	
	return NULL;
}

JS_FUNC(JS_Vec2, Multiply, ctx, argc, argv ) {
	
	if(argc<1)
		return NULL;
	float32 m = JSValueToNumber(ctx, argv[0], NULL);
	
	m_b2Vec2->x *= m; m_b2Vec2->y *= m;
	
	return NULL;
}

JS_FUNC(JS_Vec2, Length, ctx, argc, argv ) {
	
	float32 l = b2Sqrt(m_b2Vec2->x * m_b2Vec2->x + m_b2Vec2->y * m_b2Vec2->y);
	
	return JSValueMakeNumber(ctx, l);
}

JS_FUNC(JS_Vec2, LengthSquared, ctx, argc, argv ) {
	
	float32 l = m_b2Vec2->x * m_b2Vec2->x + m_b2Vec2->y * m_b2Vec2->y;
	
	return JSValueMakeNumber(ctx, l);
}

JS_FUNC(JS_Vec2, Normalize, ctx, argc, argv ) {
	
	float32 l = m_b2Vec2->Normalize();
		
	return JSValueMakeNumber(ctx, l);
}

JS_FUNC(JS_Vec2, IsValid, ctx, argc, argv ) {
	
	bool l = m_b2Vec2->IsValid();
	
	return JSValueMakeBoolean(ctx, l);
}

JS_FUNC(JS_Vec2, Log, ctx, argc, argv ) {
	
	NSLog(@"Vec2={%f, %f}\n", m_b2Vec2->x, m_b2Vec2->y);
	return NULL;
}

// -- properties --

JS_GET(JS_Vec2, x, ctx) {
	return JSValueMakeNumber(ctx, m_b2Vec2->x);
}

JS_GET(JS_Vec2, y, ctx) {
	return JSValueMakeNumber(ctx, m_b2Vec2->y);
}

JS_SET(JS_Vec2, x, ctx, value) {
	m_b2Vec2->x = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_Vec2, y, ctx, value) {
	m_b2Vec2->y = JSValueToNumber(ctx, value, NULL);
}

@end
