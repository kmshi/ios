//
//  ImageData.m
//  appLab
//

//

#import "ImageData.h"

@implementation ImageData

-(ImageData *)initWithHeight:(unsigned long)height width:(unsigned long)width {
    _height = height;
    _width = width;
    
    return self;
}

-(unsigned long)width {
    return _width;
}

-(unsigned long)height {
    return _height;
}

-(void)dealloc
{
	[super dealloc];
}

@end
