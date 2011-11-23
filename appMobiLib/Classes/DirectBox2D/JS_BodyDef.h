//
//  JS_BodyDef.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"


@interface JS_BodyDef : JS_BaseClass {

	b2BodyDef * m_b2BodyDef;
	JSObjectRef m_position;
	JSObjectRef m_linearVelocity;

}

@property (readonly) b2BodyDef * m_b2BodyDef;

@end
