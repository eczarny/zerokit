// 
// Copyright (c) 2010 Eric Czarny <eczarny@gmail.com>
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

// 
// ZeroKit
// ZeroKitUtilities.m
// 
// Created by Eric Czarny on Thursday, February 25, 2010.
// Copyright (c) 2010 Divisible by Zero.
// 

#import "ZeroKitUtilities.h"
#import "ZeroKitConstants.h"

@implementation ZeroKitUtilities

+ (NSBundle *)applicationBundle {
    return [NSBundle mainBundle];
}

+ (NSString *)applicationVersion {
    NSBundle *applicationBundle = [ZeroKitUtilities applicationBundle];
    NSString *applicationVersion = [applicationBundle objectForInfoDictionaryKey: ZeroKitApplicationBundleShortVersionString];
    
    if (!applicationVersion) {
        applicationVersion = [applicationBundle objectForInfoDictionaryKey: ZeroKitApplicationBundleVersion];
    }
    
    return applicationVersion;
}

#pragma mark -

+ (void)registerDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [[ZeroKitUtilities applicationBundle] pathForResource: ZeroKitDefaultPreferencesFile ofType: ZeroKitPropertyListFileExtension];
    NSDictionary *emergenceDefaults = [[[NSDictionary alloc] initWithContentsOfFile: path] autorelease];
    
    [defaults registerDefaults: emergenceDefaults];
}

#pragma mark -

+ (NSString *)applicationSupportPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = ([paths count] > 0) ? [paths objectAtIndex: 0] : NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    applicationSupportPath = [applicationSupportPath stringByAppendingPathComponent: ZeroKitFrameworkName];
    
    if (![fileManager fileExistsAtPath: applicationSupportPath isDirectory: nil]) {
        NSLog(@"The application support directory does not exist, it will be created.");
        
        if (![fileManager createDirectoryAtPath: applicationSupportPath withIntermediateDirectories: NO attributes: nil error: nil]) {
            NSLog(@"There was a problem creating the application support directory at path: %@", applicationSupportPath);
        }
    }
    
    return applicationSupportPath;
}

#pragma mark -

+ (BOOL)isLoginItemEnabled {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [[ZeroKitUtilities applicationBundle] bundlePath];
    CFURLRef applicationPathURL= (CFURLRef)[NSURL fileURLWithPath: applicationPath];
    BOOL result = NO;
    
    if (sharedFileList) {
        NSArray *sharedFileListArray = nil;
        UInt32 seedValue;
        
        sharedFileListArray = (NSArray *)LSSharedFileListCopySnapshot(sharedFileList, &seedValue);
        
        for (id sharedFile in sharedFileListArray) {
            LSSharedFileListItemRef sharedFileListItem = (LSSharedFileListItemRef)sharedFile;
            
            LSSharedFileListItemResolve(sharedFileListItem, 0, (CFURLRef *)&applicationPathURL, NULL);
            
            if (applicationPathURL != NULL) {
                NSString *resolvedApplicationPath = [(NSURL *)applicationPathURL path];
                
                CFRelease(applicationPathURL);
                
                if ([resolvedApplicationPath compare: applicationPath] == NSOrderedSame) {
                    result = YES;
                    
                    break;
                }
            }
        }
        
        [sharedFileListArray release];
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
    
    return result;
}

#pragma mark -

+ (void)enableLoginItem {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [[ZeroKitUtilities applicationBundle] bundlePath];
    CFURLRef applicationPathURL= (CFURLRef)[NSURL fileURLWithPath: applicationPath];
    
    if (sharedFileList) {
        LSSharedFileListItemRef sharedFileListItem = LSSharedFileListInsertItemURL(sharedFileList, kLSSharedFileListItemLast, NULL, NULL, applicationPathURL, NULL, NULL);
        
        if (sharedFileListItem) {
            CFRelease(sharedFileListItem);
        }
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
    
    CFRelease(sharedFileList);
}

+ (void)disableLoginItem {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [[ZeroKitUtilities applicationBundle] bundlePath];
    CFURLRef applicationPathURL= (CFURLRef)[NSURL fileURLWithPath: applicationPath];
    
    if (sharedFileList) {
        NSArray *sharedFileListArray = nil;
        UInt32 seedValue;
        
        sharedFileListArray = (NSArray *)LSSharedFileListCopySnapshot(sharedFileList, &seedValue);
        
        for (id sharedFile in sharedFileListArray) {
            LSSharedFileListItemRef sharedFileListItem = (LSSharedFileListItemRef)sharedFile;
            
            LSSharedFileListItemResolve(sharedFileListItem, 0, (CFURLRef *)&applicationPathURL, NULL);
            
            if (applicationPathURL != NULL) {
                NSString *resolvedApplicationPath = [(NSURL *)applicationPathURL path];
                
                CFRelease(applicationPathURL);
                
                if ([resolvedApplicationPath compare: applicationPath] == NSOrderedSame) {
                    LSSharedFileListItemRemove(sharedFileList, sharedFileListItem);
                }
            }
        }
        
        [sharedFileListArray release];
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
    
    CFRelease(sharedFileList);
}

#pragma mark -

+ (NSImage *)imageFromBundledImageResource: (NSString *)resource {
    NSString *resourcePath = [[ZeroKitUtilities applicationBundle] pathForImageResource: resource];
    
    return [[[NSImage alloc] initWithContentsOfFile: resourcePath] autorelease];
}

#pragma mark -

+ (BOOL)isStringEmpty: (NSString *)string {
    if (!string || [string isEqualToString: @""]) {
        return YES;
    }
    
    return NO;
}

@end
