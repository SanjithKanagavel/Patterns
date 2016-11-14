#import "UIKit/UIKit.h"

@interface FavouriteCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet UIView *bgView;
    @property (weak, nonatomic) IBOutlet UILabel *searchStr;
    @property (weak, nonatomic) IBOutlet UILabel *searchVal;
    @property (weak, nonatomic) IBOutlet UILabel *updateTime;
    -(void) setViewColour : (UIColor *) color;
@end
