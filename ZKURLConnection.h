#import <Foundation/Foundation.h>
#import "ZKURLConnectionDelegate.h"

@class ZKURLConnectionManager;

@interface ZKURLConnection : NSObject {
    ZKURLConnectionManager *urlConnectionManager;
    NSURLRequest *request;
    NSString *identifier;
    NSMutableData *data;
    NSURLConnection *connection;
    id<ZKURLConnectionDelegate> delegate;
}

- (id)initWithURLRequest: (NSURLRequest *)aRequest delegate: (id<ZKURLConnectionDelegate>)aDelegate manager: (ZKURLConnectionManager *)aManager;

#pragma mark -

+ (NSData *)sendSynchronousURLRequest: (NSURLRequest *)aRequest error: (NSError **)error;

#pragma mark -

- (NSString *)identifier;

#pragma mark -

- (id<ZKURLConnectionDelegate>)delegate;

#pragma mark -

- (void)cancel;

@end
