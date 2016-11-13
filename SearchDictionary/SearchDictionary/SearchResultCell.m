//
//  SearchResultCell.m
//  SearchDictionary
//
//  Created by Sanjith J K on 13/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "SearchResultCell.h"

@implementation SearchResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initData];
    [self styleCell];
    [self bindImageClick];
}

-(void) initData {
    self.faviOn = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void) bindImageClick {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showhideFavi)];
    singleTap.numberOfTapsRequired = 1;
    [self.faviImg setUserInteractionEnabled:YES];
    [self.faviImg addGestureRecognizer:singleTap];
}

-(void)showhideFavi{
    if(!self.faviOn) {
        [self.faviImg setBackgroundImage:[UIImage imageNamed:@"starUnfilled"] forState:UIControlStateNormal];
        [self.viewController removeFavourite:self.searchStr searchValue:self.searchValue];
    } else {
        [self.faviImg setBackgroundImage:[UIImage imageNamed:@"starFilled"] forState:UIControlStateNormal];
        [self.viewController addFavourite:self.searchStr searchValue:self.searchValue];
    }
    self.faviOn = !self.faviOn;
}

-(void) styleCell {
    self.bgView.layer.cornerRadius = 10.0f;
    self.bgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bgView.layer.borderWidth = 1.5f;
    self.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bgView.layer.shadowOpacity = 0.8;
    self.bgView.layer.shadowRadius = 3.0;
    self.bgView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.wordLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0];
    self.wordLabel.textColor  = [UIColor whiteColor];
}

-(void) setViewColour : (UIColor *) color{
    self.bgView.backgroundColor = color;
}

-(void) updateFaviState : (BOOL) isFavi{
    self.faviOn = isFavi? YES : NO ;
    [self showhideFavi];
}


@end