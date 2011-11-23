/*
 *  Path.h
 */

#include <QuartzCore/QuartzCore.h>
#include "FloatPoint.h"
#include "FloatSize.h"
#include "FloatRect.h"

#ifndef Path_h
#define Path_h
typedef struct CGPath PlatformPath;
typedef PlatformPath* PlatformPathPtr;

class Path {
public:
	Path();
	~Path();
	
	Path(const Path&);
//	Path& operator=(const Path&);
	
	void clear();
	bool isEmpty() const;
	// Gets the current point of the current path, which is conceptually the final point reached by the path so far.
	// Note the Path can be empty (isEmpty() == true) and still have a current point.
	bool hasCurrentPoint() const;
	
	void moveTo(const FloatPoint&);
	void addLineTo(const FloatPoint&);
	void addQuadCurveTo(const FloatPoint& controlPoint, const FloatPoint& endPoint);
	void addBezierCurveTo(const FloatPoint& controlPoint1, const FloatPoint& controlPoint2, const FloatPoint& endPoint);
	void addArcTo(const FloatPoint&, const FloatPoint&, float radius);
	void closeSubpath();
	
	void addArc(const FloatPoint&, float radius, float startAngle, float endAngle, bool anticlockwise);
	void addRect(const FloatRect&);
	void addEllipse(const FloatRect&);
	void transform(const CGAffineTransform& transform);
	
	PlatformPathPtr platformPath() const { return m_path; }
	
private:
	PlatformPathPtr m_path;
};

#endif
