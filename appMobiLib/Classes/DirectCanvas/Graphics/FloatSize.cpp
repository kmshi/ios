/*
 *  FloatSize.cpp
 *  appLab
 */

#include "FloatSize.h"
#include <QuartzCore/QuartzCore.h>

FloatSize::FloatSize(const CGSize& s) : m_width(s.width), m_height(s.height)
{
}

FloatSize::operator CGSize() const
{
    return CGSizeMake(m_width, m_height);
}
