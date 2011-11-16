#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface ZeroKitAccessibilityElement : NSObject {
    AXUIElementRef myElement;
}

+ (ZeroKitAccessibilityElement *)systemWideElement;

#pragma mark -

- (ZeroKitAccessibilityElement *)elementWithAttribute: (CFStringRef)attribute;

#pragma mark -

- (AXValueRef)valueOfAttribute: (CFStringRef)attribute type: (AXValueType)type;

- (void)setValue: (AXValueRef)value forAttribute: (CFStringRef)attribute;

@end
