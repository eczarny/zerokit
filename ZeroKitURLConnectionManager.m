#import "ZeroKitURLConnectionManager.h"
#import "ZeroKitURLConnection.h"

@implementation ZeroKitURLConnectionManager

static ZeroKitURLConnectionManager *sharedInstance = nil;

- (id)init {
    if ((self = [super init])) {
        myConnections = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark -

+ (ZeroKitURLConnectionManager *)sharedManager {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [self new];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

- (NSString *)spawnConnectionWithURLRequest: (NSURLRequest *)request delegate: (id<ZeroKitURLConnectionDelegate>)delegate {
    ZeroKitURLConnection *newConnection = [[ZeroKitURLConnection alloc] initWithURLRequest: request delegate: delegate manager: self];
    NSString *identifier = [newConnection identifier];
    
    myConnections[identifier] = newConnection;
    
    return identifier;
}

#pragma mark -

- (NSArray *)activeConnectionIdentifiers {
    return [myConnections allKeys];
}

- (NSInteger)numberOfActiveConnections {
    return [myConnections count];
}

#pragma mark -

- (ZeroKitURLConnection *)connectionForIdentifier: (NSString *)identifier {
    return myConnections[identifier];
}

#pragma mark -

- (void)closeConnectionForIdentifier: (NSString *)identifier {
    ZeroKitURLConnection *selectedConnection = [self connectionForIdentifier: identifier];
    
    if (selectedConnection) {
        [selectedConnection cancel];
        
        [myConnections removeObjectForKey: identifier];
    }
}

- (void)closeConnections {
    [[myConnections allValues] makeObjectsPerformSelector: @selector(cancel)];
    
    [myConnections removeAllObjects];
}

#pragma mark -

- (void)finalize {
    [self closeConnections];
    
    [super finalize];
}

#pragma mark -

- (void)dealloc {
    [self closeConnections];
}

@end
