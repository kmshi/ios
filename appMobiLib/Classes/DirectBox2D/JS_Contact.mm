//
//  JS_Contact.m
//

#import "JS_Contact.h"
#import "JS_Fixture.h"

@implementation JS_Contact

@synthesize m_b2Contact;

- (id)initWithCopy:(void *)internal context:(JSContextRef)ctxp object:(JSObjectRef)obj shouldDelete:(BOOL)delflag
{
	if( self = [super initWithCopy:internal context:ctxp object:obj shouldDelete:delflag] ) {
		m_b2Contact = (b2Contact *) internal;
	}
	return self;
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
//		m_b2Contact=new b2Contact();
	}
	return self;
}

- (void)dealloc {
//	if( shouldDelete == YES ) delete m_b2Contact;
	[super dealloc];
}

// -- API --

JS_FUNC(JS_Contact, GetNext, ctx, argc, argv ) {
	
	b2Contact * next = m_b2Contact->GetNext();
	if(next==NULL)
		return JSValueMakeUndefined(ctx);
	JSObjectRef obj = [DirectCanvas copyConstructor:ctx forClass:[JS_Contact class] withCopy:next shouldDelete:YES];
    
	return obj;	
}

JS_FUNC(JS_Contact, GetFixtureA, ctx, argc, argv ) {
	
	b2Fixture * fix = m_b2Contact->GetFixtureA();
	JSObjectRef obj = [DirectCanvas copyConstructor:ctx forClass:[JS_Fixture class] withCopy:fix shouldDelete:YES];
    
	return obj;	
}

JS_FUNC(JS_Contact, GetFixtureB, ctx, argc, argv ) {
	
	b2Fixture * fix = m_b2Contact->GetFixtureB();
	JSObjectRef obj = [DirectCanvas copyConstructor:ctx forClass:[JS_Fixture class] withCopy:fix shouldDelete:YES];
    
	return obj;	
}

JS_FUNC(JS_Contact, Log, ctx, argc, argv ) {
	
	NSLog(@"Contact={}\n");
	return NULL;
}

// -- properties --


@end
