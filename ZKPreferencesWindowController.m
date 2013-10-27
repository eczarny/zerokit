#import "ZKPreferencesWindowController.h"
#import "ZKPreferencePaneManager.h"
#import "ZKPreferencePaneProtocol.h"
#import "ZKConstants.h"
#import "ZKUtilities.h"

@interface ZKPreferencesWindowController (ZKPreferencesWindowControllerPrivate)

- (void)windowDidLoad;

#pragma mark -

- (id<ZKPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name;

- (void)displayPreferencePaneWithName: (NSString *)name initialPreferencePane: (BOOL)initialPreferencePane;

#pragma mark -

- (void)preparePreferencesWindow;

#pragma mark -

- (void)createToolbar;

#pragma mark -

- (void)toolbarItemWasSelected: (NSToolbarItem *)toolbarItem;

@end

#pragma mark -

@implementation ZKPreferencesWindowController

- (id)init {
    if ((self = [super initWithWindowNibName: ZKPreferencesWindowNibName])) {
        toolbarItems = [NSMutableDictionary new];
        preferencePaneManager = [ZKPreferencePaneManager sharedManager];
        
        [self loadPreferencePanes];
    }
    
    return self;
}

#pragma mark -

+ (ZKPreferencesWindowController *)sharedController {
    static ZKPreferencesWindowController *sharedInstance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

#pragma mark -

- (void)showPreferencesWindow: (id)sender {
    [self showWindow: sender];
}

- (void)hidePreferencesWindow: (id)sender {
    [self close];
}

#pragma mark -

- (void)togglePreferencesWindow: (id)sender {
    if ([[self window] isKeyWindow]) {
        [self hidePreferencesWindow: sender];
    } else {
        [self showPreferencesWindow: sender];
    }
}

#pragma mark -

- (void)loadPreferencePanes {
    [preferencePaneManager loadPreferencePanes];
}

#pragma mark -

- (NSArray *)loadedPreferencePanes {
    if (![preferencePaneManager preferencePanesAreReady]) {
        [preferencePaneManager loadPreferencePanes];
    }
    
    return [preferencePaneManager preferencePanes];
}

#pragma mark -


#pragma mark -

#pragma mark Toolbar Delegate Methods

#pragma mark -

- (NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar *)toolbar {
    return [preferencePaneManager preferencePaneOrder];
}

- (NSArray *)toolbarDefaultItemIdentifiers: (NSToolbar *)toolbar {
    return [preferencePaneManager preferencePaneOrder];
}

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar {
    return [preferencePaneManager preferencePaneOrder];
}

- (NSToolbarItem *)toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *)itemIdentifier willBeInsertedIntoToolbar: (BOOL)flag {
    return toolbarItems[itemIdentifier];
}

@end

#pragma mark -

@implementation ZKPreferencesWindowController (ZKPreferencesWindowControllerPrivate)

- (void)windowDidLoad {
    if (!toolbar) {
        [self createToolbar];
    }
    
    [self preparePreferencesWindow];
}

#pragma mark -

- (id<ZKPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name {
    return [preferencePaneManager preferencePaneWithName: name];
}

- (void)displayPreferencePaneWithName: (NSString *)name initialPreferencePane: (BOOL)initialPreferencePane {
    id<ZKPreferencePaneProtocol> preferencePane = [self preferencePaneWithName: name];
    
    NSLog(@"Displaying the %@ preference pane.", name);
    
    if (preferencePane) {
        NSWindow *preferencesWindow = [self window];
        NSView *preferencePaneView = [preferencePane view];
        NSRect preferencesWindowFrame = [preferencesWindow frame];
        NSView *transitionView = [[NSView alloc] initWithFrame: [[preferencesWindow contentView] frame]];
        
        [preferencesWindow setContentView: transitionView];
        
        
        preferencesWindowFrame.size.height = [preferencePaneView frame].size.height + ([preferencesWindow frame].size.height - [[preferencesWindow contentView] frame].size.height);
        preferencesWindowFrame.size.width = [preferencePaneView frame].size.width;
        preferencesWindowFrame.origin.y += ([[preferencesWindow contentView] frame].size.height - [preferencePaneView frame].size.height);
        
        [preferencesWindow setFrame: preferencesWindowFrame display: YES animate: YES];
        
        NSDictionary *preferencePaneViewAnimation = @{NSViewAnimationTargetKey: preferencePaneView, NSViewAnimationEffectKey: NSViewAnimationFadeInEffect};
        NSArray *preferencePaneViewAnimations = @[preferencePaneViewAnimation];
        NSViewAnimation *viewAnimation = [[NSViewAnimation alloc] initWithViewAnimations: preferencePaneViewAnimations];
        
        [preferencesWindow setContentView: preferencePaneView];
        
        if (!initialPreferencePane) {
            [viewAnimation setAnimationBlockingMode: NSAnimationNonblockingThreaded];
            [viewAnimation startAnimation];
        }
        
        
        [preferencesWindow setShowsResizeIndicator: YES];
        
        [preferencesWindow setTitle: name];
    } else {
        NSLog(@"Unable to locate a preference pane with the name: %@", name);
    }
}

#pragma mark -

- (void)preparePreferencesWindow {
    NSWindow *preferencesWindow = [self window];
    NSArray *preferencePaneOrder = [preferencePaneManager preferencePaneOrder];
    NSString *preferencePaneName = preferencePaneOrder[0];
    
    if (![preferencePaneManager preferencePanesAreReady]) {
        NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey: ZKApplicationBundleName];
        
        NSLog(@"No preference panes are available for %@.", applicationName);
    }
    
    [toolbar setSelectedItemIdentifier: preferencePaneName];
    
    [self displayPreferencePaneWithName: preferencePaneName initialPreferencePane: YES];
    
    [preferencesWindow center];
}

#pragma mark -

- (void)createToolbar {
    NSWindow *preferencesWindow = [self window];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *preferencePanes = [preferencePaneManager preferencePanes];
    NSEnumerator *preferencePaneEnumerator = [preferencePanes objectEnumerator];
    id<ZKPreferencePaneProtocol> preferencePane;
    
    while ((preferencePane = [preferencePaneEnumerator nextObject])) {
        NSString *preferencePaneName = [preferencePane name];
        NSString *preferencePaneToolTip = [preferencePane toolTip];
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: preferencePaneName];
        
        [toolbarItem setLabel: preferencePaneName];
        [toolbarItem setImage: [preferencePane icon]];
        
        if (![ZKUtilities isStringEmpty: preferencePaneToolTip]) {
            [toolbarItem setToolTip: preferencePaneToolTip];
        } else {
            [toolbarItem setToolTip: nil];
        }
        
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(toolbarItemWasSelected:)];
        
        toolbarItems[preferencePaneName] = toolbarItem;
        
    }
    
    toolbar = [[NSToolbar alloc] initWithIdentifier: bundleIdentifier];
    
    [toolbar setDelegate: self];
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setAutosavesConfiguration: NO];
    
    if (toolbarItems && ([toolbarItems count] > 0)) {
        [preferencesWindow setToolbar: toolbar];
    } else {
        NSLog(@"No toolbar items were found, the preferences window will not display a toolbar.");
    }
}

#pragma mark -

- (void)toolbarItemWasSelected: (NSToolbarItem *)toolbarItem {
    NSWindow *preferencesWindow = [self window];
    NSString *toolbarItemIdentifier = [toolbarItem itemIdentifier];
    
    if (![toolbarItemIdentifier isEqualToString: [preferencesWindow title]]) {
        [self displayPreferencePaneWithName: toolbarItemIdentifier initialPreferencePane: NO];
    }
}

@end
