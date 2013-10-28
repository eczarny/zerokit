#import <Foundation/Foundation.h>
#import "ZKPreferencePaneProtocol.h"

@interface ZKPreferencePaneManager : NSObject

@property (nonatomic, readonly) NSMutableDictionary *preferencePanesByName;
@property (nonatomic, readonly) NSMutableArray *preferencePaneOrder;

#pragma mark -

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

@end
