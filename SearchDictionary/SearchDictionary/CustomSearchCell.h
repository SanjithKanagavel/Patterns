#import "UIKit/UIKit.h"
#import "ViewController.h"

@interface CustomSearchCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet UILabel *recentTextLbl;
    @property (weak, nonatomic) IBOutlet UIImageView *recentImgView;
    @property (weak, nonatomic) ViewController *vewCont;
@end
