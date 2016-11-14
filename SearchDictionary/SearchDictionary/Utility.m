#import "Utility.h"

@implementation Utility
    + (UIColor *)colorFromHexString:(NSString *)hexString {
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        scanner.scanLocation = 1;
        [scanner scanHexInt:&rgbValue];
        return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    }

    + (UIFont *) getFont:(NSInteger)fontSize {
        return [UIFont fontWithName:fontName size:fontSize];
    }
@end
