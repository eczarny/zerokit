#import <Foundation/Foundation.h>
#import "ZKPreferencePaneProtocol.h"

@interface ZKPreferencePaneManager : NSObject {
    NSMutableDictionary *preferencePanes;
    NSMutableArray *preferencePaneOrder;
}

+ (ZKPreferencePaneManager *)sharedManager;

#pragma mark -

- (BOOL)preferencePanesAreReady;

#pragma mark -

- (void)loadPreferencePanes;

#pragma mark -

- (id<ZKPreferencePaneProtocol>)preferencePaneWithName: (NSString *)name;

#pragma mark -

- (NSArray *)preferencePanes;

- (NSArray *)preferencePaneNames;

#pragma mark -

- (NSArray *)preferencePaneOrder;

@end
