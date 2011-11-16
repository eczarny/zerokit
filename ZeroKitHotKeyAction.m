#import "ZeroKitHotKeyAction.h"

@implementation ZeroKitHotKeyAction

- (id)initWithTarget: (id)target selector: (SEL)selector {
    if (self = [super init]) {
        myTarget = target;
        mySelector = selector;
    }
    
    return self;
}

#pragma mark -

+ (ZeroKitHotKeyAction *)hotKeyActionFromTarget: (id)target selector: (SEL)selector {
    return [[[ZeroKitHotKeyAction alloc] initWithTarget: target selector: selector] autorelease];
}

#pragma mark -

- (void)trigger {
    if ([myTarget respondsToSelector: mySelector]) {
        [myTarget performSelector: mySelector];
    } else {
        NSLog(@"Unable to trigger hot key action, the target does not respond to the specified selector.");
    }

}

@end
