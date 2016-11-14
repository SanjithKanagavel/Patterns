#import "Foundation/Foundation.h"
#import "UIKit/UIKit.h"
#import "Constants.h"

@interface Utility : NSObject
    + (UIColor *) colorFromHexString:(NSString *)hexString;
    + (UIFont *) getFont:(NSInteger)fontSize;
@end
