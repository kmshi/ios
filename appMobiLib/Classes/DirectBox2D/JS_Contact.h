//
//  JS_Contact.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"


@interface JS_Contact : JS_BaseClass {

	b2Contact * m_b2Contact;
}

@property (readonly) b2Contact * m_b2Contact;

@end
