#import "ZeroKitHotKey.h"
#import "ZeroKitHotKeyAction.h"
#import "ZeroKitHotKeyTranslator.h"

@implementation ZeroKitHotKey

- (id)initWithHotKeyCode: (NSInteger)hotKeyCode hotKeyModifiers: (NSInteger)hotKeyModifiers {
    if (self = [super init]) {
        myHandle = -1;
        myHotKeyName = nil;
        myHotKeyAction = nil;
        myHotKeyCode = hotKeyCode;
        myHotKeyModifiers = [ZeroKitHotKeyTranslator convertModifiersToCarbonIfNecessary: hotKeyModifiers];
        myHotKeyRef = NULL;
    }
    
    return self;
}

#pragma mark -

- (id)initWithCoder: (NSCoder *)coder {
    if (self = [super init]) {
        if ([coder allowsKeyedCoding]) {
            myHotKeyName = [[coder decodeObjectForKey: @"name"] retain];
            myHotKeyCode = [coder decodeIntegerForKey: @"keyCode"];
            myHotKeyModifiers = [coder decodeIntegerForKey: @"modifiers"];
        } else {
            myHotKeyName = [[coder decodeObject] retain];
            
            [coder decodeValueOfObjCType: @encode(NSInteger) at: &myHotKeyCode];
            [coder decodeValueOfObjCType: @encode(NSInteger) at: &myHotKeyModifiers];
        }
    }
    
    return self;
}

#pragma mark -

- (void)encodeWithCoder: (NSCoder *)coder {
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject: myHotKeyName forKey: @"name"];
        [coder encodeInteger: myHotKeyCode forKey: @"keyCode"];
        [coder encodeInteger: myHotKeyModifiers forKey: @"modifiers"];
    } else {
        [coder encodeObject: myHotKeyName];
        [coder encodeValueOfObjCType: @encode(NSInteger) at: &myHotKeyCode];
        [coder encodeValueOfObjCType: @encode(NSInteger) at: &myHotKeyModifiers];
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

+ (ZeroKitHotKey *)clearedHotKey {
    return [[[ZeroKitHotKey alloc] initWithHotKeyCode: 0 hotKeyModifiers: 0] autorelease];
}

+ (ZeroKitHotKey *)clearedHotKeyWithName: (NSString *)name {
    ZeroKitHotKey *hotKey = [[[ZeroKitHotKey alloc] initWithHotKeyCode: 0 hotKeyModifiers: 0] autorelease];
    
    [hotKey setHotKeyName: name];
    
    return hotKey;
}

#pragma mark -

- (NSInteger)handle {
    return myHandle;
}

- (void)setHandle: (NSInteger)handle {
    myHandle = handle;
}

#pragma mark -

- (NSString *)hotKeyName {
    return myHotKeyName;
}

- (void)setHotKeyName: (NSString *)hotKeyName {
    if (myHotKeyName != hotKeyName) {
        [myHotKeyName release];
        
        myHotKeyName = [hotKeyName retain];
    }
}

#pragma mark -

- (ZeroKitHotKeyAction *)hotKeyAction {
    return myHotKeyAction;
}

- (void)setHotKeyAction: (ZeroKitHotKeyAction *)hotKeyAction {
    if (myHotKeyAction != hotKeyAction) {
        [myHotKeyAction release];
        
        myHotKeyAction = [hotKeyAction retain];
    }
}

#pragma mark -

- (NSInteger)hotKeyCode {
    return myHotKeyCode;
}

- (void)setHotKeyCode: (NSInteger)hotKeyCode {
    myHotKeyCode = hotKeyCode;
}

#pragma mark -

- (NSInteger)hotKeyModifiers {
    return myHotKeyModifiers;
}

- (void)setHotKeyModifiers: (NSInteger)hotKeyModifiers {
    myHotKeyModifiers = [ZeroKitHotKeyTranslator convertModifiersToCarbonIfNecessary: hotKeyModifiers];
}

#pragma mark -

- (EventHotKeyRef)hotKeyRef {
    return myHotKeyRef;
}

- (void)setHotKeyRef: (EventHotKeyRef)hotKeyRef {
    myHotKeyRef = hotKeyRef;
}

#pragma mark -

- (BOOL)isClearedHotKey {
    return (myHotKeyCode == 0) && (myHotKeyModifiers == 0);
}

#pragma mark -

- (NSString *)displayString {
    return [[ZeroKitHotKeyTranslator sharedTranslator] translateHotKey: self];
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

- (BOOL)isEqualToHotKey: (ZeroKitHotKey *)hotKey {
    if (hotKey == self) {
        return YES;
    }
    
    if ([hotKey hotKeyCode] != myHotKeyCode) {
        return NO;
    }
    
    if ([hotKey hotKeyModifiers] != myHotKeyModifiers) {
        return NO;
    }
    
    return YES;
}

#pragma mark -

- (void)dealloc {
    [myHotKeyName release];
    [myHotKeyAction release];
    
    [super dealloc];
}

@end
