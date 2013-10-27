#import "ZKHotKeyTranslator.h"
#import "ZKHotKey.h"
#import "ZKUtilities.h"
#import "ZKConstants.h"

enum {
    ZKHotKeyAlternateGlyph   = 0x2325,
    ZKHotKeyCommandGlyph     = 0x2318,
    ZKHotKeyControlGlyph     = 0x2303,
    ZKHotKeyDeleteLeftGlyph  = 0x232B,
    ZKHotKeyDeleteRightGlyph = 0x2326,
    ZKHotKeyDownArrowGlyph   = 0x2193,
    ZKHotKeyLeftArrowGlyph   = 0x2190,
    ZKHotKeyPageDownGlyph    = 0x21DF,
    ZKHotKeyPageUpGlyph      = 0x21DE,
    ZKHotKeyReturnGlyph      = 0x21A9,
    ZKHotKeyRightArrowGlyph  = 0x2192,
    ZKHotKeyShiftGlyph       = 0x21E7,
    ZKHotKeyTabLeftGlyph     = 0x21E4,
    ZKHotKeyTabRightGlyph    = 0x21E5,
    ZKHotKeyUpArrowGlyph     = 0x2191
};

enum {
    ZKHotKeyAlternateCarbonKeyMask = 1 << 11,
    ZKHotKeyCommandCarbonKeyMask   = 1 << 8,
    ZKHotKeyControlCarbonKeyMask   = 1 << 12,
    ZKHotKeyShiftCarbonKeyMask     = 1 << 9,
};

@interface ZKHotKeyTranslator (ZKHotKeyTranslatorPrivate)

+ (NSInteger)convertCocoaModifiersToCarbon: (NSInteger)modifiers;

+ (NSInteger)convertCarbonModifiersToCocoa: (NSInteger)modifiers;

#pragma mark -

- (void)buildKeyCodeConvertorDictionary;

@end

#pragma mark -

@implementation ZKHotKeyTranslator

- (id)init {
    if ((self = [super init])) {
        specialHotKeyTranslations = nil;
    }
    
    return self;
}

#pragma mark -

+ (ZKHotKeyTranslator *)sharedTranslator {
    static ZKHotKeyTranslator *sharedInstance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

#pragma mark -

+ (NSInteger)convertModifiersToCarbonIfNecessary: (NSInteger)modifiers {
    if ([ZKHotKey validCocoaModifiers: modifiers]) {
        modifiers = [self convertCocoaModifiersToCarbon: modifiers];
    }
    
    return modifiers;
}

#pragma mark -

+ (NSString *)translateCocoaModifiers: (NSInteger)modifiers {
    NSString *modifierGlyphs = @"";
    
    if (modifiers & NSControlKeyMask) {
        modifierGlyphs = [modifierGlyphs stringByAppendingFormat: @"%C", (UInt16)ZKHotKeyControlGlyph];
    }
    
    if (modifiers & NSAlternateKeyMask) {
        modifierGlyphs = [modifierGlyphs stringByAppendingFormat: @"%C", (UInt16)ZKHotKeyAlternateGlyph];
    }
    
    if (modifiers & NSShiftKeyMask) {
        modifierGlyphs = [modifierGlyphs stringByAppendingFormat: @"%C", (UInt16)ZKHotKeyShiftGlyph];
    }
    
    if (modifiers & NSCommandKeyMask) {
        modifierGlyphs = [modifierGlyphs stringByAppendingFormat: @"%C", (UInt16)ZKHotKeyCommandGlyph];
    }
    
    return modifierGlyphs;
}

- (NSString *)translateKeyCode: (NSInteger)keyCode {
    NSDictionary *keyCodeTranslations = nil;
    NSString *result;
    
    [self buildKeyCodeConvertorDictionary];
    
    keyCodeTranslations = specialHotKeyTranslations[ZKHotKeyTranslationsKey];
    
    result = keyCodeTranslations[[NSString stringWithFormat: @"%d", (UInt32)keyCode]];
    
    if (result) {
        NSDictionary *glyphTranslations = specialHotKeyTranslations[ZKHotKeyGlyphTranslationsKey];
        id translatedGlyph = glyphTranslations[result];
        
        if (translatedGlyph) {
            result = [NSString stringWithFormat: @"%C", (UInt16)[translatedGlyph integerValue]];
        }
    } else {
        TISInputSourceRef inputSource = TISCopyCurrentKeyboardInputSource();
        CFDataRef layoutData = (CFDataRef)TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData);
        const UCKeyboardLayout *keyboardLayout = nil;
        UInt32 keysDown = 0;
        UniCharCount length = 4;
        UniCharCount actualLength = 0;
        UniChar chars[4];
        
        if (layoutData == NULL) {
            NSLog(@"Unable to determine keyboard layout.");
            
            return @"?";
        }
        
        keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
        
        if (UCKeyTranslate(keyboardLayout, keyCode, kUCKeyActionDisplay, 0, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &keysDown, length, &actualLength, chars)) {
            NSLog(@"There was a problem translating the key code.");
            
            return @"?";
        }
        
        result = [[NSString stringWithCharacters: chars length: 1] uppercaseString];
        
        CFRelease(inputSource);
    }
    
    return result;
}

#pragma mark -

- (NSString *)translateHotKey: (ZKHotKey *)hotKey {
    NSInteger modifiers = [ZKHotKeyTranslator convertCarbonModifiersToCocoa: [hotKey hotKeyModifiers]];
    
    return [NSString stringWithFormat: @"%@%@", [ZKHotKeyTranslator translateCocoaModifiers: modifiers], [self translateKeyCode: [hotKey hotKeyCode]]];
}

@end

#pragma mark -

@implementation ZKHotKeyTranslator (ZKHotKeyTranslatorPrivate)

+ (NSInteger)convertCocoaModifiersToCarbon: (NSInteger)modifiers {
    NSInteger convertedModifiers = 0;
    
    if (modifiers & NSControlKeyMask) {
        convertedModifiers |= ZKHotKeyControlCarbonKeyMask;
    }
    
    if (modifiers & NSAlternateKeyMask) {
        convertedModifiers |= ZKHotKeyAlternateCarbonKeyMask;
    }
    
    if (modifiers & NSShiftKeyMask) {
        convertedModifiers |= ZKHotKeyShiftCarbonKeyMask;
    }
    
    if (modifiers & NSCommandKeyMask) {
        convertedModifiers |= ZKHotKeyCommandCarbonKeyMask;
    }
    
    return convertedModifiers;
}

+ (NSInteger)convertCarbonModifiersToCocoa: (NSInteger)modifiers {
    NSInteger convertedModifiers = 0;
    
    if (modifiers & ZKHotKeyControlCarbonKeyMask) {
        convertedModifiers |= NSControlKeyMask;
    }
    
    if (modifiers & ZKHotKeyAlternateCarbonKeyMask) {
        convertedModifiers |= NSAlternateKeyMask;
    }
    
    if (modifiers & ZKHotKeyShiftCarbonKeyMask) {
        convertedModifiers |= NSShiftKeyMask;
    }
    
    if (modifiers & ZKHotKeyCommandCarbonKeyMask) {
        convertedModifiers |= NSCommandKeyMask;
    }
    
    return convertedModifiers;
}

#pragma mark -

- (void)buildKeyCodeConvertorDictionary {
    if (!specialHotKeyTranslations) {
        NSBundle *bundle = [NSBundle bundleForClass: [self class]];
        NSString *path = [bundle pathForResource: ZKHotKeyTranslationsPropertyListFile ofType: ZKPropertyListFileExtension];
        
        specialHotKeyTranslations = [[NSDictionary alloc] initWithContentsOfFile: path];
    }
}

@end
