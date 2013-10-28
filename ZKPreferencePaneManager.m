#import "ZKPreferencePaneManager.h"
#import "ZKPreferencePaneProtocol.h"
#import "ZKUtilities.h"
#import "ZKConstants.h"

@implementation ZKPreferencePaneManager

- (id)init {
    if ((self = [super init])) {
        _preferencePanesByName = [NSMutableDictionary new];
        _preferencePaneOrder = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark -

+ (ZKPreferencePaneManager *)sharedManager {
    static ZKPreferencePaneManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

#pragma mark -

- (BOOL)preferencePanesAreReady {
    return _preferencePanesByName && (_preferencePanesByName.count > 0);
}

#pragma mark -

- (void)loadPreferencePanes {
    NSBundle *applicationBundle = ZKUtilities.applicationBundle;
    NSString *path = [applicationBundle pathForResource: ZKPreferencePanesFile ofType: ZKPropertyListFileExtension];
    NSDictionary *preferencePaneDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSEnumerator *preferencePaneNameEnumerator = [preferencePaneDictionary[ZKPreferencePanesKey] keyEnumerator];
    NSEnumerator *preferencePaneNameOrderEnumerator = [preferencePaneDictionary[ZKPreferencePaneOrderKey] objectEnumerator];
    NSString *preferencePaneName;
    
    NSLog(@"The preference pane manager is loading preference panes from: %@", path);
    
    [_preferencePanesByName removeAllObjects];
    
    while ((preferencePaneName = [preferencePaneNameEnumerator nextObject])) {
        NSString *preferencePaneClassName = _preferencePanesByName[preferencePaneName];
        
        if (preferencePaneClassName) {
            Class preferencePaneClass = [applicationBundle classNamed: preferencePaneClassName];
            
            if (preferencePaneClass) {
                id<ZKPreferencePaneProtocol> preferencePane = [preferencePaneClass new];
                
                if (preferencePane) {
                    [NSBundle loadNibNamed: preferencePaneClassName owner: preferencePane];
                    
                    [preferencePane preferencePaneDidLoad];
                    
                    _preferencePanesByName[preferencePaneName] = preferencePane;
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
    
    [_preferencePaneOrder removeAllObjects];
    
    while ((preferencePaneName = [preferencePaneNameOrderEnumerator nextObject])) {
        if (_preferencePanesByName[preferencePaneName]) {
            NSLog(@"Adding %@ to the preference pane order.", preferencePaneName);
            
            [_preferencePaneOrder addObject: preferencePaneName];
        } else {
            NSLog(@"Unable to set the preference pane order for preference pane named: %@", preferencePaneName);
        }
    }
}

#pragma mark -

- (id<ZKPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name {
    return _preferencePanesByName[name];
}

#pragma mark -

- (NSArray *)preferencePanes {
    return _preferencePanesByName.allValues;
}

- (NSArray *)preferencePaneNames {
    return _preferencePanesByName.allKeys;
}

@end
