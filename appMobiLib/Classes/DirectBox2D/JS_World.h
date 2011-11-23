//
//  JS_World.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"


@interface JS_World : JS_BaseClass {

	b2World * m_b2World;
	JSObjectRef m_b2ContactListener;
    JSObjectRef m_jsContactListener;
}

@property (readonly) b2World * m_b2World;

@end
