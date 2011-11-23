/*
 *  FloatRect.cpp
*/

#include "FloatRect.h"
#include <QuartzCore/QuartzCore.h>

FloatRect::FloatRect(const CGRect& r) : m_location(r.origin), m_size(r.size)
{
}

FloatRect::operator CGRect() const
{
    return CGRectMake(x(), y(), width(), height());
}