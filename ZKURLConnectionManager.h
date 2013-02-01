#import <Foundation/Foundation.h>
#import "ZKURLConnectionDelegate.h"

@class ZKURLConnection;

@interface ZKURLConnectionManager : NSObject {
    NSMutableDictionary *connections;
}

+ (ZKURLConnectionManager *)sharedManager;

#pragma mark -

- (NSString *)spawnConnectionWithURLRequest: (NSURLRequest *)request delegate: (id<ZKURLConnectionDelegate>)delegate;

#pragma mark -

- (NSArray *)activeConnectionIdentifiers;

- (NSInteger)numberOfActiveConnections;

#pragma mark -

- (ZKURLConnection *)connectionForIdentifier: (NSString *)identifier;

#pragma mark -

- (void)closeConnectionForIdentifier: (NSString *)identifier;

- (void)closeConnections;

@end
