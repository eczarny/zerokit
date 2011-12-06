#import "ZeroKitHotKeyValidator.h"
#import "ZeroKitHotKeyTranslator.h"
#import "ZeroKitHotKey.h"
#import "ZeroKitUtilities.h"

@interface ZeroKitHotKeyValidator (ZeroKitHotKeyValidatorPrivate)

+ (NSInteger)keyCodeFromDictionary: (CFDictionaryRef)dictionary;

+ (NSInteger)modifiersFromDictionary: (CFDictionaryRef)dictionary;

#pragma mark -

+ (BOOL)hotKey: (ZeroKitHotKey *)hotKey containsModifiers: (NSInteger)modifiers;

@end

#pragma mark -

@implementation ZeroKitHotKeyValidator

+ (BOOL)isHotKey: (ZeroKitHotKey *)hotKey validWithError: (NSError **)error {
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
                NSString *hotKeyString = [[ZeroKitHotKeyTranslator sharedTranslator] translateHotKey: hotKey];
                NSString *description = [NSString stringWithFormat: ZeroKitLocalizedStringFromCurrentBundle(@"The hot key %@ is already in use."), hotKeyString];
                NSString *recoverySuggestion = [NSString stringWithFormat: ZeroKitLocalizedStringFromCurrentBundle(@"The hot key \"%@\" is already used by a system-wide keyboard shortcut.\n\nTo use this hot key change the existing shortcut in the Keyboard preference pane under System Preferences."), hotKeyString];
                NSArray *recoveryOptions = [NSArray arrayWithObject: ZeroKitLocalizedStringFromCurrentBundle(@"OK")];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                
                [userInfo setObject: description forKey: NSLocalizedDescriptionKey];
                [userInfo setObject: recoverySuggestion forKey: NSLocalizedRecoverySuggestionErrorKey];
                [userInfo setObject: recoveryOptions forKey: NSLocalizedRecoveryOptionsErrorKey];
                
                *error = [NSError errorWithDomain: NSCocoaErrorDomain code: 0 userInfo: userInfo];
            }
            
            return NO;
        }
    }
    
    return YES;
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

@end
