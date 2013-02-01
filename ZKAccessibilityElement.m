#import "ZKAccessibilityElement.h"

@interface ZKAccessibilityElement (ZKAccessibilityElementPrivate)

- (void)setElement: (AXUIElementRef)anElement;

@end

#pragma mark -

@implementation ZKAccessibilityElement

- (id)init {
    if (self = [super init]) {
        element = NULL;
    }
    
    return self;
}

#pragma mark -

+ (ZKAccessibilityElement *)systemWideElement {
    ZKAccessibilityElement *newElement = [ZKAccessibilityElement new];
    AXUIElementRef systemWideElement = AXUIElementCreateSystemWide();
    
    [newElement setElement: systemWideElement];
    
    CFRelease(systemWideElement);
    
    return newElement;
}

#pragma mark -

- (ZKAccessibilityElement *)elementWithAttribute: (CFStringRef)attribute {
    ZKAccessibilityElement *newElement = nil;
    AXUIElementRef childElement;
    AXError result;
    
    result = AXUIElementCopyAttributeValue(element, attribute, (CFTypeRef *)&childElement);
    
    if (result == kAXErrorSuccess) {
        newElement = [ZKAccessibilityElement new];
        
        [newElement setElement: childElement];
        
        CFRelease(childElement);
    } else {
        NSLog(@"Unable to obtain the accessibility element with the specified attribute: %@", attribute);
    }
    
    return newElement;
}

#pragma mark -

- (NSString *)stringValueOfAttribute: (CFStringRef)attribute {
    if (CFGetTypeID(element) == AXUIElementGetTypeID()) {
        CFTypeRef value;
        AXError result;
        
        result = AXUIElementCopyAttributeValue(element, attribute, &value);
        
        if (result == kAXErrorSuccess) {
            return CFBridgingRelease(value);
        } else {
            NSLog(@"There was a problem getting the string value of the specified attribute: %@", attribute);
        }
    }
    
    return nil;
}

- (AXValueRef)valueOfAttribute: (CFStringRef)attribute type: (AXValueType)type {
    if (CFGetTypeID(element) == AXUIElementGetTypeID()) {
        CFTypeRef value;
        AXError result;
        
        result = AXUIElementCopyAttributeValue(element, attribute, (CFTypeRef *)&value);
        
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
    AXError result = AXUIElementSetAttributeValue(element, attribute, (CFTypeRef *)value);
    
    if (result != kAXErrorSuccess) {
        NSLog(@"There was a problem setting the value of the specified attribute: %@", attribute);
    }
}

#pragma mark -

- (void)dealloc {
    if (element != NULL) {
        CFRelease(element);
    }
}

@end

#pragma mark -

@implementation ZKAccessibilityElement (ZKAccessibilityElementPrivate)

- (void)setElement: (AXUIElementRef)anElement {
    if (element != NULL) {
        CFRelease(element);
    }
    
    element = CFRetain(anElement);
}

@end
