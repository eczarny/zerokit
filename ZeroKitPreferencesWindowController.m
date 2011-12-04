#import "ZeroKitPreferencesWindowController.h"
#import "ZeroKitPreferencePaneManager.h"
#import "ZeroKitPreferencePaneProtocol.h"
#import "ZeroKitConstants.h"
#import "ZeroKitUtilities.h"

@interface ZeroKitPreferencesWindowController (ZeroKitPreferencesWindowControllerPrivate)

- (void)windowDidLoad;

#pragma mark -

- (id<ZeroKitPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name;

- (void)displayPreferencePaneWithName: (NSString *)name initialPreferencePane: (BOOL)initialPreferencePane;

#pragma mark -

- (void)preparePreferencesWindow;

#pragma mark -

- (void)createToolbar;

#pragma mark -

- (void)toolbarItemWasSelected: (NSToolbarItem *)toolbarItem;

@end

#pragma mark -

@implementation ZeroKitPreferencesWindowController

static ZeroKitPreferencesWindowController *sharedInstance = nil;

- (id)init {
    if ((self = [super initWithWindowNibName: ZeroKitPreferencesWindowNibName])) {
        myToolbarItems = [[NSMutableDictionary alloc] init];
        myPreferencePaneManager = [ZeroKitPreferencePaneManager sharedManager];
        
        [self loadPreferencePanes];
    }
    
    return self;
}

#pragma mark -

+ (id)allocWithZone: (NSZone *)zone {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [super allocWithZone: zone];
            
            return sharedInstance;
        }
    }
    
    return nil;
}

#pragma mark -

+ (ZeroKitPreferencesWindowController *)sharedController {
    @synchronized(self) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
    }
    
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
    [myPreferencePaneManager loadPreferencePanes];
}

#pragma mark -

- (NSArray *)loadedPreferencePanes {
    if (![myPreferencePaneManager preferencePanesAreReady]) {
        [myPreferencePaneManager loadPreferencePanes];
    }
    
    return [myPreferencePaneManager preferencePanes];
}

#pragma mark -

- (void)dealloc {
    [myToolbar release];
    [myToolbarItems release];
    
    [super dealloc];
}

#pragma mark -

#pragma mark Toolbar Delegate Methods

#pragma mark -

- (NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar *)toolbar {
    return [myPreferencePaneManager preferencePaneOrder];
}

- (NSArray *)toolbarDefaultItemIdentifiers: (NSToolbar *)toolbar {
    return [myPreferencePaneManager preferencePaneOrder];
}

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar {
    return [myPreferencePaneManager preferencePaneOrder];
}

- (NSToolbarItem *)toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *)itemIdentifier willBeInsertedIntoToolbar: (BOOL)flag {
    return [myToolbarItems objectForKey: itemIdentifier];
}

@end

#pragma mark -

@implementation ZeroKitPreferencesWindowController (ZeroKitPreferencesWindowControllerPrivate)

- (void)windowDidLoad {
    if (!myToolbar) {
        [self createToolbar];
    }
    
    [self preparePreferencesWindow];
}

#pragma mark -

- (id<ZeroKitPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name {
    return [myPreferencePaneManager preferencePaneWithName: name];
}

- (void)displayPreferencePaneWithName: (NSString *)name initialPreferencePane: (BOOL)initialPreferencePane {
    id<ZeroKitPreferencePaneProtocol> preferencePane = [self preferencePaneWithName: name];
    
    NSLog(@"Displaying the %@ preference pane.", name);
    
    if (preferencePane) {
        NSWindow *preferencesWindow = [self window];
        NSView *preferencePaneView = [preferencePane view];
        NSRect preferencesWindowFrame = [preferencesWindow frame];
        NSView *transitionView = [[NSView alloc] initWithFrame: [[preferencesWindow contentView] frame]];
        
        [preferencesWindow setContentView: transitionView];
        
        [transitionView release]; 
        
        preferencesWindowFrame.size.height = [preferencePaneView frame].size.height + ([preferencesWindow frame].size.height - [[preferencesWindow contentView] frame].size.height);
        preferencesWindowFrame.size.width = [preferencePaneView frame].size.width;
        preferencesWindowFrame.origin.y += ([[preferencesWindow contentView] frame].size.height - [preferencePaneView frame].size.height);
        
        [preferencesWindow setFrame: preferencesWindowFrame display: YES animate: YES];
        
        NSDictionary *preferencePaneViewAnimation = [NSDictionary dictionaryWithObjectsAndKeys: preferencePaneView, NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
        NSArray *preferencePaneViewAnimations = [NSArray arrayWithObjects: preferencePaneViewAnimation, nil];
        NSViewAnimation *viewAnimation = [[NSViewAnimation alloc] initWithViewAnimations: preferencePaneViewAnimations];
        
        [preferencesWindow setContentView: preferencePaneView];
        
        if (!initialPreferencePane) {
            [viewAnimation setAnimationBlockingMode: NSAnimationNonblockingThreaded];
            [viewAnimation startAnimation];
        }
        
        [viewAnimation release];
        
        [preferencesWindow setShowsResizeIndicator: YES];
        
        [preferencesWindow setTitle: name];
    } else {
        NSLog(@"Unable to locate a preference pane with the name: %@", name);
    }
}

#pragma mark -

- (void)preparePreferencesWindow {
    NSWindow *preferencesWindow = [self window];
    NSArray *preferencePaneOrder = [myPreferencePaneManager preferencePaneOrder];
    NSString *preferencePaneName = [preferencePaneOrder objectAtIndex: 0];
    
    if (![myPreferencePaneManager preferencePanesAreReady]) {
        NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey: ZeroKitApplicationBundleName];
        
        NSLog(@"No preference panes are available for %@.", applicationName);
    }
    
    [myToolbar setSelectedItemIdentifier: preferencePaneName];
    
    [self displayPreferencePaneWithName: preferencePaneName initialPreferencePane: YES];
    
    [preferencesWindow center];
}

#pragma mark -

- (void)createToolbar {
    NSWindow *preferencesWindow = [self window];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *preferencePanes = [myPreferencePaneManager preferencePanes];
    NSEnumerator *preferencePaneEnumerator = [preferencePanes objectEnumerator];
    id<ZeroKitPreferencePaneProtocol> preferencePane;
    
    while ((preferencePane = [preferencePaneEnumerator nextObject])) {
        NSString *preferencePaneName = [preferencePane name];
        NSString *preferencePaneToolTip = [preferencePane toolTip];
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: preferencePaneName];
        
        [toolbarItem setLabel: preferencePaneName];
        [toolbarItem setImage: [preferencePane icon]];
        
        if (![ZeroKitUtilities isStringEmpty: preferencePaneToolTip]) {
            [toolbarItem setToolTip: preferencePaneToolTip];
        } else {
            [toolbarItem setToolTip: nil];
        }
        
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(toolbarItemWasSelected:)];
        
        [myToolbarItems setObject: toolbarItem forKey: preferencePaneName];
        
        [toolbarItem release];
    }
    
    myToolbar = [[NSToolbar alloc] initWithIdentifier: bundleIdentifier];
    
    [myToolbar setDelegate: self];
    [myToolbar setAllowsUserCustomization: NO];
    [myToolbar setAutosavesConfiguration: NO];
    
    if (myToolbarItems && ([myToolbarItems count] > 0)) {
        [preferencesWindow setToolbar: myToolbar];
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
