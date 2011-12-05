#import "NSAttributedStringAdditions.h"

@implementation NSAttributedString (NSAttributedStringAdditions)

+ (id)linkFromString: (NSString *)string withURL: (NSURL *)url font: (NSFont *)font {
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString: string];
    NSRange range = NSMakeRange(0, [attributedString length]);
    
    [attributedString beginEditing];
    
    [attributedString addAttribute: NSLinkAttributeName value: [url absoluteString] range: range];
    [attributedString addAttribute: NSForegroundColorAttributeName value: [NSColor blueColor] range: range];
    [attributedString addAttribute: NSUnderlineStyleAttributeName value: [NSNumber numberWithInt: NSSingleUnderlineStyle] range: range];
    [attributedString addAttribute: NSFontAttributeName value: font range: range];
    
    [attributedString endEditing];
    
    return [attributedString autorelease];
}

@end
