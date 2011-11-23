//
//  JS_FixtureDef.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"


@interface JS_FixtureDef : JS_BaseClass {

	b2FixtureDef * m_b2FixtureDef;
	JSObjectRef m_shape;
}

@property (readonly) b2FixtureDef * m_b2FixtureDef;

@end
