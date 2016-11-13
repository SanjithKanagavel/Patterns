//
//  FavouritesVC.m
//  SearchDictionary
//
//  Created by Sanjith J K on 13/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "FavouritesVC.h"
#import "SearchDictionary-Swift.h"
#import "FavouriteCell.h"

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
    [self.tableView registerClass:[FavouriteCell class] forCellReuseIdentifier:@"FavouriteCell"];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
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
    UIImage *image = [UIImage imageNamed:@"naviBg"];
    if(self.navigationItem.rightBarButtonItem == nil){
        NSLog(@"nil");
    }
    [self.navigationController.navigationBar.topItem setTitle:@"Favourites"];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                                      shadow, NSShadowAttributeName,
                                                                      [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                                     shadow, NSShadowAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil] forState:UIControlStateNormal];    

}

-(void) updateNavigationBar {
    [self.navigationController.navigationBar.topItem setTitle:@"Favourites"];
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 33, 33)];
    [btnRight setImage:[UIImage imageNamed:@"Help-44" ] forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    [barBtnRight setTintColor:[UIColor whiteColor]];
    [[[self tabBarController] navigationItem] setRightBarButtonItem:barBtnRight];
}

#pragma mark - Help functions

-(void)showHelp {
    
}

#pragma mark - Fetched results functions

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favourite" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateTime" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}


- (BOOL)retriveFavourites {
    NSManagedObjectContext *moc = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favourite"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateTime" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setReturnsObjectsAsFaults:NO];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    [favArr removeAllObjects];
    for(Favourite *fav in results) {
        [favArr addObject:fav];
    }
    if (!results) {
        NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([favArr count] == 0) {
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        self.label.center = self.view.center;
        [self.label setText:@"No results"];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0]];
    }
    else {
    }
    return [favArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavouriteCell *cell;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FavouriteCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
    NSUInteger colorIndex = (NSUInteger)indexPath.row;
    if( colorIndex > [bgColors count] - 1 ) {
        colorIndex = colorIndex % [bgColors count];
    }
    [cell setViewColour:[Utility colorFromHexString:bgColors[colorIndex]]];
    cell.searchVal.text = ((Favourite *)favArr[indexPath.row]).searchValue;
    cell.searchStr.text = ((Favourite *)favArr[indexPath.row]).searchStr;
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd-mm-yyyy hh:mm:ss"];
    NSString *date = [dateformate stringFromDate:((Favourite *)favArr[indexPath.row]).updateTime];
    cell.updateTime.text = date;
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}



@end