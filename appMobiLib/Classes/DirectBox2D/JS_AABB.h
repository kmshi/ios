//
//  JS_AABB.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"

@interface JS_AABB : JS_BaseClass {

	b2AABB * m_b2AABB;
	JSObjectRef m_lowerBound;
	JSObjectRef m_upperBound;
}

@property (readonly) b2AABB * m_b2AABB;

@end
