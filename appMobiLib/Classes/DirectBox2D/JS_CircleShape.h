//
//  JS_CircleShape.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"


@interface JS_CircleShape : JS_BaseClass {

	b2CircleShape * m_b2CircleShape;
	JSObjectRef m_p;
}

@property (readonly) b2CircleShape * m_b2CircleShape;

@end
