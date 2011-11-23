/*
 *  Path.cpp
 */

#include "Path.h"
//#include "AffineTransform.h"

Path::Path()
: m_path(CGPathCreateMutable())
{
}

Path::~Path()
{
    CGPathRelease(m_path);
}

void Path::moveTo(const FloatPoint& point)
{
    CGPathMoveToPoint(m_path, 0, point.x(), point.y());
}

void Path::addLineTo(const FloatPoint& p)
{
    CGPathAddLineToPoint(m_path, 0, p.x(), p.y());
}

void Path::addQuadCurveTo(const FloatPoint& cp, const FloatPoint& p)
{
    CGPathAddQuadCurveToPoint(m_path, 0, cp.x(), cp.y(), p.x(), p.y());
}

void Path::addBezierCurveTo(const FloatPoint& cp1, const FloatPoint& cp2, const FloatPoint& p)
{
    CGPathAddCurveToPoint(m_path, 0, cp1.x(), cp1.y(), cp2.x(), cp2.y(), p.x(), p.y());
}

void Path::addArcTo(const FloatPoint& p1, const FloatPoint& p2, float radius)
{
    CGPathAddArcToPoint(m_path, 0, p1.x(), p1.y(), p2.x(), p2.y(), radius);
}

void Path::closeSubpath()
{
    if (!CGPathIsEmpty(m_path)) // to silence a warning when trying to close an empty path
        CGPathCloseSubpath(m_path);
}

void Path::addArc(const FloatPoint& p, float r, float sa, float ea, bool clockwise)
{
    // Workaround for <rdar://problem/5189233> CGPathAddArc hangs or crashes when passed inf as start or end angle
    if (isfinite(sa) && isfinite(ea))
        CGPathAddArc(m_path, 0, p.x(), p.y(), r, sa, ea, clockwise);
}

void Path::addRect(const FloatRect& r)
{

    CGPathAddRect(m_path, 0, r);
}


void Path::addEllipse(const FloatRect& r)
{
    CGPathAddEllipseInRect(m_path, 0, r);
}


void Path::clear()
{
    CGPathRelease(m_path);
    m_path = CGPathCreateMutable();
}

bool Path::isEmpty() const
{
    return CGPathIsEmpty(m_path);
}

bool Path::hasCurrentPoint() const
{
    return !isEmpty();
}

//void transform(const AffineTransform& transform)
void Path::transform(const CGAffineTransform& transform)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform transformCG = transform;
    CGPathAddPath(path, &transformCG, m_path);
    CGPathRelease(m_path);
    m_path = path;
}