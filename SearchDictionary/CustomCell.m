//
//  CustomCell.m
//  SearchDictionary
//
//  Created by Sanjith J K on 08/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self styleView];
    // Initialization code
}

-(void) styleView {
    self.bView.layer.cornerRadius = 30.0f;
    self.bView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bView.layer.borderWidth = 1.5f;
    self.bView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bView.layer.shadowOpacity = 0.8;
    self.bView.layer.shadowRadius = 3.0;
    self.bView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.bView.frame];
    selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    [self setSelectedBackgroundView:selectedBackgroundView];
    // Configure the view for the selected state
}

-(void) setViewColour : (UIColor *) color{
    self.bView.backgroundColor = color;
}


@end
