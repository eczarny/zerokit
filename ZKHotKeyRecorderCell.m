#import "ZKHotKeyRecorderCell.h"
#import "ZKHotKey.h"
#import "ZKHotKeyTranslator.h"
#import "ZKHotKeyValidator.h"
#import "ZKHotKeyRecorder.h"
#import "ZKHotKeyRecorderDelegate.h"
#import "ZKUtilities.h"

#define MakeRelativePoint(a, b, c) NSMakePoint((a * horizontalScale) + c.origin.x, (b * verticalScale) + c.origin.y)

#pragma mark -

@interface ZKHotKeyRecorderCell (ZKHotKeyRecorderCellPrivate)

- (void)drawBorderInRect: (NSRect)rect withRadius: (CGFloat)radius;

- (void)drawBackgroundInRect: (NSRect)rect withRadius: (CGFloat)radius;

#pragma mark -

- (void)drawBadgeInRect: (NSRect)rect;

#pragma mark -

- (void)drawClearHotKeyBadgeInRect: (NSRect)rect withOpacity: (CGFloat)opacity;

- (void)drawRevertHotKeyBadgeInRect: (NSRect)rect;

#pragma mark -

- (void)drawLabelInRect: (NSRect)rect;

#pragma mark -

- (void)drawString: (NSString *)string withForegroundColor: (NSColor *)foregroundcolor inRect: (NSRect)rect;

@end

#pragma mark -

@implementation ZKHotKeyRecorderCell

- (id)init {
    if (self = [super init]) {
        hotKeyRecorder = nil;
        hotKeyName = nil;
        hotKey = nil;
        delegate = nil;
        additionalHotKeyValidators = [NSArray new];
        modifierFlags = 0;
        isRecording = NO;
        trackingArea = nil;
        isMouseAboveBadge = NO;
        isMouseDown = NO;
    }
    
    return self;
}

#pragma mark -

- (void)setHotKeyRecorder: (ZKHotKeyRecorder *)aHotKeyRecorder {
    hotKeyRecorder = aHotKeyRecorder;
}

#pragma mark -

- (NSString *)hotKeyName {
    return hotKeyName;
}

- (void)setHotKeyName: (NSString *)aHotKeyName {
    hotKeyName = aHotKeyName;
}

#pragma mark -

- (ZKHotKey *)hotKey {
    return hotKey;
}

- (void)setHotKey: (ZKHotKey *)aHotKey {
    hotKey = aHotKey;
}

#pragma mark -

- (id<ZKHotKeyRecorderDelegate>)delegate {
    return delegate;
}

- (void)setDelegate: (id<ZKHotKeyRecorderDelegate>)aDelegate {
    delegate = aDelegate;
}

#pragma mark -

- (void)setAdditionalHotKeyValidators: (NSArray *)theAdditionalHotKeyValidators {
    additionalHotKeyValidators = theAdditionalHotKeyValidators;
}

#pragma mark -

- (BOOL)resignFirstResponder {
    if (isRecording) {
        PopSymbolicHotKeyMode(hotKeyMode);
        
        isRecording = NO;
        
        [[self controlView] setNeedsDisplay: YES];
    }
    
    return YES;
}

#pragma mark -

- (BOOL)performKeyEquivalent: (NSEvent *)event {
    NSInteger keyCode = [event keyCode];
    NSInteger newModifierFlags = modifierFlags | [event modifierFlags];
    
    if (isRecording && [ZKHotKey validCocoaModifiers: newModifierFlags]) {
        NSString *characters = [[event charactersIgnoringModifiers] uppercaseString];
        
        if ([characters length]) {
            ZKHotKey *newHotKey = [[ZKHotKey alloc] initWithHotKeyCode: keyCode hotKeyModifiers: newModifierFlags];
            NSError *error = nil;
            
            if (![ZKHotKeyValidator isHotKeyValid: hotKey withValidators: additionalHotKeyValidators error: &error]) {
                [[NSAlert alertWithError: error] runModal];
            } else {
                [newHotKey setHotKeyName: hotKeyName];
                
                [self setHotKey: newHotKey];
                
                [delegate hotKeyRecorder: hotKeyRecorder didReceiveNewHotKey: newHotKey];
            }
        } else {
            NSBeep();
        }
        
        modifierFlags = 0;
        
        PopSymbolicHotKeyMode(hotKeyMode);
        
        isRecording = NO;
        
        [[self controlView] setNeedsDisplay: YES];
        
        return YES;
    }
    
    return NO;
}

- (void)flagsChanged: (NSEvent *)event {
    if (isRecording) {
        modifierFlags = [event modifierFlags];
        
        if (modifierFlags == 256) {
            modifierFlags = 0;
        }
        
        [[self controlView] setNeedsDisplay: YES];
    }
}

#pragma mark -

- (BOOL)trackMouse: (NSEvent *)event inRect: (NSRect)rect ofView: (NSView *)view untilMouseUp: (BOOL)untilMouseUp {
    NSEvent *currentEvent = event;
    
    do {
        NSPoint mouseLocation = [view convertPoint: [currentEvent locationInWindow] fromView: nil];
        
        switch ([currentEvent type]) {
            case NSLeftMouseDown:
                isMouseDown = YES;
                
                [view setNeedsDisplay: YES];
                
                break;
            case NSLeftMouseDragged:
                if ([view mouse: mouseLocation inRect: rect]) {
                    isMouseDown = YES;
                } else {
                    isMouseDown = NO;
                }
                
                if (isMouseAboveBadge && [view mouse: mouseLocation inRect: [trackingArea rect]]) {
                    isMouseDown = YES;
                    isMouseAboveBadge = YES;
                } else {
                    isMouseDown = NO;
                    isMouseAboveBadge = NO;
                }
                
                [view setNeedsDisplay: YES];
                
                break;
            default:
                isMouseDown = NO;
                
                if ([view mouse: mouseLocation inRect: rect] && !isRecording && !isMouseAboveBadge) {
                    isRecording = YES;
                    
                    hotKeyMode = PushSymbolicHotKeyMode(kHIHotKeyModeAllDisabled);
                    
                    [[view window] makeFirstResponder: view];
                } else if (isRecording && isMouseAboveBadge) {
                    PopSymbolicHotKeyMode(hotKeyMode);
                    
                    isRecording = NO;
                } else if (!isRecording && hotKey && isMouseAboveBadge) {
                    [delegate hotKeyRecorder: hotKeyRecorder didClearExistingHotKey: hotKey];
                    
                    [self setHotKey: nil];
                }
                
                [view setNeedsDisplay: YES];
                
                return YES;
        }
    } while ((currentEvent = [[view window] nextEventMatchingMask: (NSLeftMouseDraggedMask | NSLeftMouseUpMask)
                                                        untilDate: [NSDate distantFuture]
                                                           inMode: NSEventTrackingRunLoopMode
                                                          dequeue: YES]));
    
    return YES;
}

#pragma mark -

- (void)mouseEntered: (NSEvent *)event {
    isMouseAboveBadge = YES;
    
    [[self controlView] setNeedsDisplay: YES];
}

- (void)mouseExited: (NSEvent *)event {
    isMouseAboveBadge = NO;
    
    [[self controlView] setNeedsDisplay: YES];
}

#pragma mark -

- (void)drawWithFrame: (NSRect)frame inView: (NSView *)view {
    CGFloat radius = NSHeight(frame) / 2.0f;
    
    // Draw the border of the control.
    [self drawBorderInRect: frame withRadius: radius];
    
    // Draw the default background of the control.
    [self drawBackgroundInRect: frame withRadius: radius];
    
    // Draw the tracking area image, depending the control's current state.
    [self drawBadgeInRect: frame];
    
    // Draw the label of the control.
    [self drawLabelInRect: frame];
}

@end

#pragma mark -

@implementation ZKHotKeyRecorderCell (ZKHotKeyRecorderCellPrivate)

- (void)drawBorderInRect: (NSRect)rect withRadius: (CGFloat)radius {
    NSBezierPath *roundedPath = [NSBezierPath bezierPathWithRoundedRect: rect xRadius: radius yRadius: radius];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    [roundedPath addClip];
    
    [[NSColor windowFrameColor] set];
    
    [NSBezierPath fillRect: rect];
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawBackgroundInRect: (NSRect)rect withRadius: (CGFloat)radius {
    NSBezierPath *roundedPath = [NSBezierPath bezierPathWithRoundedRect: NSInsetRect(rect, 1.0f, 1.0f) xRadius: radius yRadius: radius];
    NSColor *gradientStartingColor = nil;
    NSColor *gradientEndingColor = nil;
    NSGradient *gradient = nil;
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    [roundedPath addClip];
    
    if (isRecording) {
        gradientStartingColor = [NSColor colorWithDeviceRed: 0.784f green: 0.953f blue: 1.0f alpha: 1.0f];
        gradientEndingColor = [NSColor colorWithDeviceRed: 0.694f green: 0.859f blue: 1.0f alpha: 1.0f];
    } else {
        gradientStartingColor = [[[NSColor whiteColor] shadowWithLevel: 0.2f] colorWithAlphaComponent: 0.9f];
        gradientEndingColor = [[[NSColor whiteColor] highlightWithLevel: 0.2f] colorWithAlphaComponent: 0.9f];
    }
    
    if (!isRecording && isMouseDown && !isMouseAboveBadge) {
        gradient = [[NSGradient alloc] initWithStartingColor: gradientEndingColor endingColor: gradientStartingColor];
    } else {
        gradient = [[NSGradient alloc] initWithStartingColor: gradientStartingColor endingColor: gradientEndingColor];
    }
    
    [gradient drawInRect: rect angle: 90.0f];
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

#pragma mark -

- (void)drawBadgeInRect: (NSRect)rect {
    NSRect badgeRect;
    NSSize badgeSize;
    
    // Calculate this! Eventually...
    badgeSize.width = 13.0f;
    badgeSize.height = 13.0f;
    
    badgeRect.origin = NSMakePoint(NSMaxX(rect) - badgeSize.width - 4.0f, floor((NSMaxY(rect) - badgeSize.height) / 2.0f));
    badgeRect.size = badgeSize;
    
    if (isRecording && !hotKey) {
        [self drawClearHotKeyBadgeInRect: badgeRect withOpacity: 0.25f];
    } else if (isRecording) {
        [self drawRevertHotKeyBadgeInRect: badgeRect];
    } else if (hotKey) {
        [self drawClearHotKeyBadgeInRect: badgeRect withOpacity: 0.25f];
    }
    
    if (((hotKey && !isRecording) || (!hotKey && isRecording)) && isMouseAboveBadge && isMouseDown) {
        [self drawClearHotKeyBadgeInRect: badgeRect withOpacity: 0.50f];
    }
    
    if (!trackingArea) {
        trackingArea = [[NSTrackingArea alloc] initWithRect: badgeRect
                                                      options: (NSTrackingActiveInKeyWindow | NSTrackingMouseEnteredAndExited)
                                                        owner: self
                                                     userInfo: nil];
        
        [[self controlView] addTrackingArea: trackingArea];
    }
}

#pragma mark -

- (void)drawClearHotKeyBadgeInRect: (NSRect)rect withOpacity: (CGFloat)opacity {
    CGFloat horizontalScale = (rect.size.width / 13.0f);
    CGFloat verticalScale = (rect.size.height / 13.0f);
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    [[NSColor colorWithCalibratedWhite: 0.0f alpha: opacity] setFill];
    
    [[NSBezierPath bezierPathWithOvalInRect: rect] fill];
    
    [[NSColor whiteColor] setStroke];
    
    NSBezierPath *cross = [NSBezierPath new];
    
    [cross setLineWidth: horizontalScale * 1.4f];
    
    [cross moveToPoint: MakeRelativePoint(4.0f, 4.0f, rect)];
    [cross lineToPoint: MakeRelativePoint(9.0f, 9.0f, rect)];
    [cross moveToPoint: MakeRelativePoint(9.0f, 4.0f, rect)];
    [cross lineToPoint: MakeRelativePoint(4.0f, 9.0f, rect)];
    
    [cross stroke];
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawRevertHotKeyBadgeInRect: (NSRect)rect {
    CGFloat horizontalScale = (rect.size.width / 1.0f);
    CGFloat verticalScale = (rect.size.height / 1.0f);
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    NSBezierPath *swoosh = [NSBezierPath new];
    
    [swoosh setLineWidth: horizontalScale];
    
    [swoosh moveToPoint: MakeRelativePoint(0.0489685f, 0.6181513f, rect)];
	[swoosh lineToPoint: MakeRelativePoint(0.4085750f, 0.9469318f, rect)];
	[swoosh lineToPoint: MakeRelativePoint(0.4085750f, 0.7226146f, rect)];
    
	[swoosh curveToPoint: MakeRelativePoint(0.8508247f, 0.4836237f, rect)
           controlPoint1: MakeRelativePoint(0.4085750f, 0.7226146f, rect)
           controlPoint2: MakeRelativePoint(0.8371143f, 0.7491841f, rect)];
	[swoosh curveToPoint: MakeRelativePoint(0.5507195f, 0.0530682f, rect)
           controlPoint1: MakeRelativePoint(0.8677834f, 0.1545071f, rect)
           controlPoint2: MakeRelativePoint(0.5507195f, 0.0530682f, rect)];
	[swoosh curveToPoint: MakeRelativePoint(0.7421721f, 0.3391942f, rect)
           controlPoint1: MakeRelativePoint(0.5507195f, 0.0530682f, rect)
           controlPoint2: MakeRelativePoint(0.7458685f, 0.1913146f, rect)];
	[swoosh curveToPoint: MakeRelativePoint(0.4085750f, 0.5154130f, rect)
           controlPoint1: MakeRelativePoint(0.7383412f, 0.4930328f, rect)
           controlPoint2: MakeRelativePoint(0.4085750f, 0.5154130f, rect)];
    
	[swoosh lineToPoint: MakeRelativePoint(0.4085750f, 0.2654000f, rect)];
    
    [swoosh fill];
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

#pragma mark -

- (void)drawLabelInRect: (NSRect)rect {
    NSString *label = nil;
    NSColor *foregroundColor = [NSColor blackColor];
    
    if (isRecording && !isMouseAboveBadge) {
        label = ZKLocalizedStringFromCurrentBundle(@"Enter hot key");
    } else if (isRecording && isMouseAboveBadge && !hotKey) {
        label = ZKLocalizedStringFromCurrentBundle(@"Stop recording");
    } else if (isRecording && isMouseAboveBadge) {
        label = ZKLocalizedStringFromCurrentBundle(@"Use existing");
    } else if (hotKey) {
        label = [hotKey displayString];
    } else {
        label = ZKLocalizedStringFromCurrentBundle(@"Click to record");
    }
    
    // Recording is in progress and modifier flags have already been set, display them.
    if (isRecording && (modifierFlags > 0)) {
        label = [ZKHotKeyTranslator translateCocoaModifiers: modifierFlags];
    }
    
    if (![self isEnabled]) {
        foregroundColor = [NSColor disabledControlTextColor];
    }
    
    if (isRecording) {
        [self drawString: label withForegroundColor: foregroundColor inRect: rect];
    } else {
        [self drawString: label withForegroundColor: foregroundColor inRect: rect];
    }
}

#pragma mark -

- (void)drawString: (NSString *)string withForegroundColor: (NSColor *)foregroundColor inRect: (NSRect)rect {
    NSMutableDictionary *attributes = [ZKUtilities createStringAttributesWithShadow];
    NSRect labelRect = rect;
    
    attributes[NSFontAttributeName] = [NSFont systemFontOfSize: [NSFont smallSystemFontSize]];
    attributes[NSForegroundColorAttributeName] = foregroundColor;
    
    labelRect.origin.y = -(NSMidY(rect) - [string sizeWithAttributes: attributes].height / 2.0f);
    
    [string drawInRect: labelRect withAttributes: attributes];
}

@end
