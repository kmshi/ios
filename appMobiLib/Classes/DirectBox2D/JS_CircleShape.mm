//
//  JS_CircleShape.m
//

#import "JS_CircleShape.h"
#import "JS_Vec2.h"

@implementation JS_CircleShape

@synthesize m_b2CircleShape;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2CircleShape = (b2CircleShape *) internal;
		m_p = [DirectCanvas copyConstructor:ctxp forClass:[JS_Vec2 class] withCopy:&m_b2CircleShape->m_p shouldDelete:NO];
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		m_b2CircleShape=new b2CircleShape();
		m_p = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:&m_b2CircleShape->m_p shouldDelete:NO];
	}
	return self;
}

- (void)dealloc {
	if( shouldDelete == YES ) delete m_b2CircleShape;
	[super dealloc];
}

// -- API --

JS_FUNC(JS_CircleShape, GetType, ctx, argc, argv ) {
	
	int32 l = m_b2CircleShape->GetType();
	
	return JSValueMakeNumber(ctx, l);
}

JS_FUNC(JS_CircleShape, GetRadius, ctx, argc, argv ) {
	
	int32 r = m_b2CircleShape->m_radius;
	return JSValueMakeNumber(ctx, r);
}

JS_FUNC(JS_CircleShape, SetRadius, ctx, argc, argv ) {
	
	float32 r = JSValueToNumber(ctx, argv[0], NULL);
	m_b2CircleShape->m_radius=r;
	return NULL;
}

JS_FUNC(JS_CircleShape, Log, ctx, argc, argv ) {
	
	NSLog(@"CircleShape={}\n");
	return NULL;
}

// -- properties --

JS_GET(JS_CircleShape, m_type, ctx) {
	return JSValueMakeNumber(ctx, m_b2CircleShape->m_type);
}

JS_GET(JS_CircleShape, m_radius, ctx) {
	return JSValueMakeNumber(ctx, m_b2CircleShape->m_radius);
}

JS_GET(JS_CircleShape, m_p, ctx) {
	return m_p;
}

//
JS_SET(JS_CircleShape, m_type, ctx, value) {
	m_b2CircleShape->m_type = (b2Shape::Type) JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_CircleShape, m_radius, ctx, value) {
	m_b2CircleShape->m_radius = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_CircleShape, m_p, ctx, value) {
	JSObjectRef obj = JSValueToObject(ctx, value, NULL);	
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
	JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(m_p);
	*vec2.m_b2Vec2 = *vec.m_b2Vec2;
}

@end
