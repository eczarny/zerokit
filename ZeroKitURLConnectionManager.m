// 
// Copyright (c) 2011 Eric Czarny <eczarny@gmail.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of  this  software  and  associated documentation files (the "Software"), to
// deal  in  the Software without restriction, including without limitation the
// rights  to  use,  copy,  modify,  merge,  publish,  distribute,  sublicense,
// and/or sell copies  of  the  Software,  and  to  permit  persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED,  INCLUDING  BUT  NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY,  WHETHER  IN  AN  ACTION  OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
// 

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
