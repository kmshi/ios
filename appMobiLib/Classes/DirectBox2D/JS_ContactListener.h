//
//  JS_ContactListener.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"

class b2CListener : public b2ContactListener {
	void BeginContact(b2Contact * contact);
public:    
    JSObjectRef beginFunction;
};

@interface JS_ContactListener : JS_BaseClass {

	b2CListener * m_b2ContactListener;
}

@property (readonly) b2CListener * m_b2ContactListener;

@end
