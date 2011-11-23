//
//  JS_PolygonShape.h
//

#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#include "Box2D.h"


@interface JS_PolygonShape : JS_BaseClass {

	b2PolygonShape * m_b2PolygonShape;
	JSObjectRef m_centroid;
	JSObjectRef m_vertices[b2_maxPolygonVertices];
	JSObjectRef m_normals[b2_maxPolygonVertices];
}

@property (readonly) b2PolygonShape * m_b2PolygonShape;

@end
