#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class ZKPreferencePaneManager;

@interface ZKPreferencesWindowController : NSWindowController<NSToolbarDelegate> {
    ZKPreferencePaneManager *preferencePaneManager;
    NSToolbar *toolbar;
    NSMutableDictionary *toolbarItems;
}

+ (ZKPreferencesWindowController *)sharedController;

#pragma mark -

- (void)showPreferencesWindow: (id)sender;

- (void)hidePreferencesWindow: (id)sender;

#pragma mark -

- (void)togglePreferencesWindow: (id)sender;

#pragma mark -

- (void)loadPreferencePanes;

#pragma mark -

- (NSArray *)loadedPreferencePanes;

@end
