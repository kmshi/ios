//
//  Canvaspath.h
//  appLab
//
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture.h"

@interface CanvasPath : NSObject {

	GLubyte * pixels;
	Texture * texture;		// used for drawing Path API objects
	CGContextRef context;
	int m_width, m_height, realWidth, realHeight; 
	CGAffineTransform m_transform;
    void * cg;
}

-(void) beginPath;
-(void) closePath;
-(void) moveTo:(float) x y:(float) y;
-(void) lineTo:(float) x y:(float) y;
-(void) quadraticCurveTo:(float) cpx cpy:(float) cpy x:(float) x y:(float) y;
-(void) bezierCurveTo:(float) cp1x cp1y:(float) cp1y cp2x:(float) cp2x cp2y:(float) cp2y x:(float) x y:(float) y;
-(void) arcTo:(float) x0 y0:(float) y0 x1:(float) x1 y1:(float) y1 r:(float) r exceptionCode:(int*) ec;
-(void) arc:(float)x y:(float)y r:(float)r sa:(float)sa ea:(float)ea acl:(int) anticlockwise exceptionCode:(int*) ecp;
-(void) rect:(float) x y:(float) y width:(float) width height:(float) height;
-(void) fill;
-(void) stroke;
-(bool) isPointInPath:(const float) x y:(const float) y;
-(void) setStrokeColor:(float)r g:(float)g b:(float)b a:(float)a;
-(void) setFillColor:(float)r g:(float)g b:(float)b a:(float)a;
-(void) clear;
-(void) scale:(float) sx sy:(float) sy;
-(void) rotate:(float) angleInRadians;
-(void) translate:(float) tx ty:(float) ty;
-(void) save;
-(void) restore;

@property (readonly) Texture * texture;
@property (readonly) GLubyte * pixels;

@end
