//
//  CustomCell.h
//  SearchDictionary
//
//  Created by Sanjith J K on 08/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *wText;
@property (weak, nonatomic) IBOutlet UIView *bView;
-(void) setViewColour : (UIColor *) color;

@end
