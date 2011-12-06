#import <Foundation/Foundation.h>

@class ZeroKitHotKey;

@interface ZeroKitHotKeyValidator : NSObject

+ (BOOL)isHotKey: (ZeroKitHotKey *)hotKey validWithError: (NSError **)error;

@end
