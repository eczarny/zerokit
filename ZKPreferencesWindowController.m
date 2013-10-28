#import "ZKPreferencesWindowController.h"
#import "ZKPreferencePaneManager.h"
#import "ZKPreferencePaneProtocol.h"
#import "ZKConstants.h"
#import "ZKUtilities.h"

@interface ZKPreferencesWindowController ()

@property (nonatomic) ZKPreferencePaneManager *preferencePaneManager;
@property (nonatomic) NSToolbar *toolbar;
@property (nonatomic) NSMutableDictionary *toolbarItems;

@end

#pragma mark -

@implementation ZKPreferencesWindowController

- (id)init {
    if ((self = [super initWithWindowNibName: ZKPreferencesWindowNibName])) {
        _toolbarItems = [NSMutableDictionary new];
        _preferencePaneManager = [ZKPreferencePaneManager sharedManager];
        
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
    if ([self window].isKeyWindow) {
        [self hidePreferencesWindow: sender];
    } else {
        [self showPreferencesWindow: sender];
    }
}

#pragma mark -

- (void)loadPreferencePanes {
    [_preferencePaneManager loadPreferencePanes];
}

#pragma mark -

- (NSArray *)loadedPreferencePanes {
    if (!_preferencePaneManager.preferencePanesAreReady) {
        [_preferencePaneManager loadPreferencePanes];
    }
    
    return _preferencePaneManager.preferencePanes;
}

#pragma mark -


#pragma mark -

#pragma mark Toolbar Delegate Methods

#pragma mark -

- (NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar *)toolbar {
    return [_preferencePaneManager preferencePaneOrder];
}

- (NSArray *)toolbarDefaultItemIdentifiers: (NSToolbar *)toolbar {
    return [_preferencePaneManager preferencePaneOrder];
}

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar {
    return [_preferencePaneManager preferencePaneOrder];
}

- (NSToolbarItem *)toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *)itemIdentifier willBeInsertedIntoToolbar: (BOOL)flag {
    return _toolbarItems[itemIdentifier];
}

#pragma mark -

- (void)windowDidLoad {
    if (!_toolbar) {
        [self createToolbar];
    }
    
    [self preparePreferencesWindow];
}

#pragma mark -

- (id<ZKPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name {
    return [_preferencePaneManager preferencePaneWithName: name];
}

- (void)displayPreferencePaneWithName: (NSString *)name initialPreferencePane: (BOOL)initialPreferencePane {
    id<ZKPreferencePaneProtocol> preferencePane = [self preferencePaneWithName: name];
    
    NSLog(@"Displaying the %@ preference pane.", name);
    
    if (preferencePane) {
        NSWindow *preferencesWindow = self.window;
        NSView *preferencePaneView = preferencePane.view;
        NSRect preferencesWindowFrame = preferencesWindow.frame;
        NSView *transitionView = [[NSView alloc] initWithFrame: [preferencesWindow.contentView frame]];
        
        preferencesWindow.contentView = transitionView;
        
        preferencesWindowFrame.size.height = preferencePaneView.frame.size.height + (preferencesWindow.frame.size.height - [preferencesWindow.contentView frame].size.height);
        preferencesWindowFrame.size.width = preferencePaneView.frame.size.width;
        preferencesWindowFrame.origin.y += ([[preferencesWindow contentView] frame].size.height - preferencePaneView.frame.size.height);
        
        [preferencesWindow setFrame: preferencesWindowFrame display: YES animate: YES];
        
        NSDictionary *preferencePaneViewAnimation = @{NSViewAnimationTargetKey: preferencePaneView, NSViewAnimationEffectKey: NSViewAnimationFadeInEffect};
        NSArray *preferencePaneViewAnimations = @[preferencePaneViewAnimation];
        NSViewAnimation *viewAnimation = [[NSViewAnimation alloc] initWithViewAnimations: preferencePaneViewAnimations];
        
        preferencesWindow.contentView = preferencePaneView;
        
        if (!initialPreferencePane) {
            viewAnimation.animationBlockingMode = NSAnimationNonblockingThreaded;
            
            [viewAnimation startAnimation];
        }
        
        
        preferencesWindow.showsResizeIndicator = YES;
        
        preferencesWindow.title = name;
    } else {
        NSLog(@"Unable to locate a preference pane with the name: %@", name);
    }
}

#pragma mark -

- (void)preparePreferencesWindow {
    NSWindow *preferencesWindow = self.window;
    NSArray *preferencePaneOrder = _preferencePaneManager.preferencePaneOrder;
    NSString *preferencePaneName = preferencePaneOrder[0];
    
    if (!_preferencePaneManager.preferencePanesAreReady) {
        NSString *applicationName = [NSBundle.mainBundle objectForInfoDictionaryKey: ZKApplicationBundleName];
        
        NSLog(@"No preference panes are available for %@.", applicationName);
    }
    
    _toolbar.selectedItemIdentifier = preferencePaneName;
    
    [self displayPreferencePaneWithName: preferencePaneName initialPreferencePane: YES];
    
    [preferencesWindow center];
}

#pragma mark -

- (void)createToolbar {
    NSWindow *preferencesWindow = self.window;
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSArray *preferencePanes = _preferencePaneManager.preferencePanes;
    NSEnumerator *preferencePaneEnumerator = preferencePanes.objectEnumerator;
    id<ZKPreferencePaneProtocol> preferencePane;
    
    while ((preferencePane = [preferencePaneEnumerator nextObject])) {
        NSString *preferencePaneName = preferencePane.name;
        NSString *preferencePaneToolTip = preferencePane.toolTip;
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: preferencePaneName];
        
        toolbarItem.label = preferencePaneName;
        toolbarItem.image = preferencePane.icon;
        
        if (![ZKUtilities isStringEmpty: preferencePaneToolTip]) {
            toolbarItem.toolTip = preferencePaneToolTip;
        } else {
            toolbarItem.toolTip = nil;
        }
        
        toolbarItem.target = self;
        toolbarItem.action = @selector(toolbarItemWasSelected:);
        
        _toolbarItems[preferencePaneName] = toolbarItem;
    }
    
    _toolbar = [[NSToolbar alloc] initWithIdentifier: bundleIdentifier];
    
    _toolbar.delegate = self;
    _toolbar.allowsUserCustomization = NO;
    _toolbar.autosavesConfiguration = NO;
    
    if (_toolbarItems && (_toolbarItems.count > 0)) {
        preferencesWindow.toolbar = _toolbar;
    } else {
        NSLog(@"No toolbar items were found, the preferences window will not display a toolbar.");
    }
}

#pragma mark -

- (void)toolbarItemWasSelected: (NSToolbarItem *)toolbarItem {
    NSWindow *preferencesWindow = self.window;
    NSString *toolbarItemIdentifier = toolbarItem.itemIdentifier;
    
    if (![toolbarItemIdentifier isEqualToString: preferencesWindow.title]) {
        [self displayPreferencePaneWithName: toolbarItemIdentifier initialPreferencePane: NO];
    }
}

@end
