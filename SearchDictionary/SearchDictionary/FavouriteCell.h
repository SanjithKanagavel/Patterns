#import "UIKit/UIKit.h"

@interface FavouriteCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet UIView *bgView;
    @property (weak, nonatomic) IBOutlet UILabel *searchStr;
    @property (weak, nonatomic) IBOutlet UILabel *searchVal;
    -(void) setViewColour : (UIColor *) color;
@end
