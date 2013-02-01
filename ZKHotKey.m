#import "ZKHotKey.h"
#import "ZKHotKeyTranslator.h"

@implementation ZKHotKey

- (id)initWithHotKeyCode: (NSInteger)aHotKeyCode hotKeyModifiers: (NSInteger)theHotKeyModifiers {
    if (self = [super init]) {
        handle = -1;
        hotKeyName = nil;
        hotKeyAction = nil;
        hotKeyCode = aHotKeyCode;
        hotKeyModifiers = [ZKHotKeyTranslator convertModifiersToCarbonIfNecessary: theHotKeyModifiers];
        hotKeyRef = NULL;
    }
    
    return self;
}

#pragma mark -

- (id)initWithCoder: (NSCoder *)coder {
    if (self = [super init]) {
        if ([coder allowsKeyedCoding]) {
            hotKeyName = [coder decodeObjectForKey: @"name"];
            hotKeyCode = [coder decodeIntegerForKey: @"keyCode"];
            hotKeyModifiers = [coder decodeIntegerForKey: @"modifiers"];
        } else {
            hotKeyName = [coder decodeObject];
            
            [coder decodeValueOfObjCType: @encode(NSInteger) at: &hotKeyCode];
            [coder decodeValueOfObjCType: @encode(NSInteger) at: &hotKeyModifiers];
        }
    }
    
    return self;
}

#pragma mark -

- (void)encodeWithCoder: (NSCoder *)coder {
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject: hotKeyName forKey: @"name"];
        [coder encodeInteger: hotKeyCode forKey: @"keyCode"];
        [coder encodeInteger: hotKeyModifiers forKey: @"modifiers"];
    } else {
        [coder encodeObject: hotKeyName];
        [coder encodeValueOfObjCType: @encode(NSInteger) at: &hotKeyCode];
        [coder encodeValueOfObjCType: @encode(NSInteger) at: &hotKeyModifiers];
    }
}

#pragma mark -

- (id)replacementObjectForPortCoder: (NSPortCoder *)encoder {
    if ([encoder isBycopy]) {
        return self;
    }
    
    return [super replacementObjectForPortCoder: encoder];
}

#pragma mark -

+ (ZKHotKey *)clearedHotKey {
    return [[ZKHotKey alloc] initWithHotKeyCode: 0 hotKeyModifiers: 0];
}

+ (ZKHotKey *)clearedHotKeyWithName: (NSString *)name {
    ZKHotKey *hotKey = [[ZKHotKey alloc] initWithHotKeyCode: 0 hotKeyModifiers: 0];
    
    [hotKey setHotKeyName: name];
    
    return hotKey;
}

#pragma mark -

- (NSInteger)handle {
    return handle;
}

- (void)setHandle: (NSInteger)aHandle {
    handle = aHandle;
}

#pragma mark -

- (NSString *)hotKeyName {
    return hotKeyName;
}

- (void)setHotKeyName: (NSString *)aHotKeyName {
    hotKeyName = aHotKeyName;
}

#pragma mark -

- (ZKHotKeyAction)hotKeyAction {
    return hotKeyAction;
}

- (void)setHotKeyAction: (ZKHotKeyAction)aHotKeyAction {
    hotKeyAction = aHotKeyAction;
}

#pragma mark -

- (void)triggerHotKeyAction {
    if (hotKeyAction) {
        hotKeyAction(self);
    }
}

#pragma mark -

- (NSInteger)hotKeyCode {
    return hotKeyCode;
}

- (void)setHotKeyCode: (NSInteger)aHotKeyCode {
    hotKeyCode = aHotKeyCode;
}

#pragma mark -

- (NSInteger)hotKeyModifiers {
    return hotKeyModifiers;
}

- (void)setHotKeyModifiers: (NSInteger)theHotKeyModifiers {
    hotKeyModifiers = [ZKHotKeyTranslator convertModifiersToCarbonIfNecessary: theHotKeyModifiers];
}

#pragma mark -

- (EventHotKeyRef)hotKeyRef {
    return hotKeyRef;
}

- (void)setHotKeyRef: (EventHotKeyRef)aHotKeyRef {
    hotKeyRef = aHotKeyRef;
}

#pragma mark -

- (BOOL)isClearedHotKey {
    return (hotKeyCode == 0) && (hotKeyModifiers == 0);
}

#pragma mark -

- (NSString *)displayString {
    return [[ZKHotKeyTranslator sharedTranslator] translateHotKey: self];
}

#pragma mark -

+ (BOOL)validCocoaModifiers: (NSInteger)modifiers {
    return (modifiers & NSAlternateKeyMask) || (modifiers & NSCommandKeyMask) || (modifiers & NSControlKeyMask) || (modifiers & NSShiftKeyMask);
}

#pragma mark -

- (BOOL)isEqual: (id)object {
    if (object == self) {
        return YES;
    }
    
    if (!object || ![object isKindOfClass: [self class]]) {
        return NO;
    }
    
    return [self isEqualToHotKey: object];
}

- (BOOL)isEqualToHotKey: (ZKHotKey *)hotKey {
    if (hotKey == self) {
        return YES;
    }
    
    if ([hotKey hotKeyCode] != hotKeyCode) {
        return NO;
    }
    
    if ([hotKey hotKeyModifiers] != hotKeyModifiers) {
        return NO;
    }
    
    return YES;
}

@end
