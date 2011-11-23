
#import "FlyProgressView.h"

@implementation FlyProgressView

@synthesize position = _position;

- (id)initWithProgressViewStyle:(UIProgressViewStyle)style
{
	_tintColor = [UIColor yellowColor];
	_markColor = [UIColor redColor];
	_backColor = [UIColor blackColor];
	_doneColor = [UIColor greenColor];
	_position = -1.0;
	_isDone = NO;
	return [super initWithProgressViewStyle:style];
}

- (void)drawRect:(CGRect)rect
{
	if([self progressViewStyle] == UIProgressViewStyleDefault )
	{
		int width = rect.size.width - 6;
		CGContextRef ctx = UIGraphicsGetCurrentContext();

		CGContextSetFillColorWithColor(ctx, [_backColor CGColor]);
		CGContextFillRect(ctx, rect);

		if( _isDone == NO )
		{
			rect.size.width *= [self progress];
			CGContextSetFillColorWithColor(ctx, [_tintColor CGColor]);
			CGContextFillRect(ctx, rect);
		}
		else
		{
			rect.size.width *= [self progress];
			CGContextSetFillColorWithColor(ctx, [_doneColor CGColor]);
			CGContextFillRect(ctx, rect);
		}

		if( _position >= 0.0 )
		{
			CGContextSetFillColorWithColor(ctx, [_markColor CGColor]);
			CGContextFillRect(ctx, CGRectMake(_position * width, 0, 6, 1));
		}
	}
	else
	{
		[super drawRect:rect];
	}
}

- (void) setTintColor: (UIColor *) aColor
{
	[_tintColor release];
	_tintColor = [aColor retain];
}

- (void) setMarkColor: (UIColor *) aColor
{
	[_markColor release];
	_markColor = [aColor retain];
}

- (void) setBackColor: (UIColor *) aColor
{
	[_backColor release];
	_backColor = [aColor retain];
}

- (void) setDoneColor: (UIColor *) aColor
{
	[_doneColor release];
	_doneColor = [aColor retain];
}

- (void) setDone:(BOOL) done
{
	_isDone = done;
	[self setNeedsDisplay];
}

- (void) setPosition:(float) position
{
	_position = position;
	[self setNeedsDisplay];
}

- (float) getPosition
{
	return _position;
}

- (void)dealloc
{
    [super dealloc];
	[_tintColor release];
	[_markColor release];
}

@end
