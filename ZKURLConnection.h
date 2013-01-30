#import <Foundation/Foundation.h>
#import "ZKURLConnectionDelegate.h"

@class ZKURLConnectionManager;

@interface ZKURLConnection : NSObject {
    ZKURLConnectionManager *myManager;
    NSURLRequest *myRequest;
    NSString *myIdentifier;
    NSMutableData *myData;
    NSURLConnection *myConnection;
    id<ZKURLConnectionDelegate> myDelegate;
}

- (id)initWithURLRequest: (NSURLRequest *)request delegate: (id<ZKURLConnectionDelegate>)delegate manager: (ZKURLConnectionManager *)manager;

#pragma mark -

+ (NSData *)sendSynchronousURLRequest: (NSURLRequest *)request error: (NSError **)error;

#pragma mark -

- (NSString *)identifier;

#pragma mark -

- (id<ZKURLConnectionDelegate>)delegate;

#pragma mark -

- (void)cancel;

@end
