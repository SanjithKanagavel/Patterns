//
//  Utility.m
//  SearchDictionary
//
//  Created by Sanjith J K on 09/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "Utility.h"

@implementation Utility
    + (UIColor *)colorFromHexString:(NSString *)hexString {
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        scanner.scanLocation = 1;
        [scanner scanHexInt:&rgbValue];
        return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    }
@end
