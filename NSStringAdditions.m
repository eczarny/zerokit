#import "NSStringAdditions.h"

@implementation NSString (NSStringAdditions)

+ (NSString *)stringByGeneratingUUID {
    CFUUIDRef UUIDReference = CFUUIDCreate(nil);
    NSString *result = CFBridgingRelease(CFUUIDCreateString(nil, UUIDReference));
    
    CFRelease(UUIDReference);
    
    return result;
}

#pragma mark -

- (BOOL)contains: (NSString *)string {
    return [self rangeOfString: string].location != NSNotFound;
}

@end
