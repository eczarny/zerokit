#import "ZeroKitPreferencePaneManager.h"
#import "ZeroKitPreferencePaneProtocol.h"
#import "ZeroKitUtilities.h"
#import "ZeroKitConstants.h"

@implementation ZeroKitPreferencePaneManager

static ZeroKitPreferencePaneManager *sharedInstance = nil;

- (id)init {
    if ((self = [super init])) {
        myPreferencePanes = [NSMutableDictionary new];
        myPreferencePaneOrder = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark -

+ (ZeroKitPreferencePaneManager *)sharedManager {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [self new];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

- (BOOL)preferencePanesAreReady {
    return myPreferencePanes && ([myPreferencePanes count] > 0);
}

#pragma mark -

- (void)loadPreferencePanes {
    NSBundle *applicationBundle = [ZeroKitUtilities applicationBundle];
    NSString *path = [applicationBundle pathForResource: ZeroKitPreferencePanesFile ofType: ZeroKitPropertyListFileExtension];
    NSDictionary *preferencePaneDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSDictionary *preferencePanes = preferencePaneDictionary[ZeroKitPreferencePanesKey];
    NSArray *preferencePaneOrder = preferencePaneDictionary[ZeroKitPreferencePaneOrderKey];
    NSEnumerator *preferencePaneNameEnumerator = [preferencePanes keyEnumerator];
    NSEnumerator *preferencePaneNameOrderEnumerator = [preferencePaneOrder objectEnumerator];
    NSString *preferencePaneName;
    
    NSLog(@"The preference pane manager is loading preference panes from: %@", path);
    
    [myPreferencePanes removeAllObjects];
    
    while ((preferencePaneName = [preferencePaneNameEnumerator nextObject])) {
        NSString *preferencePaneClassName = preferencePanes[preferencePaneName];
        
        if (preferencePaneClassName) {
            Class preferencePaneClass = [applicationBundle classNamed: preferencePaneClassName];
            
            if (preferencePaneClass) {
                id<ZeroKitPreferencePaneProtocol> preferencePane = [preferencePaneClass new];
                
                if (preferencePane) {
                    [NSBundle loadNibNamed: preferencePaneClassName owner: preferencePane];
                    
                    [preferencePane preferencePaneDidLoad];
                    
                    myPreferencePanes[preferencePaneName] = preferencePane;
                } else {
                    NSLog(@"Failed initializing preference pane named: %@", preferencePaneName);
                }
            } else {
                NSLog(@"Unable to load preference pane with class named: %@", preferencePaneClassName);
            }
        } else {
            NSLog(@"The preference pane, %@, is missing a class name!", preferencePaneName);
        }
    }
    
    [myPreferencePaneOrder removeAllObjects];
    
    while ((preferencePaneName = [preferencePaneNameOrderEnumerator nextObject])) {
        if (myPreferencePanes[preferencePaneName]) {
            NSLog(@"Adding %@ to the preference pane order.", preferencePaneName);
            
            [myPreferencePaneOrder addObject: preferencePaneName];
        } else {
            NSLog(@"Unable to set the preference pane order for preference pane named: %@", preferencePaneName);
        }
    }
}

#pragma mark -

- (id<ZeroKitPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name {
    return myPreferencePanes[name];
}

#pragma mark -

- (NSArray *)preferencePanes {
    return [myPreferencePanes allValues];
}

- (NSArray *)preferencePaneNames {
    return [myPreferencePanes allKeys];
}

#pragma mark -

- (NSArray *)preferencePaneOrder {
    return myPreferencePaneOrder;
}

@end
