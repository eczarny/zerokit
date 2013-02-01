#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@class ZKHotKey;

typedef void(^ZKHotKeyAction)(ZKHotKey *);

@interface ZKHotKey : NSObject<NSCoding> {
    NSInteger handle;
    NSString *hotKeyName;
    ZKHotKeyAction hotKeyAction;
    NSInteger hotKeyCode;
    NSInteger hotKeyModifiers;
    EventHotKeyRef hotKeyRef;
}

- (id)initWithHotKeyCode: (NSInteger)aHotKeyCode hotKeyModifiers: (NSInteger)theHotKeyModifiers;

#pragma mark -

+ (ZKHotKey *)clearedHotKey;

+ (ZKHotKey *)clearedHotKeyWithName: (NSString *)name;

#pragma mark -

- (NSInteger)handle;

- (void)setHandle: (NSInteger)aHandle;

#pragma mark -

- (NSString *)hotKeyName;

- (void)setHotKeyName: (NSString *)aHotKeyName;

#pragma mark -

- (ZKHotKeyAction)hotKeyAction;

- (void)setHotKeyAction: (ZKHotKeyAction)aHotKeyAction;

#pragma mark -

- (void)triggerHotKeyAction;

#pragma mark -

- (NSInteger)hotKeyCode;

- (void)setHotKeyCode: (NSInteger)aHotKeyCode;

#pragma mark -

- (NSInteger)hotKeyModifiers;

- (void)setHotKeyModifiers: (NSInteger)theHotKeyModifiers;

#pragma mark -

- (EventHotKeyRef)hotKeyRef;

- (void)setHotKeyRef: (EventHotKeyRef)aHotKeyRef;

#pragma mark -

- (BOOL)isClearedHotKey;

#pragma mark -

- (NSString *)displayString;

#pragma mark -

+ (BOOL)validCocoaModifiers: (NSInteger)modifiers;

#pragma mark -

- (BOOL)isEqual: (id)object;

- (BOOL)isEqualToHotKey: (ZKHotKey *)hotKey;

@end
