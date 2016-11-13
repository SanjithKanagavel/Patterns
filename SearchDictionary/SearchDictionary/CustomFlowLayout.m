//
//  CustomFlowLayout.m
//  SearchDictionary
//
//  Created by Sanjith J K on 09/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "CustomFlowLayout.h"

@implementation CustomFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributesForElementsInRect = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttributesForElementsInRect = [[NSMutableArray alloc] initWithCapacity:attributesForElementsInRect.count];
    
    CGFloat leftMargin = self.sectionInset.left; //initalized to silence compiler, and actaully safer, but
        for (UICollectionViewLayoutAttributes *attributes in attributesForElementsInRect) {
        if (attributes.frame.origin.x == self.sectionInset.left) {
            leftMargin = self.sectionInset.left; //will add outside loop
        } else {
            CGRect newLeftAlignedFrame = attributes.frame;
            newLeftAlignedFrame.origin.x = leftMargin;
            attributes.frame = newLeftAlignedFrame;
        }
        
        leftMargin += attributes.frame.size.width + 10.0f;
        [newAttributesForElementsInRect addObject:attributes];
    }
    
    return newAttributesForElementsInRect;
}

@end
