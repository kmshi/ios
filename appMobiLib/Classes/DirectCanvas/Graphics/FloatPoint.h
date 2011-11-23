/*
 *  FloatPoint.h
 */


#ifndef FloatPoint_h
#define FloatPoint_h

#include "FloatSize.h"
/*
#include "IntPoint.h"
#include <wtf/MathExtras.h>
*/
typedef struct CGPoint CGPoint;

	
class FloatPoint {
	public:
		FloatPoint() : m_x(0), m_y(0) { }
		FloatPoint(float x, float y) : m_x(x), m_y(y) { }
//		FloatPoint(const IntPoint&);
		
		static FloatPoint zero() { return FloatPoint(); }
		static FloatPoint narrowPrecision(double x, double y);
		
		float x() const { return m_x; }
		float y() const { return m_y; }
		
		void setX(float x) { m_x = x; }
		void setY(float y) { m_y = y; }
		void move(float dx, float dy) { m_x += dx; m_y += dy; }
		
		FloatPoint(const CGPoint&);
		operator CGPoint() const;
//		FloatPoint matrixTransform(const TransformationMatrix&) const;
//		FloatPoint matrixTransform(const AffineTransform&) const;
		
	private:
		float m_x, m_y;
	};
	
	
	inline FloatPoint& operator+=(FloatPoint& a, const FloatSize& b)
	{
		a.move(b.width(), b.height());
		return a;
	}
	
	inline FloatPoint& operator-=(FloatPoint& a, const FloatSize& b)
	{
		a.move(-b.width(), -b.height());
		return a;
	}
	
	inline FloatPoint operator+(const FloatPoint& a, const FloatSize& b)
	{
		return FloatPoint(a.x() + b.width(), a.y() + b.height());
	}
	
	inline FloatSize operator-(const FloatPoint& a, const FloatPoint& b)
	{
		return FloatSize(a.x() - b.x(), a.y() - b.y());
	}
	
	inline FloatPoint operator-(const FloatPoint& a, const FloatSize& b)
	{
		return FloatPoint(a.x() - b.width(), a.y() - b.height());
	}
	
	inline bool operator==(const FloatPoint& a, const FloatPoint& b)
	{
		return a.x() == b.x() && a.y() == b.y();
	}
	
	inline bool operator!=(const FloatPoint& a, const FloatPoint& b)
	{
		return a.x() != b.x() || a.y() != b.y();
	}
/*	
	inline IntPoint roundedIntPoint(const FloatPoint& p)
	{
		return IntPoint(static_cast<int>(roundf(p.x())), static_cast<int>(roundf(p.y())));
	}
*/	

#endif
