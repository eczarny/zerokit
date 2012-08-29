#import "ZeroKitAccessibilityElement.h"

@interface ZeroKitAccessibilityElement (ZeroKitAccessibilityElementPrivate)

- (void)setElement: (AXUIElementRef)element;

@end

#pragma mark -

@implementation ZeroKitAccessibilityElement

- (id)init {
    if (self = [super init]) {
        myElement = NULL;
    }
    
    return self;
}

#pragma mark -

+ (ZeroKitAccessibilityElement *)systemWideElement {
    ZeroKitAccessibilityElement *systemWideElement = [[[ZeroKitAccessibilityElement alloc] init] autorelease];
    
    [systemWideElement setElement: AXUIElementCreateSystemWide()];
    
    return systemWideElement;
}

#pragma mark -

- (ZeroKitAccessibilityElement *)elementWithAttribute: (CFStringRef)attribute {
    ZeroKitAccessibilityElement *element = nil;
    AXUIElementRef childElement;
    AXError result;
    
    result = AXUIElementCopyAttributeValue(myElement, attribute, (CFTypeRef *)&childElement);
    
    if (result == kAXErrorSuccess) {
        element = [[[ZeroKitAccessibilityElement alloc] init] autorelease];
        
        [element setElement: childElement];
    } else {
        NSLog(@"Unable to obtain the accessibility element with the specified attribute: %@", attribute);
    }
    
    return element;
}

#pragma mark -

- (NSString *)stringValueOfAttribute: (CFStringRef)attribute {
    if (CFGetTypeID(myElement) == AXUIElementGetTypeID()) {
        NSString *value = nil;
        AXError result;
        
        result = AXUIElementCopyAttributeValue(myElement, attribute, (CFTypeRef *)&value);
        
        if (result == kAXErrorSuccess) {
            return value;
        } else {
            NSLog(@"There was a problem getting the string value of the specified attribute: %@", attribute);
        }
    }
    
    return nil;
}

- (AXValueRef)valueOfAttribute: (CFStringRef)attribute type: (AXValueType)type {
    if (CFGetTypeID(myElement) == AXUIElementGetTypeID()) {
        CFTypeRef value;
        AXError result;
        
        result = AXUIElementCopyAttributeValue(myElement, attribute, (CFTypeRef *)&value);
        
        if ((result == kAXErrorSuccess) && (AXValueGetType(value) == type)) {
            return value;
        } else {
            NSLog(@"There was a problem getting the value of the specified attribute: %@", attribute);
        }
    }
    
    return NULL;
}

#pragma mark -

- (void)setValue: (AXValueRef)value forAttribute: (CFStringRef)attribute {
    AXError result = AXUIElementSetAttributeValue(myElement, attribute, (CFTypeRef *)value);
    
    if (result != kAXErrorSuccess) {
        NSLog(@"There was a problem setting the value of the specified attribute: %@", attribute);
    }
}

@end

#pragma mark -

@implementation ZeroKitAccessibilityElement (ZeroKitAccessibilityElementPrivate)

- (void)setElement: (AXUIElementRef)element {
    myElement = element;
}

@end
