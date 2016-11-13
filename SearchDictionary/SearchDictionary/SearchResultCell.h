//
//  SearchResultCell.h
//  SearchDictionary
//
//  Created by Sanjith J K on 13/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "ViewController.h"

@interface SearchResultCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet UIView *bgView;
    @property (weak, nonatomic) IBOutlet UILabel *wordLabel;
    @property (weak, nonatomic) IBOutlet UIButton *faviImg;
    @property (strong,nonatomic) NSString *searchStr;
    @property (strong,nonatomic) ViewController *viewController;
    @property (weak,nonatomic) NSString *searchValue;
    @property (nonatomic) BOOL faviOn;
    -(void) setViewColour : (UIColor *) color;
    -(void) updateFaviState : (BOOL) isFavi;
@end
