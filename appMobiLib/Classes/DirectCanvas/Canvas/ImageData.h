//
//  ImageData.h
//  appLab
//

//

#import <Foundation/Foundation.h>

@interface ImageData : NSObject {
	//ImageData model
    unsigned long _width;
	unsigned long _height;
	// data, is currently not used in here
}

-(ImageData *)initWithHeight:(unsigned long)height width:(unsigned long)width;

- (unsigned long)width;
- (unsigned long)height;
//-(CanvasPixelArray *) data;

@end
