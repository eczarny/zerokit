#import <Cocoa/Cocoa.h>

@class ZeroKitHotKeyRecorder, ZeroKitHotKey;

@protocol ZeroKitHotKeyRecorderDelegate

- (void)hotKeyRecorder: (ZeroKitHotKeyRecorder *)hotKeyRecorder didReceiveNewHotKey: (ZeroKitHotKey *)hotKey;

- (void)hotKeyRecorder: (ZeroKitHotKeyRecorder *)hotKeyRecorder didClearExistingHotKey: (ZeroKitHotKey *)hotKey;

@end
