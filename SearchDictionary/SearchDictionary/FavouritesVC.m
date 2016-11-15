#import "FavouritesVC.h"

@interface FavouritesVC ()

@end

@implementation FavouritesVC

NSMutableArray *favArr;
NSArray *bgColors;

#pragma mark - ViewController functions

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBaseScreen];
    [self configureCoreData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateNavigationBar];
    if([self retriveFavourites]){
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Screen related functions

-(void) configureBaseScreen {
    favArr = [[NSMutableArray alloc] init];
    bgColors = @[ peterRiver,belizeHole,amethyst,wisteria,carrot,pumpkin,alizarin,pomegranate,turquoise, greenSea,emerald,nephritis,concrete,asbestos,wetAsphalt,midnightBlue ];
    [self.tableView registerClass:[FavouriteCell class] forCellReuseIdentifier:favouriteCell];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    UIView *view = [[UIView alloc]init];
    view.frame = self.tableView.frame;
    [view setAlpha:0.85];
    [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:naviBgstr]]];
    [self.tableView setBackgroundView:view];
    [self styleNavigation];
}

-(void)configureCoreData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.moc;
}

- (void) styleNavigation {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    UIImage *image = [UIImage imageNamed:naviBgstr];
    [self.navigationController.navigationBar.topItem setTitle:favourites];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                                      shadow, NSShadowAttributeName,
                                                                      [UIFont fontWithName:fontName size:21.0], NSFontAttributeName, nil]];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                                     shadow, NSShadowAttributeName,
                                                                     [UIFont fontWithName:fontName size:21.0], NSFontAttributeName, nil] forState:UIControlStateNormal];

}

-(void) updateNavigationBar {
    [self.navigationController.navigationBar.topItem setTitle:favourites];
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 33, 33)];
    [btnRight setImage:[UIImage imageNamed:helpStr ] forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    [barBtnRight setTintColor:[UIColor whiteColor]];
    [[[self tabBarController] navigationItem] setRightBarButtonItem:barBtnRight];
}

#pragma mark - Help functions

-(void)showHelp {
    [[Hotline sharedInstance] showFAQs:self];
}

#pragma mark - Fetched results functions

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:favourite inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:updateTime ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        abort();
    }
    return _fetchedResultsController;
}


- (BOOL)retriveFavourites {
    NSManagedObjectContext *moc = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:favourite];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:updateTime ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setReturnsObjectsAsFaults:NO];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    [favArr removeAllObjects];
    for(FavouriteMO *fav in results) {
        [favArr addObject:fav];
    }
    if (!results) {
        abort();
    }
    if([results count] == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, tableView.frame.size.width/2-5, 18)];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame),CGRectGetMinY(label1.frame), tableView.frame.size.width/2, 18)];
    [label1 setFont:[UIFont boldSystemFontOfSize:12]];
    [label1 setFont:[Utility getFont:17]];
    [label1 setTextColor:[UIColor whiteColor]];
    [label1 setText:searchStringF];
    [label2 setFont:[UIFont boldSystemFontOfSize:12]];
    [label2 setFont:[Utility getFont:17]];
    [label2 setTextColor:[UIColor whiteColor]];
    [label2 setText:searchValueF];
    [view addSubview:label1];
    [view addSubview:label2];
    [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:naviBgstr]]];
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(tableView == self.tableView) {
        if([favArr count] != 0) {
            return @"Search Results";
        }
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([favArr count] == 0) {
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        self.label.center = self.view.center;
        [self.label setText:noResultsStr];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setFont:[UIFont fontWithName:fontName size:21.0]];
    }
    else {
    }
    return [favArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavouriteCell *cell;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:favouriteCell owner:self options:nil];
    cell = [nib objectAtIndex:0];
    NSUInteger colorIndex = (NSUInteger)indexPath.row;
    if( colorIndex > [bgColors count] - 1 ) {
        colorIndex = colorIndex % [bgColors count];
    }
    [cell setViewColour:[Utility colorFromHexString:bgColors[colorIndex]]];
    cell.searchVal.text = ((FavouriteMO *)favArr[indexPath.row]).searchValue;
    cell.searchStr.text = ((FavouriteMO *)favArr[indexPath.row]).searchStr;
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}



@end
