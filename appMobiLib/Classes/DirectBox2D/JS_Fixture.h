//
//  JS_Fixture.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"


@interface JS_Fixture : JS_BaseClass {

	b2Fixture * m_b2Fixture;
	JSObjectRef m_aabb;
	JSObjectRef m_next;
	JSObjectRef m_body;
	JSObjectRef m_shape;
	JSObjectRef m_filter;
}

@property (readonly) b2Fixture * m_b2Fixture;

@end
