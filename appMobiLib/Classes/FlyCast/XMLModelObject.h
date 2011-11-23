
#import <Foundation/Foundation.h>

@protocol XMLModelObject

- (NSMutableDictionary *)XMLAttributes;
- (void)setXMLAttributes:(NSMutableDictionary *)attributes;

+ (NSDictionary *)childElements;
+ (NSDictionary *)setterMethodsAndChildElementNames;

@end