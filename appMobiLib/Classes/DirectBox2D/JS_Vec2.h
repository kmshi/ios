//
//  JS_b2Vec2.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"


@interface JS_Vec2 : JS_BaseClass {

	b2Vec2 * m_b2Vec2;
}

@property (readonly) b2Vec2 * m_b2Vec2;

@end
