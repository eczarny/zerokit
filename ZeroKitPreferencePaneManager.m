#import "ZeroKitPreferencePaneManager.h"
#import "ZeroKitPreferencePaneProtocol.h"
#import "ZeroKitUtilities.h"
#import "ZeroKitConstants.h"

@implementation ZeroKitPreferencePaneManager

static ZeroKitPreferencePaneManager *sharedInstance = nil;

- (id)init {
    if ((self = [super init])) {
        myPreferencePanes = [[NSMutableDictionary alloc] init];
        myPreferencePaneOrder = [[NSMutableArray alloc] init];
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

+ (ZeroKitPreferencePaneManager *)sharedManager {
    @synchronized(self) {
        if (!sharedInstance) {
            [[self alloc] init];
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
    NSDictionary *preferencePaneDictionary = [[[NSMutableDictionary alloc] initWithContentsOfFile: path] autorelease];
    NSDictionary *preferencePanes = [preferencePaneDictionary objectForKey: ZeroKitPreferencePanesKey];
    NSArray *preferencePaneOrder = [preferencePaneDictionary objectForKey: ZeroKitPreferencePaneOrderKey];
    NSEnumerator *preferencePaneNameEnumerator = [preferencePanes keyEnumerator];
    NSEnumerator *preferencePaneNameOrderEnumerator = [preferencePaneOrder objectEnumerator];
    NSString *preferencePaneName;
    
    NSLog(@"The preference pane manager is loading preference panes from: %@", path);
    
    [myPreferencePanes removeAllObjects];
    
    while ((preferencePaneName = [preferencePaneNameEnumerator nextObject])) {
        NSString *preferencePaneClassName = [preferencePanes objectForKey: preferencePaneName];
        
        if (preferencePaneClassName) {
            Class preferencePaneClass = [applicationBundle classNamed: preferencePaneClassName];
            
            if (preferencePaneClass) {
                id<ZeroKitPreferencePaneProtocol> preferencePane = [[[preferencePaneClass alloc] init] autorelease];
                
                if (preferencePane) {
                    [NSBundle loadNibNamed: preferencePaneClassName owner: preferencePane];
                    
                    [preferencePane preferencePaneDidLoad];
                    
                    [myPreferencePanes setObject: preferencePane forKey: preferencePaneName];
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
        if ([myPreferencePanes objectForKey: preferencePaneName]) {
            NSLog(@"Adding %@ to the preference pane order.", preferencePaneName);
            
            [myPreferencePaneOrder addObject: preferencePaneName];
        } else {
            NSLog(@"Unable to set the preference pane order for preference pane named: %@", preferencePaneName);
        }
    }
}

#pragma mark -

- (id<ZeroKitPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name {
    return [myPreferencePanes objectForKey: name];
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

#pragma mark -

- (void)dealloc {
    [myPreferencePanes release];
    [myPreferencePaneOrder release];
    
    [super dealloc];
}

@end
