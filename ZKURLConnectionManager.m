#import "ZKURLConnectionManager.h"
#import "ZKURLConnection.h"

@implementation ZKURLConnectionManager

static ZKURLConnectionManager *sharedInstance = nil;

- (id)init {
    if ((self = [super init])) {
        connections = [NSMutableDictionary new];
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
    
    connections[identifier] = newConnection;
    
    return identifier;
}

#pragma mark -

- (NSArray *)activeConnectionIdentifiers {
    return [connections allKeys];
}

- (NSInteger)numberOfActiveConnections {
    return [connections count];
}

#pragma mark -

- (ZKURLConnection *)connectionForIdentifier: (NSString *)identifier {
    return connections[identifier];
}

#pragma mark -

- (void)closeConnectionForIdentifier: (NSString *)identifier {
    ZKURLConnection *selectedConnection = [self connectionForIdentifier: identifier];
    
    if (selectedConnection) {
        [selectedConnection cancel];
        
        [connections removeObjectForKey: identifier];
    }
}

- (void)closeConnections {
    [[connections allValues] makeObjectsPerformSelector: @selector(cancel)];
    
    [connections removeAllObjects];
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
