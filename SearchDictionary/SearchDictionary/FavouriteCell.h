//
//  FavouriteCell.h
//  SearchDictionary
//
//  Created by Sanjith J K on 13/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouriteCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet UIView *bgView;
    @property (weak, nonatomic) IBOutlet UILabel *searchStr;
    @property (weak, nonatomic) IBOutlet UILabel *searchVal;
    @property (weak, nonatomic) IBOutlet UILabel *updateTime;
    -(void) setViewColour : (UIColor *) color;
@end
