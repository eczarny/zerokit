#import "ZeroKitURLConnectionManager.h"
#import "ZeroKitURLConnection.h"

@implementation ZeroKitURLConnectionManager

static ZeroKitURLConnectionManager *sharedInstance = nil;

- (id)init {
    if ((self = [super init])) {
        myConnections = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark -

+ (id)allocWithZone: (NSZone *)zone {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [super allocWithZone: zone];
            
            return sharedInstance;
        }
    }
    
    return nil;
}

#pragma mark -

+ (ZeroKitURLConnectionManager *)sharedManager {
    @synchronized(self) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

- (NSString *)spawnConnectionWithURLRequest: (NSURLRequest *)request delegate: (id<ZeroKitURLConnectionDelegate>)delegate {
    ZeroKitURLConnection *newConnection = [[ZeroKitURLConnection alloc] initWithURLRequest: request delegate: delegate manager: self];
    NSString *identifier = [[[newConnection identifier] retain] autorelease];
    
    [myConnections setObject: newConnection forKey: identifier];
    
    [newConnection release];
    
    return identifier;
}

#pragma mark -

- (NSArray *)activeConnectionIdentifiers {
    return [myConnections allKeys];
}

- (int)numberOfActiveConnections {
    return [myConnections count];
}

#pragma mark -

- (ZeroKitURLConnection *)connectionForIdentifier: (NSString *)identifier {
    return [myConnections objectForKey: identifier];
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
    
    [myConnections release];
    
    [super dealloc];
}

@end
