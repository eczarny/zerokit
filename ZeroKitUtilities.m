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

#import "ZeroKitUtilities.h"
#import "ZeroKitConstants.h"

@implementation ZeroKitUtilities

+ (NSBundle *)applicationBundle {
    return [NSBundle mainBundle];
}

#pragma mark -

+ (NSString *)applicationVersion {
    NSBundle *applicationBundle = [ZeroKitUtilities applicationBundle];
    NSString *applicationVersion = [applicationBundle objectForInfoDictionaryKey: ZeroKitApplicationBundleShortVersionString];
    
    if (!applicationVersion) {
        applicationVersion = [applicationBundle objectForInfoDictionaryKey: ZeroKitApplicationBundleVersion];
    }
    
    return applicationVersion;
}

#pragma mark -

+ (void)registerDefaultsForBundle: (NSBundle *)bundle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [bundle pathForResource: ZeroKitDefaultPreferencesFile ofType: ZeroKitPropertyListFileExtension];
    NSDictionary *applicationDefaults = [[[NSDictionary alloc] initWithContentsOfFile: path] autorelease];
    
    [defaults registerDefaults: applicationDefaults];
}

#pragma mark -

+ (NSString *)applicationSupportPathForBundle: (NSBundle *)bundle {
    NSString *applicationName = [bundle objectForInfoDictionaryKey: ZeroKitApplicationBundleName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = ([paths count] > 0) ? [paths objectAtIndex: 0] : NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    applicationSupportPath = [applicationSupportPath stringByAppendingPathComponent: applicationName];
    
    if (![fileManager fileExistsAtPath: applicationSupportPath isDirectory: nil]) {
        NSLog(@"The application support directory does not exist, it will be created.");
        
        if (![fileManager createDirectoryAtPath: applicationSupportPath withIntermediateDirectories: NO attributes: nil error: nil]) {
            NSLog(@"There was a problem creating the application support directory at path: %@", applicationSupportPath);
        }
    }
    
    return applicationSupportPath;
}

#pragma mark -

+ (NSString *)pathForPreferencePaneNamed: (NSString *)preferencePaneName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSAllDomainsMask, YES);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *preferencePanePath = nil;
    
    if (preferencePaneName) {
        preferencePaneName = [preferencePaneName stringByAppendingFormat: @".%@", ZeroKitPreferencePaneExtension];
        
        for (NSString *path in paths) {
            path = [path stringByAppendingPathComponent: preferencePaneName];
            
            if (path && [fileManager fileExistsAtPath: path isDirectory: nil]) {
                preferencePanePath = path;
                
                break;
            }
        }
        
        if (!preferencePanePath) {
            NSLog(@"There was a problem obtaining the path for the specified preference pane: %@", preferencePaneName);
        }
    }
    
    return preferencePanePath;
}

#pragma mark -

+ (BOOL)isLoginItemEnabledForBundle: (NSBundle *)bundle {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [bundle bundlePath];
    CFURLRef applicationPathURL = (CFURLRef)[NSURL fileURLWithPath: applicationPath];
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

+ (void)enableLoginItemForBundle: (NSBundle *)bundle {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [bundle bundlePath];
    CFURLRef applicationPathURL = (CFURLRef)[NSURL fileURLWithPath: applicationPath];
    
    if (sharedFileList) {
        LSSharedFileListItemRef sharedFileListItem = LSSharedFileListInsertItemURL(sharedFileList, kLSSharedFileListItemLast, NULL, NULL, applicationPathURL, NULL, NULL);
        
        if (sharedFileListItem) {
            CFRelease(sharedFileListItem);
        }
        
        CFRelease(sharedFileList);
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
}

+ (void)disableLoginItemForBundle: (NSBundle *)bundle {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [bundle bundlePath];
    CFURLRef applicationPathURL = (CFURLRef)[NSURL fileURLWithPath: applicationPath];
    
    if (sharedFileList) {
        NSArray *sharedFileListArray = nil;
        UInt32 seedValue;
        
        sharedFileListArray = (NSArray *)LSSharedFileListCopySnapshot(sharedFileList, &seedValue);
        
        for (id sharedFile in sharedFileListArray) {
            LSSharedFileListItemRef sharedFileListItem = (LSSharedFileListItemRef)sharedFile;
            
            LSSharedFileListItemResolve(sharedFileListItem, 0, (CFURLRef *)&applicationPathURL, NULL);
            
            if (applicationPathURL != NULL) {
                NSString *resolvedApplicationPath = [(NSURL *)applicationPathURL path];
                
                if ([resolvedApplicationPath compare: applicationPath] == NSOrderedSame) {
                    LSSharedFileListItemRemove(sharedFileList, sharedFileListItem);
                }
            }
        }
        
        [sharedFileListArray release];
        
        CFRelease(sharedFileList);
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
}

#pragma mark -

+ (NSImage *)imageFromResource: (NSString *)resource inBundle: (NSBundle *)bundle {
    return [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: resource]] autorelease];
}

#pragma mark -

+ (BOOL)isStringEmpty: (NSString *)string {
    if (!string || [string isEqualToString: @""]) {
        return YES;
    }
    
    return NO;
}

@end
