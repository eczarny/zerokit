#import "ZeroKitHotKeyValidator.h"
#import "ZeroKitHotKeyValidatorProtocol.h"
#import "ZeroKitHotKeyTranslator.h"
#import "ZeroKitHotKey.h"
#import "ZeroKitUtilities.h"

@interface ZeroKitHotKeyValidator (ZeroKitHotKeyValidatorPrivate)

+ (NSInteger)keyCodeFromDictionary: (CFDictionaryRef)dictionary;

+ (NSInteger)modifiersFromDictionary: (CFDictionaryRef)dictionary;

#pragma mark -

+ (BOOL)hotKey: (ZeroKitHotKey *)hotKey containsModifiers: (NSInteger)modifiers;

#pragma mark -

+ (NSError *)errorWithHotKey: (ZeroKitHotKey *)hotKey description: (NSString *)description recoverySuggestion: (NSString *)recoverySuggestion;

#pragma mark -

+ (BOOL)isHotKey: (ZeroKitHotKey *)hotKey availableInMenu: (NSMenu *)menu error: (NSError **)error;

@end

#pragma mark -

@implementation ZeroKitHotKeyValidator

+ (BOOL)isHotKeyValid: (ZeroKitHotKey *)hotKey error: (NSError **)error {
    return [ZeroKitHotKeyValidator isHotKeyValid: hotKey withValidators: [NSArray array] error: error];
}

+ (BOOL)isHotKeyValid: (ZeroKitHotKey *)hotKey withValidators: (NSArray *)validators error: (NSError **)error {
    CFArrayRef hotKeys = NULL;
    OSStatus err = CopySymbolicHotKeys(&hotKeys);
    
    if (err) {
        return YES;
    }
    
    for (CFIndex i = 0; i < CFArrayGetCount(hotKeys); i++) {
        CFDictionaryRef hotKeyDictionary = (CFDictionaryRef)CFArrayGetValueAtIndex(hotKeys, i);
        
        if (!hotKeyDictionary || (CFGetTypeID(hotKeyDictionary) != CFDictionaryGetTypeID())) {
            continue;
        }
        
        if (kCFBooleanTrue != (CFBooleanRef)CFDictionaryGetValue(hotKeyDictionary, kHISymbolicHotKeyEnabled)) {
            continue;
        }
        
        NSInteger keyCode = [ZeroKitHotKeyValidator keyCodeFromDictionary: hotKeyDictionary];
        NSInteger modifiers = [ZeroKitHotKeyValidator modifiersFromDictionary: hotKeyDictionary];
        
        if (([hotKey hotKeyCode] == keyCode) && [ZeroKitHotKeyValidator hotKey: hotKey containsModifiers: modifiers]) {
            if (error) {
                *error = [ZeroKitHotKeyValidator errorWithHotKey: hotKey
                                                     description: @"Hot key %@ already in use."
                                              recoverySuggestion: @"The hot key \"%@\" is already used by a system-wide keyboard shortcut.\n\nTo use this hot key change the existing shortcut in the Keyboard preference pane under System Preferences."];
            }
            
            return NO;
        }
    }
    
    for (id<ZeroKitHotKeyValidatorProtocol> validator in validators) {
        if ([validator conformsToProtocol: @protocol(ZeroKitHotKeyValidatorProtocol)] && ![validator isHotKeyValid: hotKey]) {
            if (error) {
                *error = [ZeroKitHotKeyValidator errorWithHotKey: hotKey
                                                     description: @"Hot key %@ already in use."
                                              recoverySuggestion: @"The hot key \"%@\" is already in use. Please select a new hot key."];
            }
            
            return NO;
        }
    }
    
    return [self isHotKey: hotKey availableInMenu: [[NSApplication sharedApplication] mainMenu] error: error];
}

@end

#pragma mark -

@implementation ZeroKitHotKeyValidator (ZeroKitHotKeyValidatorPrivate)

+ (NSInteger)keyCodeFromDictionary: (CFDictionaryRef)dictionary {
    CFNumberRef keyCodeFromDictionary = (CFNumberRef)CFDictionaryGetValue(dictionary, kHISymbolicHotKeyCode);
    NSInteger keyCode = 0;
    
    CFNumberGetValue(keyCodeFromDictionary, kCFNumberLongType, &keyCode);
    
    return keyCode;
}

+ (NSInteger)modifiersFromDictionary: (CFDictionaryRef)dictionary {
    CFNumberRef modifiersFromDictionary = (CFNumberRef)CFDictionaryGetValue(dictionary, kHISymbolicHotKeyModifiers);
    NSInteger modifiers = 0;
    
    CFNumberGetValue(modifiersFromDictionary, kCFNumberLongType, &modifiers);
    
    return modifiers;
}

#pragma mark -

+ (BOOL)hotKey: (ZeroKitHotKey *)hotKey containsModifiers: (NSInteger)modifiers {
    return [hotKey hotKeyModifiers] == [ZeroKitHotKeyTranslator convertModifiersToCarbonIfNecessary: modifiers];
}

#pragma mark -

+ (NSError *)errorWithHotKey: (ZeroKitHotKey *)hotKey description: (NSString *)description recoverySuggestion: (NSString *)recoverySuggestion {
    NSString *hotKeyString = [[ZeroKitHotKeyTranslator sharedTranslator] translateHotKey: hotKey];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    [userInfo setObject: [NSString stringWithFormat: ZeroKitLocalizedStringFromCurrentBundle(description), hotKeyString]
                 forKey: NSLocalizedDescriptionKey];
    
    [userInfo setObject: [NSString stringWithFormat: ZeroKitLocalizedStringFromCurrentBundle(recoverySuggestion), hotKeyString]
                 forKey: NSLocalizedRecoverySuggestionErrorKey];
    
    [userInfo setObject: [NSArray arrayWithObject: ZeroKitLocalizedStringFromCurrentBundle(@"OK")]
                 forKey: NSLocalizedRecoveryOptionsErrorKey];
    
    return [NSError errorWithDomain: NSCocoaErrorDomain code: 0 userInfo: userInfo];
}

#pragma mark -

+ (BOOL)isHotKey: (ZeroKitHotKey *)hotKey availableInMenu: (NSMenu *)menu error: (NSError **)error {
    for (NSMenuItem *menuItem in [menu itemArray]) {
        if ([menuItem hasSubmenu] && ![self isHotKey: hotKey availableInMenu: [menuItem submenu] error: error]) {
            return NO;
        }
        
        NSString *keyEquivalent = [menuItem keyEquivalent];
        
        if (!keyEquivalent || [keyEquivalent isEqualToString: @""]) {
            continue;
        }
        
        NSString *keyCode = [[ZeroKitHotKeyTranslator sharedTranslator] translateKeyCode: [hotKey hotKeyCode]];
        
        if ([[keyEquivalent uppercaseString] isEqualToString: keyCode]
                && [ZeroKitHotKeyValidator hotKey: hotKey containsModifiers: [menuItem keyEquivalentModifierMask]]) {
            if (error) {
                *error = [ZeroKitHotKeyValidator errorWithHotKey: hotKey
                                                     description: @"Hot key %@ already in use."
                                              recoverySuggestion: @"The hot key \"%@\" is already used in the menu."];
            }
            
            return NO;
        }
    }
    
    return YES;
}

@end
