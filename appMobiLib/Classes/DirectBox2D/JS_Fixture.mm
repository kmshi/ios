//
//  JS_Fixture.m
//  appLab
//

#import "JS_Fixture.h"
#import "JS_PolygonShape.h"
#import "JS_CircleShape.h"
#import "JS_AABB.h"
#import "JS_Body.h"

@implementation JS_Fixture

@synthesize m_b2Fixture;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2Fixture = (b2Fixture *) internal;
	}
	return self;
}
/*
- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		m_b2Fixture=new b2Fixture();
		m_aabb = [DirectCanvas copyConstructor:ctx forClass:[JS_AABB class] withCopy:&m_b2Fixture->m_aabb shouldDelete:NO];
		m_next = [DirectCanvas copyConstructor:ctx forClass:[JS_Fixture class] withCopy:&m_b2Fixture->m_next shouldDelete:NO];
		m_body = [DirectCanvas copyConstructor:ctx forClass:[JS_Body class] withCopy:&m_b2Fixture->m_body shouldDelete:NO];
		m_shape = [DirectCanvas copyConstructor:ctx forClass:[JS_PolygonShape class] withCopy:&m_b2Fixture->m_shape shouldDelete:NO]; //:TODO - need to check proper shape
		//:TODO - add this after JS_Filter defined m_filter = [DirectCanvas copyConstructor:ctx forClass:[JS_Filter class] withCopy:&m_b2Fixture->m_filter shouldDelete:NO];
	}
	return self;
}
*/
- (void)dealloc {
//	if( shouldDelete == YES ) delete m_b2Fixture;
	[super dealloc];
}

// -- API --

JS_FUNC(JS_Fixture, GetBody, ctx, argc, argv ) {

	b2Body * body = m_b2Fixture->GetBody();
	JSObjectRef obj = [DirectCanvas copyConstructor:ctx forClass:[JS_Body class] withCopy:body shouldDelete:YES];
    
	return obj;	
}

JS_FUNC(JS_Fixture, Log, ctx, argc, argv ) {
	
	NSLog(@"Fixture={}\n");
	return NULL;
}

// -- properties --


@end
