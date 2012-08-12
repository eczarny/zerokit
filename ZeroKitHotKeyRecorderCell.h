#import <Cocoa/Cocoa.h>
#import "ZeroKitHotKeyRecorderDelegate.h"

@class ZeroKitHotKeyRecorder, ZeroKitHotKey;

@interface ZeroKitHotKeyRecorderCell : NSCell {
    ZeroKitHotKeyRecorder *myHotKeyRecorder;
    NSString *myHotKeyName;
    ZeroKitHotKey *myHotKey;
    id<ZeroKitHotKeyRecorderDelegate> myDelegate;
    NSArray *myAdditionalHotKeyValidators;
    NSInteger myModifierFlags;
    BOOL isRecording;
    NSTrackingArea *myTrackingArea;
    BOOL isMouseAboveBadge;
    BOOL isMouseDown;
    void *myHotKeyMode;
}

- (void)setHotKeyRecorder: (ZeroKitHotKeyRecorder *)hotKeyRecorder;

#pragma mark -

- (NSString *)hotKeyName;

- (void)setHotKeyName: (NSString *)hotKeyName;

#pragma mark -

- (ZeroKitHotKey *)hotKey;

- (void)setHotKey: (ZeroKitHotKey *)hotKey;

#pragma mark -

- (id<ZeroKitHotKeyRecorderDelegate>)delegate;

- (void)setDelegate: (id<ZeroKitHotKeyRecorderDelegate>)delegate;

#pragma mark -

- (void)setAdditionalHotKeyValidators: (NSArray *)additionalHotKeyValidators;

#pragma mark -

- (BOOL)resignFirstResponder;

#pragma mark -

- (BOOL)performKeyEquivalent: (NSEvent *)event;

- (void)flagsChanged: (NSEvent *)event;

@end
