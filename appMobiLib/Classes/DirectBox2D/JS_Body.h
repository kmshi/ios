//
//  JS_Body.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"


@interface JS_Body : JS_BaseClass {

	b2Body * m_b2Body;
    b2Vec2 * m_b2pos;
    JSObjectRef m_position;
    JSObjectRef m_userData;
}

@property (readonly) b2Body * m_b2Body;

@end
