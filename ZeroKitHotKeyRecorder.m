#import "ZeroKitHotKeyRecorder.h"
#import "ZeroKitHotKeyRecorderCell.h"

#define MyCell (ZeroKitHotKeyRecorderCell *)[self cell]

#pragma mark -

@implementation ZeroKitHotKeyRecorder

- (id)initWithFrame: (NSRect)frame {
    if (self = [super initWithFrame: frame]) {
        [MyCell setHotKeyRecorder: self];
    }
    
    return self;
}

#pragma mark -

+ (Class)cellClass {
    return [ZeroKitHotKeyRecorderCell class];
}

#pragma mark -

- (NSString *)hotKeyName {
    return [MyCell hotKeyName];
}

- (void)setHotKeyName: (NSString *)hotKeyName {
    [MyCell setHotKeyName: hotKeyName];
}

#pragma mark -

- (ZeroKitHotKey *)hotKey {
    return [MyCell hotKey];
}

- (void)setHotKey: (ZeroKitHotKey *)hotKey {
    [MyCell setHotKey: hotKey];
    
    [self updateCell: MyCell];
}

#pragma mark -

- (id<ZeroKitHotKeyRecorderDelegate>)delegate {
    return [MyCell delegate];
}

- (void)setDelegate: (id<ZeroKitHotKeyRecorderDelegate>)delegate {
    [MyCell setDelegate: delegate];
}

#pragma mark -

- (void)setAdditionalHotKeyValidators: (NSArray *)additionalHotKeyValidators {
    [MyCell setAdditionalHotKeyValidators: additionalHotKeyValidators];
}

#pragma mark -

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)acceptsFirstMouse: (NSEvent *)event {
    return YES;
}

#pragma mark -

- (BOOL)performKeyEquivalent: (NSEvent *)event {
    if ([[[self window] firstResponder] isEqualTo: self]) {
        return [MyCell performKeyEquivalent: event];
    }
    
    return [super performKeyEquivalent: event];
}

- (void)keyDown: (NSEvent *)event {
    if ([self performKeyEquivalent: event]) {
        return;
    }
    
    [super keyDown: event];
}

- (void)flagsChanged: (NSEvent *)event {
    [MyCell flagsChanged: event];
}

#pragma mark -

- (BOOL)resignFirstResponder {
    return [MyCell resignFirstResponder];
}

@end
