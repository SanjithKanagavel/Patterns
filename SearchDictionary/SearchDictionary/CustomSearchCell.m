#import "CustomSearchCell.h"

@implementation CustomSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self styleCell];
}
-(void)styleCell{
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.recentTextLbl setBackgroundColor:[UIColor clearColor]];
    [self.recentImgView setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.contentView.frame];
    selectedBackgroundView.backgroundColor = [UIColor clearColor];
    [self setSelectedBackgroundView:selectedBackgroundView];
}

@end
