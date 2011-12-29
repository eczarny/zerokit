#import "ZeroKitHotKeyTranslator.h"
#import "ZeroKitHotKey.h"
#import "ZeroKitUtilities.h"
#import "ZeroKitConstants.h"

enum {
    ZeroKitHotKeyAlternateGlyph   = 0x2325,
    ZeroKitHotKeyCommandGlyph     = 0x2318,
    ZeroKitHotKeyControlGlyph     = 0x2303,
    ZeroKitHotKeyDeleteLeftGlyph  = 0x232B,
    ZeroKitHotKeyDeleteRightGlyph = 0x2326,
    ZeroKitHotKeyDownArrowGlyph   = 0x2193,
    ZeroKitHotKeyLeftArrowGlyph   = 0x2190,
    ZeroKitHotKeyPageDownGlyph    = 0x21DF,
    ZeroKitHotKeyPageUpGlyph      = 0x21DE,
    ZeroKitHotKeyReturnGlyph      = 0x21A9,
    ZeroKitHotKeyRightArrowGlyph  = 0x2192,
    ZeroKitHotKeyShiftGlyph       = 0x21E7,
    ZeroKitHotKeyTabLeftGlyph     = 0x21E4,
    ZeroKitHotKeyTabRightGlyph    = 0x21E5,
    ZeroKitHotKeyUpArrowGlyph     = 0x2191
};

enum {
    ZeroKitHotKeyAlternateCarbonKeyMask = 1 << 11,
    ZeroKitHotKeyCommandCarbonKeyMask   = 1 << 8,
    ZeroKitHotKeyControlCarbonKeyMask   = 1 << 12,
    ZeroKitHotKeyShiftCarbonKeyMask     = 1 << 9,
};

@interface ZeroKitHotKeyTranslator (ZeroKitHotKeyTranslatorPrivate)

+ (NSInteger)convertCocoaModifiersToCarbon: (NSInteger)modifiers;

+ (NSInteger)convertCarbonModifiersToCocoa: (NSInteger)modifiers;

#pragma mark -

- (void)buildKeyCodeConvertorDictionary;

@end

#pragma mark -

@implementation ZeroKitHotKeyTranslator

static ZeroKitHotKeyTranslator *sharedInstance = nil;

- (id)init {
    if ((self = [super init])) {
        mySpecialHotKeyTranslations = nil;
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

+ (ZeroKitHotKeyTranslator *)sharedTranslator {
    @synchronized(self) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

+ (NSInteger)convertModifiersToCarbonIfNecessary: (NSInteger)modifiers {
    if ([ZeroKitHotKey validCocoaModifiers: modifiers]) {
        modifiers = [self convertCocoaModifiersToCarbon: modifiers];
    }
    
    return modifiers;
}

#pragma mark -

+ (NSString *)translateCocoaModifiers: (NSInteger)modifiers {
    NSString *modifierGlyphs = [NSString string];
    
    if (modifiers & NSControlKeyMask) {
        modifierGlyphs = [modifierGlyphs stringByAppendingFormat: @"%C", ZeroKitHotKeyControlGlyph];
    }
    
    if (modifiers & NSAlternateKeyMask) {
        modifierGlyphs = [modifierGlyphs stringByAppendingFormat: @"%C", ZeroKitHotKeyAlternateGlyph];
    }
    
    if (modifiers & NSShiftKeyMask) {
        modifierGlyphs = [modifierGlyphs stringByAppendingFormat: @"%C", ZeroKitHotKeyShiftGlyph];
    }
    
    if (modifiers & NSCommandKeyMask) {
        modifierGlyphs = [modifierGlyphs stringByAppendingFormat: @"%C", ZeroKitHotKeyCommandGlyph];
    }
    
    return modifierGlyphs;
}

- (NSString *)translateKeyCode: (NSInteger)keyCode {
    NSDictionary *keyCodeTranslations = nil;
    NSString *result;
    
    [self buildKeyCodeConvertorDictionary];
    
    keyCodeTranslations = [mySpecialHotKeyTranslations objectForKey: ZeroKitHotKeyTranslationsKey];
    
    result = [keyCodeTranslations objectForKey: [NSString stringWithFormat: @"%d", keyCode]];
    
    if (result) {
        NSDictionary *glyphTranslations = [mySpecialHotKeyTranslations objectForKey: ZeroKitHotKeyGlyphTranslationsKey];
        id translatedGlyph = [glyphTranslations objectForKey: result];
        
        if (translatedGlyph) {
            result = [NSString stringWithFormat: @"%C", [translatedGlyph integerValue]];
        }
    } else {
        TISInputSourceRef inputSource = TISCopyCurrentKeyboardInputSource();
        CFDataRef layoutData = (CFDataRef)TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData);
        const UCKeyboardLayout *keyboardLayout = nil;
        UInt32 keysDown = 0;
        UniCharCount length = 4;
        UniCharCount actualLength = 0;
        UniChar chars[4];
        OSStatus err;
        
        if (layoutData == NULL) {
            NSLog(@"Unable to determine keyboard layout.");
            
            return @"?";
        }
        
        keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
        
        err = UCKeyTranslate(keyboardLayout,
                             keyCode,
                             kUCKeyActionDisplay,
                             0,
                             LMGetKbdType(),
                             kUCKeyTranslateNoDeadKeysBit,
                             &keysDown,
                             length,
                             &actualLength,
                             chars);
        
        if (err != noErr) {
            NSLog(@"There was a problem translating the key code.");
            
            return @"?";
        }
        
        result = [[NSString stringWithCharacters: chars length: 1] uppercaseString];
    }
    
    return result;
}

#pragma mark -

- (NSString *)translateHotKey: (ZeroKitHotKey *)hotKey {
    NSInteger modifiers = [ZeroKitHotKeyTranslator convertCarbonModifiersToCocoa: [hotKey hotKeyModifiers]];
    
    return [NSString stringWithFormat: @"%@%@", [ZeroKitHotKeyTranslator translateCocoaModifiers: modifiers], [self translateKeyCode: [hotKey hotKeyCode]]];
}

#pragma mark -

- (void)dealloc {
    [mySpecialHotKeyTranslations release];
    
    [super dealloc];
}

@end

#pragma mark -

@implementation ZeroKitHotKeyTranslator (ZeroKitHotKeyTranslatorPrivate)

+ (NSInteger)convertCocoaModifiersToCarbon: (NSInteger)modifiers {
    NSInteger convertedModifiers = 0;
    
    if (modifiers & NSControlKeyMask) {
        convertedModifiers |= ZeroKitHotKeyControlCarbonKeyMask;
    }
    
    if (modifiers & NSAlternateKeyMask) {
        convertedModifiers |= ZeroKitHotKeyAlternateCarbonKeyMask;
    }
    
    if (modifiers & NSShiftKeyMask) {
        convertedModifiers |= ZeroKitHotKeyShiftCarbonKeyMask;
    }
    
    if (modifiers & NSCommandKeyMask) {
        convertedModifiers |= ZeroKitHotKeyCommandCarbonKeyMask;
    }
    
    return convertedModifiers;
}

+ (NSInteger)convertCarbonModifiersToCocoa: (NSInteger)modifiers {
    NSInteger convertedModifiers = 0;
    
    if (modifiers & ZeroKitHotKeyControlCarbonKeyMask) {
        convertedModifiers |= NSControlKeyMask;
    }
    
    if (modifiers & ZeroKitHotKeyAlternateCarbonKeyMask) {
        convertedModifiers |= NSAlternateKeyMask;
    }
    
    if (modifiers & ZeroKitHotKeyShiftCarbonKeyMask) {
        convertedModifiers |= NSShiftKeyMask;
    }
    
    if (modifiers & ZeroKitHotKeyCommandCarbonKeyMask) {
        convertedModifiers |= NSCommandKeyMask;
    }
    
    return convertedModifiers;
}

#pragma mark -

- (void)buildKeyCodeConvertorDictionary {
    if (!mySpecialHotKeyTranslations) {
        NSBundle *bundle = [NSBundle bundleForClass: [self class]];
        NSString *path = [bundle pathForResource: ZeroKitHotKeyTranslationsPropertyListFile ofType: ZeroKitPropertyListFileExtension];
        
        mySpecialHotKeyTranslations = [[NSDictionary alloc] initWithContentsOfFile: path];
    }
}

@end
