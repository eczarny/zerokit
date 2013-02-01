#import <Cocoa/Cocoa.h>
#import "ZKHotKeyRecorderDelegate.h"

@class ZKHotKeyRecorder, ZKHotKey;

@interface ZKHotKeyRecorderCell : NSCell {
    ZKHotKeyRecorder *hotKeyRecorder;
    NSString *hotKeyName;
    ZKHotKey *hotKey;
    id<ZKHotKeyRecorderDelegate> delegate;
    NSArray *additionalHotKeyValidators;
    NSInteger modifierFlags;
    BOOL isRecording;
    NSTrackingArea *trackingArea;
    BOOL isMouseAboveBadge;
    BOOL isMouseDown;
    void *hotKeyMode;
}

- (void)setHotKeyRecorder: (ZKHotKeyRecorder *)aHotKeyRecorder;

#pragma mark -

- (NSString *)hotKeyName;

- (void)setHotKeyName: (NSString *)aHotKeyName;

#pragma mark -

- (ZKHotKey *)hotKey;

- (void)setHotKey: (ZKHotKey *)aHotKey;

#pragma mark -

- (id<ZKHotKeyRecorderDelegate>)delegate;

- (void)setDelegate: (id<ZKHotKeyRecorderDelegate>)aDelegate;

#pragma mark -

- (void)setAdditionalHotKeyValidators: (NSArray *)theAdditionalHotKeyValidators;

#pragma mark -

- (BOOL)resignFirstResponder;

#pragma mark -

- (BOOL)performKeyEquivalent: (NSEvent *)event;

- (void)flagsChanged: (NSEvent *)event;

@end
