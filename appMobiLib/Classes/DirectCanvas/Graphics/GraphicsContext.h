/*
 *  GraphicsContext.h
 */

#include "Path.h"

typedef struct CGContext * CGContextRef;

class GraphicsContext {
public:
	GraphicsContext(CGContextRef ctx);
	~GraphicsContext();
	void beginPath();
	void addPath(const Path& path);
	void fillPath();
	void strokePath();

	void scale(const FloatSize& size);
	void rotate(float angle);
	void translate(float x, float y);

	void save();
	void restore();

private:
	CGContextRef platformContext();
	CGContextRef m_context;
	void savePlatformState();
	void restorePlatformState();
};	
