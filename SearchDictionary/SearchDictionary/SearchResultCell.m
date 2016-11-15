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
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction)];
    singleTap.numberOfTapsRequired = 1;
    [self.faviImg setUserInteractionEnabled:YES];
    [self.faviImg addGestureRecognizer:singleTap];
}

-(void)clickAction {
    [self showhideFavi:YES];
}

-(void)showhideFavi:(BOOL)update{
    if(!self.faviOn) {
        [self.faviImg setImage:[UIImage imageNamed:starUnfilledStr]];
        if(update) {
            [self.viewController removeFavourite:self.searchStr searchValue:self.searchValue];
        }
    } else {
        [self.faviImg setImage:[UIImage imageNamed:starFilledStr]];
        if(update) {
            [self.viewController addFavourite:self.searchStr searchValue:self.searchValue];
            }
    }
    self.faviOn = !self.faviOn;
}

-(void) styleCell {
    /*self.bgView.layer.cornerRadius = 10.0f;
    self.bgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bgView.layer.borderWidth = 1.5f;
    self.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bgView.layer.shadowOpacity = 0.8;
    self.bgView.layer.shadowRadius = 3.0;
    self.bgView.layer.shadowOffset = CGSizeMake(2.0, 2.0);*/
    self.wordLabel.font = [UIFont fontWithName:fontName size:21.0];
    self.wordLabel.textColor  = [UIColor whiteColor];
}

-(void) setViewColour : (UIColor *) color{
    self.bgView.backgroundColor = color;
}

-(void) updateFaviState : (BOOL) isFavi{
    self.faviOn = isFavi? YES : NO ;
    [self showhideFavi:NO];
}


@end
