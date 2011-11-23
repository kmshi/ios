/*
 *  FloatPoint.cpp
 *  appLab
 *
 *  Copyright 2011 None. All rights reserved.
 *
 */

#include "FloatPoint.h"
#include <QuartzCore/QuartzCore.h>

FloatPoint::FloatPoint(const CGPoint& p) : m_x(p.x), m_y(p.y)
{
}

FloatPoint::operator CGPoint() const
{
    return CGPointMake(m_x, m_y);
}
