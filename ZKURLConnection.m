#import "ZKURLConnection.h"
#import "ZKURLConnectionManager.h"
#import "NSStringAdditions.h"

@interface ZKURLConnection (ZKURLConnectionPrivate)

- (void)connection: (NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)theData;

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error;

#pragma mark -

- (BOOL)connection: (NSURLConnection *)connection canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace;

- (void)connection: (NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)connection: (NSURLConnection *)connection didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)connectionDidFinishLoading: (NSURLConnection *)connection;

@end

#pragma mark -

@implementation ZKURLConnection

- (id)initWithURLRequest: (NSURLRequest *)aRequest delegate: (id<ZKURLConnectionDelegate>)aDelegate manager: (ZKURLConnectionManager *)aManager {
    if ((self = [super init])) {
        urlConnectionManager = aManager;
        request = aRequest;
        identifier = [NSString stringByGeneratingUUID];
        data = [NSMutableData new];
        
        connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
        
        delegate = aDelegate;
        
        if (connection) {
            NSLog(@"The connection, %@, has been established!", identifier);
        } else {
            NSLog(@"The connection, %@, could not be established!", identifier);
            
            return nil;
        }
    }
    
    return self;
}

#pragma mark -

+ (NSData *)sendSynchronousURLRequest: (NSURLRequest *)aRequest error: (NSError **)error {
    NSData *data = [NSURLConnection sendSynchronousRequest: aRequest returningResponse: nil error: error];
    
    if (!data) {
        return nil;
    }
    
    return data;
}

#pragma mark -

- (NSString *)identifier {
    return identifier;
}

#pragma mark -

- (id<ZKURLConnectionDelegate>)delegate {
    return delegate;
}

#pragma mark -

- (void)cancel {
    [connection cancel];
}

@end

#pragma mark -

@implementation ZKURLConnection (ZKURLConnectionPrivate)

- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    if([response respondsToSelector: @selector(statusCode)]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        if(statusCode >= 400) {
            NSError *error = [NSError errorWithDomain: @"HTTP" code: statusCode userInfo: nil];
            
            [delegate request: request didFailWithError: error];
        } else if (statusCode == 304) {
            [urlConnectionManager closeConnectionForIdentifier: identifier];
        }
    }
    
    [data setLength: 0];
}

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)theData {
    [data appendData: theData];
}

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error {
    NSLog(@"The connection, %@, failed with the following error: %@", identifier, [error localizedDescription]);
    
    [delegate request: request didFailWithError: error];
    
    [urlConnectionManager closeConnectionForIdentifier: identifier];
}

#pragma mark -

- (BOOL)connection: (NSURLConnection *)connection canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace {
    return [delegate request: request canAuthenticateAgainstProtectionSpace: protectionSpace];
}

- (void)connection: (NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    [delegate request: request didReceiveAuthenticationChallenge: challenge];
}

- (void)connection: (NSURLConnection *)connection didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    [delegate request: request didCancelAuthenticationChallenge: challenge];
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection {
    if (data && ([data length] > 0)) {
        [delegate request: request didReceiveData: data];
    }
    
    [urlConnectionManager closeConnectionForIdentifier: identifier];
}

@end
