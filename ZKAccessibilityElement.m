#import "ZKAccessibilityElement.h"

@interface ZKAccessibilityElement (ZKAccessibilityElementPrivate)

- (void)setElement: (AXUIElementRef)element;

@end

#pragma mark -

@implementation ZKAccessibilityElement

- (id)init {
    if (self = [super init]) {
        myElement = NULL;
    }
    
    return self;
}

#pragma mark -

+ (ZKAccessibilityElement *)systemWideElement {
    ZKAccessibilityElement *element = [ZKAccessibilityElement new];
    AXUIElementRef systemWideElement = AXUIElementCreateSystemWide();
    
    [element setElement: systemWideElement];
    
    CFRelease(systemWideElement);
    
    return element;
}

#pragma mark -

- (ZKAccessibilityElement *)elementWithAttribute: (CFStringRef)attribute {
    ZKAccessibilityElement *element = nil;
    AXUIElementRef childElement;
    AXError result;
    
    result = AXUIElementCopyAttributeValue(myElement, attribute, (CFTypeRef *)&childElement);
    
    if (result == kAXErrorSuccess) {
        element = [ZKAccessibilityElement new];
        
        [element setElement: childElement];
        
        CFRelease(childElement);
    } else {
        NSLog(@"Unable to obtain the accessibility element with the specified attribute: %@", attribute);
    }
    
    return element;
}

#pragma mark -

- (NSString *)stringValueOfAttribute: (CFStringRef)attribute {
    if (CFGetTypeID(myElement) == AXUIElementGetTypeID()) {
        CFTypeRef value;
        AXError result;
        
        result = AXUIElementCopyAttributeValue(myElement, attribute, &value);
        
        if (result == kAXErrorSuccess) {
            return CFBridgingRelease(value);
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

#pragma mark -

- (void)dealloc {
    if (myElement != NULL) {
        CFRelease(myElement);
    }
}

@end

#pragma mark -

@implementation ZKAccessibilityElement (ZKAccessibilityElementPrivate)

- (void)setElement: (AXUIElementRef)element {
    if (myElement != NULL) {
        CFRelease(myElement);
    }
    
    myElement = CFRetain(element);
}

@end
