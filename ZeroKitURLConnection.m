#import "ZeroKitURLConnection.h"
#import "ZeroKitURLConnectionManager.h"
#import "NSStringAdditions.h"

@interface ZeroKitURLConnection (ZeroKitURLConnectionPrivate)

- (void)connection: (NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data;

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error;

#pragma mark -

- (BOOL)connection: (NSURLConnection *)connection canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace;

- (void)connection: (NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)connection: (NSURLConnection *)connection didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)connectionDidFinishLoading: (NSURLConnection *)connection;

@end

#pragma mark -

@implementation ZeroKitURLConnection

- (id)initWithURLRequest: (NSURLRequest *)request delegate: (id<ZeroKitURLConnectionDelegate>)delegate manager: (ZeroKitURLConnectionManager *)manager {
    if ((self = [super init])) {
        myManager = [manager retain];
        myRequest = [request retain];
        myIdentifier = [[NSString stringByGeneratingUUID] retain];
        myData = [[NSMutableData alloc] init];
        
        myConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
        
        myDelegate = [delegate retain];
        
        if (myConnection) {
            NSLog(@"The connection, %@, has been established!", myIdentifier);
        } else {
            NSLog(@"The connection, %@, could not be established!", myIdentifier);
            
            [self release];
            
            return nil;
        }
    }
    
    return self;
}

#pragma mark -

+ (NSData *)sendSynchronousURLRequest: (NSURLRequest *)request error: (NSError **)error {
    NSData *data = [[[NSURLConnection sendSynchronousRequest: request returningResponse: nil error: error] retain] autorelease];
    
    if (!data) {
        return nil;
    }
    
    return data;
}

#pragma mark -

- (NSString *)identifier {
    return [[myIdentifier retain] autorelease];
}

#pragma mark -

- (id<ZeroKitURLConnectionDelegate>)delegate {
    return myDelegate;
}

#pragma mark -

- (void)cancel {
    [myConnection cancel];
}

#pragma mark -

- (void)dealloc {    
    [myManager release];
    [myRequest release];
    [myIdentifier release];
    [myData release];
    [myConnection release];
    [myDelegate release];
    
    [super dealloc];
}

@end

#pragma mark -

@implementation ZeroKitURLConnection (ZeroKitURLConnectionPrivate)

- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    if([response respondsToSelector: @selector(statusCode)]) {
        int statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        if(statusCode >= 400) {
            NSError *error = [NSError errorWithDomain: @"HTTP" code: statusCode userInfo: nil];
            
            [myDelegate request: myRequest didFailWithError: error];
        } else if (statusCode == 304) {
            [myManager closeConnectionForIdentifier: myIdentifier];
        }
    }
    
    [myData setLength: 0];
}

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data {
    [myData appendData: data];
}

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error {
    NSURLRequest *request = [[myRequest retain] autorelease];
    
    NSLog(@"The connection, %@, failed with the following error: %@", myIdentifier, [error localizedDescription]);
    
    [myDelegate request: request didFailWithError: error];
    
    [myManager closeConnectionForIdentifier: myIdentifier];
}

#pragma mark -

- (BOOL)connection: (NSURLConnection *)connection canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace {
    return [myDelegate request: myRequest canAuthenticateAgainstProtectionSpace: protectionSpace];
}

- (void)connection: (NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    [myDelegate request: myRequest didReceiveAuthenticationChallenge: challenge];
}

- (void)connection: (NSURLConnection *)connection didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    [myDelegate request: myRequest didCancelAuthenticationChallenge: challenge];
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection {
    if (myData && ([myData length] > 0)) {
        NSURLRequest *request = [[myRequest retain] autorelease];
        
        [myDelegate request: request didReceiveData: myData];
    }
    
    [myManager closeConnectionForIdentifier: myIdentifier];
}

@end
