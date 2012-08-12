#import <Foundation/Foundation.h>

@class ZeroKitHotKey;

@interface ZeroKitHotKeyValidator : NSObject

+ (BOOL)isHotKeyValid: (ZeroKitHotKey *)hotKey error: (NSError **)error;

+ (BOOL)isHotKeyValid: (ZeroKitHotKey *)hotKey withValidators: (NSArray *)validators error: (NSError **)error;

@end
