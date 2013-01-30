#import "ZKURLConnectionManager.h"
#import "ZKURLConnection.h"

@implementation ZKURLConnectionManager

static ZKURLConnectionManager *sharedInstance = nil;

- (id)init {
    if ((self = [super init])) {
        myConnections = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark -

+ (ZKURLConnectionManager *)sharedManager {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [self new];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

- (NSString *)spawnConnectionWithURLRequest: (NSURLRequest *)request delegate: (id<ZKURLConnectionDelegate>)delegate {
    ZKURLConnection *newConnection = [[ZKURLConnection alloc] initWithURLRequest: request delegate: delegate manager: self];
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

- (ZKURLConnection *)connectionForIdentifier: (NSString *)identifier {
    return myConnections[identifier];
}

#pragma mark -

- (void)closeConnectionForIdentifier: (NSString *)identifier {
    ZKURLConnection *selectedConnection = [self connectionForIdentifier: identifier];
    
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
