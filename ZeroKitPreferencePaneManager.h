#import <Foundation/Foundation.h>
#import "ZeroKitPreferencePaneProtocol.h"

@interface ZeroKitPreferencePaneManager : NSObject {
    NSMutableDictionary *myPreferencePanes;
    NSMutableArray *myPreferencePaneOrder;
}

+ (ZeroKitPreferencePaneManager *)sharedManager;

#pragma mark -

- (BOOL)preferencePanesAreReady;

#pragma mark -

- (void)loadPreferencePanes;

#pragma mark -

- (id<ZeroKitPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name;

#pragma mark -

- (NSArray *)preferencePanes;

- (NSArray *)preferencePaneNames;

#pragma mark -

- (NSArray *)preferencePaneOrder;

@end
