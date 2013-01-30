#import <Cocoa/Cocoa.h>
#import "ZKHotKeyRecorderDelegate.h"

@class ZKHotKeyRecorder, ZKHotKey;

@interface ZKHotKeyRecorderCell : NSCell {
    ZKHotKeyRecorder *myHotKeyRecorder;
    NSString *myHotKeyName;
    ZKHotKey *myHotKey;
    id<ZKHotKeyRecorderDelegate> myDelegate;
    NSArray *myAdditionalHotKeyValidators;
    NSInteger myModifierFlags;
    BOOL isRecording;
    NSTrackingArea *myTrackingArea;
    BOOL isMouseAboveBadge;
    BOOL isMouseDown;
    void *myHotKeyMode;
}

- (void)setHotKeyRecorder: (ZKHotKeyRecorder *)hotKeyRecorder;

#pragma mark -

- (NSString *)hotKeyName;

- (void)setHotKeyName: (NSString *)hotKeyName;

#pragma mark -

- (ZKHotKey *)hotKey;

- (void)setHotKey: (ZKHotKey *)hotKey;

#pragma mark -

- (id<ZKHotKeyRecorderDelegate>)delegate;

- (void)setDelegate: (id<ZKHotKeyRecorderDelegate>)delegate;

#pragma mark -

- (void)setAdditionalHotKeyValidators: (NSArray *)additionalHotKeyValidators;

#pragma mark -

- (BOOL)resignFirstResponder;

#pragma mark -

- (BOOL)performKeyEquivalent: (NSEvent *)event;

- (void)flagsChanged: (NSEvent *)event;

@end
