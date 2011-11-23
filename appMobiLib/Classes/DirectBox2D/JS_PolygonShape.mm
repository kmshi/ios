//
//  JS_PolygonShape.m
//

#import "JS_PolygonShape.h"
#import "JS_Vec2.h"

@implementation JS_PolygonShape

@synthesize m_b2PolygonShape;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2PolygonShape = (b2PolygonShape *) internal;
		m_centroid = [DirectCanvas copyConstructor:ctxp forClass:[JS_Vec2 class] withCopy:&m_b2PolygonShape->m_centroid shouldDelete:NO];
		for(int i=0; i<b2_maxPolygonVertices; i++) {  // another option is to create these only as needed here and add later
			m_vertices[i] = [DirectCanvas copyConstructor:ctxp forClass:[JS_Vec2 class] withCopy:&m_b2PolygonShape->m_vertices[i] shouldDelete:NO];
			m_normals[i] = [DirectCanvas copyConstructor:ctxp forClass:[JS_Vec2 class] withCopy:&m_b2PolygonShape->m_normals[i] shouldDelete:NO];
		}
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		m_b2PolygonShape=new b2PolygonShape();
		m_centroid = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:&m_b2PolygonShape->m_centroid shouldDelete:NO];
		for(int i=0; i<b2_maxPolygonVertices; i++) {  // another option is to create these only as needed here and add later
			m_vertices[i] = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:&m_b2PolygonShape->m_vertices[i] shouldDelete:NO];
			m_normals[i] = [DirectCanvas copyConstructor:ctx forClass:[JS_Vec2 class] withCopy:&m_b2PolygonShape->m_normals[i] shouldDelete:NO];
		}
	}
	return self;
}

- (void)dealloc {
	if( shouldDelete == YES ) delete m_b2PolygonShape;
	[super dealloc];
}

// -- API --

JS_FUNC(JS_PolygonShape, GetType, ctx, argc, argv ) {
	
	int32 l = m_b2PolygonShape->GetType();
	
	return JSValueMakeNumber(ctx, l);
}

JS_FUNC(JS_PolygonShape, GetRadius, ctx, argc, argv ) {
	
	int32 r = m_b2PolygonShape->m_radius;
	return JSValueMakeNumber(ctx, r);
}

JS_FUNC(JS_PolygonShape, SetAsBox, ctx, argc, argv ) {

	if(argc<2)
		return NULL;
	float32 hx = JSValueToNumber(ctx, argv[0], NULL);
	float32 hy = JSValueToNumber(ctx, argv[1], NULL);
	
	if(argc==2) {
		m_b2PolygonShape->SetAsBox(hx, hy);
	}
	if(argc==4) {
		JSObjectRef obj = JSValueToObject(ctx, argv[2], NULL);
		JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
		b2Vec2 *center = vec.m_b2Vec2;
		float32 angle = JSValueToNumber(ctx, argv[3], NULL);
		m_b2PolygonShape->SetAsBox(hx, hy, *center, angle);
	}
	return NULL;
}

JS_FUNC(JS_PolygonShape, SetAsEdge, ctx, argc, argv ) {
	
	if(argc<2)
		return NULL;
	JSObjectRef obj = JSValueToObject(ctx, argv[0], NULL);
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
	b2Vec2 *v1 = vec.m_b2Vec2;
	JSObjectRef obj2 = JSValueToObject(ctx, argv[1], NULL);
	JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(obj2);
	b2Vec2 *v2 = vec2.m_b2Vec2;
	
	m_b2PolygonShape->SetAsEdge(*v1, *v2);
	return NULL;
}

JS_FUNC(JS_PolygonShape, SetRadius, ctx, argc, argv ) {
	
	float32 r = JSValueToNumber(ctx, argv[0], NULL);
	m_b2PolygonShape->m_radius=r;
	return NULL;
}

JS_FUNC(JS_PolygonShape, Log, ctx, argc, argv ) {
	
	NSLog(@"PolygonShape={}\n");
	return NULL;
}

// -- properties --

JS_GET(JS_PolygonShape, m_type, ctx) {
	return JSValueMakeNumber(ctx, m_b2PolygonShape->m_type);
}

JS_GET(JS_PolygonShape, m_radius, ctx) {
	return JSValueMakeNumber(ctx, m_b2PolygonShape->m_radius);
}

JS_GET(JS_PolygonShape, m_centroid, ctx) {
	return m_centroid;
}

JS_GET(JS_PolygonShape, m_vertices, ctx) {
	JSObjectRef array = JSObjectMakeArray(ctx, m_b2PolygonShape->m_vertexCount, m_vertices, NULL);
	return array;
}

JS_GET(JS_PolygonShape, m_normals, ctx) {
	JSObjectRef array = JSObjectMakeArray(ctx, m_b2PolygonShape->m_vertexCount, m_normals, NULL);
	return array;
}

JS_GET(JS_PolygonShape, m_vertexCount, ctx) {
	return JSValueMakeNumber(ctx, m_b2PolygonShape->m_vertexCount);
}
//
JS_SET(JS_PolygonShape, m_type, ctx, value) {
	m_b2PolygonShape->m_type = (b2Shape::Type) JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_PolygonShape, m_radius, ctx, value) {
	m_b2PolygonShape->m_radius = JSValueToNumber(ctx, value, NULL);
}

JS_SET(JS_PolygonShape, m_centroid, ctx, value) {
	JSObjectRef obj = JSValueToObject(ctx, value, NULL);	
	JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj);
	JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(m_centroid);
	*vec2.m_b2Vec2 = *vec.m_b2Vec2;
}

JS_SET(JS_PolygonShape, m_vertices, ctx, value) {

	JSObjectRef obj = JSValueToObject(ctx, value, NULL);
	int i;
	for(i=0; i<b2_maxPolygonVertices; i++) {
		JSValueRef val = JSObjectGetPropertyAtIndex(ctx, obj, i, NULL);
		if(JSValueIsUndefined(ctx, val))
		   break;
		else {
			JSObjectRef obj2 = JSValueToObject(ctx, val, NULL);
			JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj2);
			JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(m_vertices[i]);
			*vec2.m_b2Vec2 = *vec.m_b2Vec2;
		}
	}
	m_b2PolygonShape->m_vertexCount = i; // native code does not automatically update count when setting vertices, so this is different
}

JS_SET(JS_PolygonShape, m_normals, ctx, value) {
	
	JSObjectRef obj = JSValueToObject(ctx, value, NULL);
	int i;
	for(i=0; i<b2_maxPolygonVertices; i++) {
		JSValueRef val = JSObjectGetPropertyAtIndex(ctx, obj, i, NULL);
		if(JSValueIsUndefined(ctx, val))
			break;
		else {
			JSObjectRef obj2 = JSValueToObject(ctx, val, NULL);
			JS_Vec2 * vec= (JS_Vec2 *) JSObjectGetPrivate(obj2);
			JS_Vec2 * vec2= (JS_Vec2 *) JSObjectGetPrivate(m_normals[i]);
			*vec2.m_b2Vec2 = *vec.m_b2Vec2;
		}
	}
	m_b2PolygonShape->m_vertexCount = i; // native code does not automatically update count when setting normals, so this is different
}

JS_SET(JS_PolygonShape, m_vertexCount, ctx, value) {
	m_b2PolygonShape->m_vertexCount = JSValueToNumber(ctx, value, NULL);
}

@end
