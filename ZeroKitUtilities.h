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
// ZeroKitUtilities.h
// 
// Created by Eric Czarny on Thursday, February 25, 2010.
// Copyright (c) 2010 Divisible by Zero.
// 

#import <Cocoa/Cocoa.h>

#define ZeroKitLocalizedString(string) NSLocalizedString(string, string)

#pragma mark -

@class ZeroKitProcess;

@interface ZeroKitUtilities : NSObject {
    
}

+ (NSBundle *)applicationBundle;

#pragma mark -

+ (NSString *)applicationVersion;

#pragma mark -

+ (void)registerDefaultsForBundle: (NSBundle *)bundle;

#pragma mark -

+ (NSString *)applicationSupportPathForBundle: (NSBundle *)bundle;

#pragma mark -

+ (NSString *)pathForSystemPreferencePaneNamed: (NSString *)preferencePaneName;

#pragma mark -

+ (BOOL)isLoginItemEnabledForBundle: (NSBundle *)bundle;

#pragma mark -

+ (void)enableLoginItemForBundle: (NSBundle *)bundle;

+ (void)disableLoginItemForBundle: (NSBundle *)bundle;

#pragma mark -

+ (NSImage *)imageFromResource: (NSString *)resource inBundle: (NSBundle *)bundle;

#pragma mark -

+ (BOOL)isStringEmpty: (NSString *)string;

@end
