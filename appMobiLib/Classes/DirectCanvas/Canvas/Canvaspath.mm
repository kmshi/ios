//
//  CanvasPath.mm
//  appLab
// 
//  Copyright 2011 None. All rights reserved.
//

#import "CanvasPath.h"
#include "ExceptionCode.h"
#include "GraphicsContext.h"

Path *p_path = NULL;
Path m_path;


//----------------
//from math.h
#define isfinite(x)	\
(	sizeof (x) == sizeof(float )	?	__inline_isfinitef((float)(x))	\
:	sizeof (x) == sizeof(double)	?	__inline_isfinited((double)(x))	\
:	__inline_isfinite ((long double)(x)))
//-------------------

@implementation CanvasPath

@synthesize texture;
@synthesize pixels;

- (id)initWithWidth:(int)width height:(int)height
{
	//NSLog(@"CanvasPath.init"); //:temp
	
	m_width=width;
	m_height=height;
	if(!context) {
		realWidth = pow(2, ceil(log2( width )));
		realHeight = pow(2, ceil(log2( height )));
		
		pixels = (GLubyte *) malloc( realWidth * realHeight * 4);
		memset( pixels, 0, realWidth * realHeight * 4 );
		context = CGBitmapContextCreate(pixels, realWidth, realHeight, 8, realWidth * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
	}
	if(!texture)
		texture = [[Texture alloc] initWithWidth:width height:height pixels:pixels];
	
	if(!cg)
		cg = new GraphicsContext(context);
	if(!p_path) {
		p_path = new Path();
		m_path=*p_path;
	}
//	m_transform=CGAffineTransformMakeTranslation(0, 0); // create unity transform
	m_transform=CGAffineTransformMake(-1, 0, 0, -1, 0, realHeight-m_height); //: create 180 rotated transform
	((GraphicsContext *)cg)->translate(0, realHeight-m_height);  // move to align with the openGL surface (since allocated next power of 2)
	
	return self;
}

//------   Path API   ----------

-(void) beginPath
{
	m_path.clear();
}

-(void) closePath
{
    m_path.closeSubpath();
}

-(void) moveTo:(float) x y:(float) y
{
    if (!isfinite(x) | !isfinite(y))
        return;
//    if (!state().m_invertibleCTM)
//        return;
    m_path.moveTo(FloatPoint(x, y));
}

-(void) lineTo:(float) x y:(float) y
{
    if (!isfinite(x) | !isfinite(y))
        return;
//    if (!state().m_invertibleCTM)
//        return;
    if (!m_path.hasCurrentPoint())
        m_path.moveTo(FloatPoint(x, y));
    else
        m_path.addLineTo(FloatPoint(x, y));
}

-(void) quadraticCurveTo:(float) cpx cpy:(float) cpy x:(float) x y:(float) y
{
    if (!isfinite(cpx) | !isfinite(cpy) | !isfinite(x) | !isfinite(y))
        return;
//    if (!state().m_invertibleCTM)
//        return;
    if (!m_path.hasCurrentPoint())
        m_path.moveTo(FloatPoint(x, y));
    else
        m_path.addQuadCurveTo(FloatPoint(cpx, cpy), FloatPoint(x, y));
}

-(void) bezierCurveTo:(float) cp1x cp1y:(float) cp1y cp2x:(float) cp2x cp2y:(float) cp2y x:(float) x y:(float) y
{
    if (!isfinite(cp1x) | !isfinite(cp1y) | !isfinite(cp2x) | !isfinite(cp2y) | !isfinite(x) | !isfinite(y))
        return;
//    if (!state().m_invertibleCTM)
//        return;
    if (!m_path.hasCurrentPoint())
        m_path.moveTo(FloatPoint(x, y));
    else
        m_path.addBezierCurveTo(FloatPoint(cp1x, cp1y), FloatPoint(cp2x, cp2y), FloatPoint(x, y));
}

-(void) arcTo:(float) x0 y0:(float) y0 x1:(float) x1 y1:(float) y1 r:(float) r exceptionCode:(int*) ec
{
    ec = 0;
    if (!isfinite(x0) | !isfinite(y0) | !isfinite(x1) | !isfinite(y1) | !isfinite(r))
        return;
    
    if (r < 0) {
        *ec = INDEX_SIZE_ERR;
        return;
    }
//    if (!state().m_invertibleCTM)
//        return;
    m_path.addArcTo(FloatPoint(x0, y0), FloatPoint(x1, y1), r);
}

-(void) arc:(float)x y:(float)y r:(float)r sa:(float)sa ea:(float)ea acl:(int) anticlockwise exceptionCode:(int*) ecp
{
    *ecp = 0;
    if (!isfinite(x) | !isfinite(y) | !isfinite(r) | !isfinite(sa) | !isfinite(ea))
        return;
    
    if (r < 0) {
        *ecp = INDEX_SIZE_ERR;
        return;
    }
//    if (!state().m_invertibleCTM)
//        return;
    m_path.addArc(FloatPoint(x, y), r, sa, ea, anticlockwise);
}

static bool validateRectForCanvas(float& x, float& y, float& width, float& height)
{
    if (!isfinite(x) | !isfinite(y) | !isfinite(width) | !isfinite(height))
        return false;
	
    if (!width && !height)
        return false;
	
    if (width < 0) {
        width = -width;
        x -= width;
    }
    
    if (height < 0) {
        height = -height;
        y -= height;
    }
    
    return true;
}

-(void) rect:(float) x y:(float) y width:(float) width height:(float) height
{
    if (!validateRectForCanvas(x, y, width, height))
        return;
//    if (!state().m_invertibleCTM)
//        return;
    m_path.addRect(FloatRect(x, y, width, height));
}


-(void) fill
{
    GraphicsContext* c = ((GraphicsContext *)cg);
    if (!c)
        return;
//    if (!state().m_invertibleCTM)
//        return;
	
  //  if (!m_path.isEmpty()) {
        c->beginPath();
		c->addPath(m_path);
    //    willDraw(m_path.boundingRect());
        c->fillPath();
   // }
}

-(void) stroke
{
    GraphicsContext* c = ((GraphicsContext *)cg);
    if (!c)
        return;
//    if (!state().m_invertibleCTM)
//        return;
	
//    if (!m_path.isEmpty()) {
			c->beginPath();
			c->addPath(m_path);
//        CanvasStrokeStyleApplier strokeApplier(this);
//        FloatRect boundingRect = m_path.strokeBoundingRect(&strokeApplier);
//        willDraw(boundingRect);
			c->strokePath();
//    }
}

-(bool) isPointInPath:(const float) x y:(const float) y
{
	NSLog(@"isPointInPath not implemented yet!");
	//:TODO - add support for transform and enable
/*    GraphicsContext* c = drawingContext();
    if (!c)
        return false;
//    if (!state().m_invertibleCTM)
//        return false;
	
    FloatPoint point(x, y);
    AffineTransform ctm = state().m_transform;
    FloatPoint transformedPoint = ctm.inverse().mapPoint(point);
    return m_path.contains(transformedPoint);
 */
	return true;
}

-(void) scale:(float) sx sy:(float) sy
{
    GraphicsContext* c = ((GraphicsContext *)cg);
    if (!c)
        return;
//    if (!state().m_invertibleCTM)
//        return;
	
    if (!isfinite(sx) | !isfinite(sy))
        return;
/*	
    AffineTransform newTransform = state().m_transform;
    newTransform.scaleNonUniform(sx, sy);
    if (!newTransform.isInvertible()) {
        state().m_invertibleCTM = false;
        return;
    }
	
    state().m_transform = newTransform;
*/
	CGAffineTransform newTransform = CGAffineTransformScale(m_transform, sx, sy);
    m_transform = newTransform;

    c->scale(FloatSize(sx, sy));
  //  m_path.transform(AffineTransform().scaleNonUniform(1.0 / sx, 1.0 / sy));
}


-(void) rotate:(float) angleInRadians
{
    GraphicsContext* c = ((GraphicsContext *)cg);
    if (!c)
        return;
//    if (!state().m_invertibleCTM)
//        return;
	
    if (!isfinite(angleInRadians))
        return;
/*	
    AffineTransform newTransform = state().m_transform;
    newTransform.rotate(angleInRadians / piDouble * 180.0);
    if (!newTransform.isInvertible()) {
        state().m_invertibleCTM = false;
        return;
    }
	
    state().m_transform = newTransform;
*/
    CGAffineTransform newTransform = CGAffineTransformRotate(m_transform, angleInRadians);
    m_transform = newTransform;

    c->rotate(angleInRadians);
//    m_path.transform(AffineTransform().rotate(-angleInRadians / piDouble * 180.0));
}

-(void) translate:(float) tx ty:(float) ty
{
    GraphicsContext* c = ((GraphicsContext *)cg);
    if (!c)
        return;
//    if (!state().m_invertibleCTM)
//        return;
	
    if (!isfinite(tx) | !isfinite(ty))
        return;
	
/*
	AffineTransform newTransform = state().m_transform;
	newTransform.translate(tx, ty);
    if (!newTransform.isInvertible()) {
        state().m_invertibleCTM = false;
        return;
    }
 state().m_transform = newTransform;
*/
    CGAffineTransform newTransform = CGAffineTransformTranslate(m_transform, tx, ty);
    m_transform = newTransform;

    c->translate(tx, ty);
//    m_path.transform(AffineTransform().translate(-tx, -ty));
//:does not do anything now -	m_path.transform(CGAffineTransformTranslate(m_transform, -tx, -ty));
}

-(void) save
{
//    ASSERT(m_stateStack.size() >= 1);
//    m_stateStack.append(state());
    GraphicsContext* c = ((GraphicsContext *)cg);
    if (!c)
        return;
    c->save();
}

-(void) restore
{
//    ASSERT(m_stateStack.size() >= 1);
//    if (m_stateStack.size() <= 1)
//        return;
//    m_path.transform(state().m_transform);  //:TODO this might be needed to make sure path transform is set properly
//    m_stateStack.removeLast();
//    m_path.transform(state().m_transform.inverse());
    GraphicsContext* c = ((GraphicsContext *)cg);
    if (!c)
        return;
    c->restore();
}

//-------------------------------

-(void) setStrokeColor:(float)r g:(float)g b:(float)b a:(float)a
{
	CGContextSetRGBStrokeColor(context, r, g, b, a);  //: red for testing (why color shift & not working first time?)
}

-(void) setFillColor:(float)r g:(float)g b:(float)b a:(float)a
{
	CGContextSetRGBFillColor(context, r, g, b, a);  //: red for testing (why color shift & not working first time?)
}

-(void) clear
{
	CGRect rect;
	rect.origin=(CGPoint) {0,0};
	rect.size = (CGSize){realHeight, realWidth};
	CGAffineTransform tempTransform=CGAffineTransformMake(1, 0, 0, 1, 0, realHeight-m_height); //: create 180 rotated transform
	//CGContextSaveGState(context);  //:save and restore should not be needed since we do it when we clear
	CGContextClearRect(context, rect);
	//CGContextRestoreGState(context);

}

/*
-(void) testPath
{
	CGContextSetRGBStrokeColor(context, 0, 0, 1, 1);  //: red for testing (why color shift & not working first time?)
	cg->beginPath();
	CGContextTranslateCTM(context, 0, 16);
	cg->addPath(m_path);
	cg->strokePath();
	CGContextTranslateCTM(context, 0, -16);
	CGContextFillPath(context);
}
*/

//-------------------------------

- (void)dealloc
{
	if( texture ) [texture release];
	if(context) CGContextRelease(context); 
	free(pixels); //: TODO - Make sure correct
	[super dealloc];
}

@end
