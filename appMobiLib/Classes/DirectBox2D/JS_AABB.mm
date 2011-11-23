//
//  JS_b2AABB.m
//

#import "JS_AABB.h"
#import "JS_Vec2.h"

@implementation JS_AABB

@synthesize m_b2AABB;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2AABB = (b2AABB *) internal;
		m_lowerBound = [DirectCanvas copyConstructor:ctxp forClass:[JS_Vec2 class] withCopy:&m_b2AABB->lowerBound shouldDelete:NO];
		m_upperBound = [DirectCanvas copyConstructor:ctxp forClass:[JS_Vec2 class] withCopy:&m_b2AABB->upperBound shouldDelete:NO];
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {

		m_b2AABB=new b2AABB();		
		m_lowerBound = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:&m_b2AABB->lowerBound shouldDelete:NO];
		m_upperBound = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:&m_b2AABB->upperBound shouldDelete:NO];
	}
	return self;
}

- (void) dealloc {
	
	if( shouldDelete == YES ) delete m_b2AABB;
	[super dealloc];
}

// -- JS API --

JS_FUNC(JS_AABB, GetCenter, ctx, argc, argv ) {
	
	b2Vec2 center = m_b2AABB->GetCenter();
	b2Vec2 *vec = new b2Vec2(center.x, center.y);
	JSObjectRef obj = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:vec shouldDelete:YES];
    
	return obj;	
}

JS_FUNC(JS_AABB, IsValid, ctx, argc, argv ) {
	
	bool l = m_b2AABB->IsValid();	
	return JSValueMakeBoolean(ctx, l);
}

JS_FUNC(JS_AABB, Log, ctx, argc, argv ) {
	
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(m_lowerBound);
	JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(m_upperBound);

	NSLog(@"AABB={lB:%f, %f uB: %f, %f}\n", vec.m_b2Vec2->x, vec.m_b2Vec2->y, vec2.m_b2Vec2->x, vec2.m_b2Vec2->y);
	return NULL;
}

// -- properties --

JS_GET(JS_AABB, lowerBound, ctx) {
	return m_lowerBound;
}

JS_GET(JS_AABB, upperBound, ctx) {
	return m_upperBound;
}

JS_SET(JS_AABB, lowerBound, ctx, value) {
	
	JSObjectRef obj = JSValueToObject(ctx, value, NULL);	
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
	JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(m_lowerBound);
	*vec2.m_b2Vec2 = *vec.m_b2Vec2;
}

JS_SET(JS_AABB, upperBound, ctx, value) {
	
	JSObjectRef obj = JSValueToObject(ctx, value, NULL);	
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
	JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(m_upperBound);
	*vec2.m_b2Vec2 = *vec.m_b2Vec2;	
}

@end
