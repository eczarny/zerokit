#import <Foundation/Foundation.h>

@protocol ZKPreferencePaneProtocol<NSObject>

- (void)preferencePaneDidLoad;

#pragma mark -

- (NSString *)name;

#pragma mark -

- (NSImage *)icon;

#pragma mark -

- (NSString *)toolTip;

#pragma mark -

- (NSView *)view;

@end
