/*
 *  GraphicsContextCG.cpp
 */

#include "GraphicsContext.h"
#import <QuartzCore/QuartzCore.h>

GraphicsContext::GraphicsContext(CGContextRef cgContext)
{
    if (cgContext) {
		m_context=cgContext;
    }
}

GraphicsContext::~GraphicsContext()
{
}

CGContextRef GraphicsContext::platformContext()
{
	return m_context;
}

void GraphicsContext::beginPath()
{
    CGContextBeginPath(platformContext());
}

void GraphicsContext::addPath(const Path& path)
{
    CGContextAddPath(platformContext(), path.platformPath());
}

static inline void fillPathWithFillRule(CGContextRef context/*, WindRule fillRule*/)
{
/*    if (fillRule == RULE_EVENODD)
        CGContextEOFillPath(context);
    else
*/
		CGContextFillPath(context);
}


void GraphicsContext::fillPath()
{
/*    if (paintingDisabled())
        return;
*/	
    CGContextRef context = platformContext();
/*	
    // FIXME: Is this helpful and correct in the fillPattern and fillGradient cases?
    setCGFillColorSpace(context, m_common->state.fillColorSpace);
	
    if (m_common->state.fillGradient) {
        CGContextSaveGState(context);
        if (fillRule() == RULE_EVENODD)
            CGContextEOClip(context);
        else
            CGContextClip(context);
        CGContextConcatCTM(context, m_common->state.fillGradient->gradientSpaceTransform());
        m_common->state.fillGradient->paint(this);
        CGContextRestoreGState(context);
        return;
    }
	
    if (m_common->state.fillPattern)
        applyFillPattern();
*/    fillPathWithFillRule(context/*, fillRule()*/);
}


void GraphicsContext::strokePath()
{
/*
    if (paintingDisabled())
        return;
*/	
    CGContextRef context = platformContext();
/*	
    // FIXME: Is this helpful and correct in the strokePattern and strokeGradient cases?
    setCGStrokeColorSpace(context, m_common->state.strokeColorSpace);
	
    if (m_common->state.strokeGradient) {
        CGContextSaveGState(context);
        CGContextReplacePathWithStrokedPath(context);
        CGContextClip(context);
        CGContextConcatCTM(context, m_common->state.strokeGradient->gradientSpaceTransform());
        m_common->state.strokeGradient->paint(this);
        CGContextRestoreGState(context);
        return;
    }
	
    if (m_common->state.strokePattern)
        applyStrokePattern();
*/
    CGContextStrokePath(context);
}



/*
void GraphicsContext::setPlatformStrokeColor(const Color& color, ColorSpace colorSpace)
{
    if (paintingDisabled())
        return;
    setCGStrokeColor(platformContext(), color, colorSpace);
}


void GraphicsContext::setPlatformFillColor(const Color& color, ColorSpace colorSpace)
{
    if (paintingDisabled())
        return;
    setCGFillColor(platformContext(), color, colorSpace);
}

*/

void GraphicsContext::scale(const FloatSize& size)
{
//    if (paintingDisabled())
//        return;
    CGContextScaleCTM(platformContext(), size.width(), size.height());
//    m_data->scale(size);
//    m_data->m_userToDeviceTransformKnownToBeIdentity = false;
}

void GraphicsContext::rotate(float angle)
{
//    if (paintingDisabled())
//        return;
    CGContextRotateCTM(platformContext(), angle);
//    m_data->rotate(angle);
//    m_data->m_userToDeviceTransformKnownToBeIdentity = false;
}

void GraphicsContext::translate(float x, float y)
{
//    if (paintingDisabled())
//        return;
    CGContextTranslateCTM(platformContext(), x, y);
//    m_data->translate(x, y);
//    m_data->m_userToDeviceTransformKnownToBeIdentity = false;
}

void GraphicsContext::save()
{
/*    if (paintingDisabled())
        return;
	
    m_common->stack.append(m_common->state);*/
	
    savePlatformState();
}

void GraphicsContext::restore()
{
/*    if (paintingDisabled())
        return;
	
    if (m_common->stack.isEmpty()) {
        LOG_ERROR("ERROR void GraphicsContext::restore() stack is empty");
        return;
    }
    m_common->state = m_common->stack.last();
    m_common->stack.removeLast();*/
	
    restorePlatformState();
}


void GraphicsContext::savePlatformState()
{
    // Note: Do not use this function within this class implementation, since we want to avoid the extra
    // save of the secondary context (in GraphicsContextPlatformPrivateCG.h).
    CGContextSaveGState(platformContext());
//    m_data->save();
}

void GraphicsContext::restorePlatformState()
{
    // Note: Do not use this function within this class implementation, since we want to avoid the extra
    // restore of the secondary context (in GraphicsContextPlatformPrivateCG.h).
    CGContextRestoreGState(platformContext());
 //   m_data->restore();
 //   m_data->m_userToDeviceTransformKnownToBeIdentity = false;
}

