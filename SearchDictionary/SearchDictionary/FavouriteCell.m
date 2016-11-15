#import "FavouriteCell.h"

@implementation FavouriteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //[self styleCell];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];    
}

-(void) styleCell {
    self.bgView.layer.cornerRadius = 10.0f;
    self.bgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bgView.layer.borderWidth = 1.5f;
    self.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bgView.layer.shadowOpacity = 0.8;
    self.bgView.layer.shadowRadius = 3.0;
    self.bgView.layer.shadowOffset = CGSizeMake(2.0, 2.0);    
}

-(void) setViewColour : (UIColor *) color{
    self.bgView.backgroundColor = color;
}


@end
