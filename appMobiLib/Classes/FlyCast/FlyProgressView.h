
#import <UIKit/UIKit.h>

@interface FlyProgressView : UIProgressView
{
	UIColor *_tintColor;
	UIColor *_markColor;
	UIColor *_backColor;
	UIColor *_doneColor;
	BOOL _isDone;
	float _position;
}

- (void) setTintColor:(UIColor *) aColor;
- (void) setMarkColor:(UIColor *) aColor;
- (void) setBackColor:(UIColor *) aColor;
- (void) setDoneColor:(UIColor *) aColor;
- (void) setDone:(BOOL) done;
- (void) setPosition:(float) position;
- (float) getPosition;

@property(nonatomic) float position;

@end