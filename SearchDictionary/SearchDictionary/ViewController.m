#import "ViewController.h"
#import "SearchResultCell.h"

@interface ViewController ()
@end

@implementation ViewController

BOOL startChange;
NSInteger count,screenWidth,screenHeight;
NSArray *resArr,*colors,*wordArray;
NSMutableSet *tempArr;
NSThread *reloadThread;

#pragma mark - ViewController functions

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBaseScreen];
    [self configureCoreData];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateNavigationBar];
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Screen related functions

-(void) configureBaseScreen {
    
    wordArray = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:wordsStr ofType:txtStr] encoding:NSUTF8StringEncoding error:NULL] componentsSeparatedByString:newLineStr];
    count = 0;
    startChange = false;
    resArr = [[NSArray alloc] init];
    tempArr = [[NSMutableSet alloc]init];
    screenWidth = [[UIScreen mainScreen]bounds].size.width;
    screenHeight = [[UIScreen mainScreen]bounds].size.height;
    colors = @[ peterRiver,belizeHole,amethyst,wisteria,carrot,pumpkin,alizarin,pomegranate,turquoise, greenSea,emerald,nephritis,concrete,asbestos,wetAsphalt,midnightBlue ];
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
    [self.indicator setCenter:self.view.center];
    [self.indicator setColor:[UIColor redColor]];
    [self.view addSubview:self.indicator];
    [self.indicator bringSubviewToFront:self.view];
    
    [self.tableView registerClass:[SearchResultCell class] forCellReuseIdentifier:searchResultCell];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.searchBar setTintColor:[UIColor whiteColor]];
    
    UITextField *textField = [self.searchBar valueForKey: _searchFieldStr];
    [textField setTextColor:[UIColor blackColor]];
    [textField setFont:[Utility getFont:17]];
    UIButton *button = [self.searchBar valueForKey: cancelBtnStr];
    [button setTintColor:[UIColor whiteColor]];
    [button.titleLabel setFont:[Utility getFont:17]];
    [self styleNavigation];
}

-(void)configureCoreData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.moc;
}

- (void) styleNavigation {
    
    UIImage *image = [UIImage imageNamed:naviBgstr];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *fontValues = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,shadow, NSShadowAttributeName,[Utility getFont:21], NSFontAttributeName, nil];
    NSDictionary *smallFontValues = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,shadow, NSShadowAttributeName,[Utility getFont:12], NSFontAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes: fontValues];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:fontValues  forState:UIControlStateNormal];
    [self.tabBarController.tabBar setBarTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:naviBgstr]]];
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:smallFontValues forState:UIControlStateNormal];
    
}

-(void) updateNavigationBar {
    [self.navigationController.navigationBar.topItem setTitle:search];
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 33, 33)];
    [btnRight setImage:[UIImage imageNamed:helpStr ] forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    [barBtnRight setTintColor:[UIColor whiteColor]];
    [[[self tabBarController] navigationItem] setRightBarButtonItem:barBtnRight];
}

- (void) reloadData:(NSString *) searchStr {
    for(int i=0; i<[searchStr length]; i++) {
        [self getCombinations:searchStr numberIndex:0 groups:nil lastGroupIndex:0 remainingPointers:i];
    }
    tempArr = [self processSet];
    resArr = [tempArr allObjects];
    [self sortArray];
}

#pragma mark - Help functions

-(void)showHelp {
    
}

#pragma mark - Search bar functions

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = emptyStr;
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {    
    if( reloadThread != nil ) {
        reloadThread = nil;
        [reloadThread cancel];
    }
    reloadThread = [[NSThread alloc] initWithBlock:^(void){
        [tempArr removeAllObjects];
        [self reloadData:searchBar.text];
    }];
    
    [self showActivityIndicator];
    [reloadThread start];
    [searchBar resignFirstResponder];
    
}


#pragma mark - Activity Indicator functions

-(void) showActivityIndicator{
    [self.indicator startAnimating];
}

-(void) hideActivityIndicator {
    [self.indicator stopAnimating];
}

#pragma mark - Combination functions

int groupsCount = 0;
int combinationsCount = 0;

-(NSString *) getStringcode : (NSInteger) number {
    switch (number) {
        case 2:
            return abc;
        case 3:
            return def;
        case 4:
            return ghi;
        case 5:
            return jkl;
        case 6:
            return mno;
        case 7:
            return pqrs;
        case 8:
            return tuv;
        case 9:
            return wxyz;
        default:
            return emptyStr;
    }
}


-(NSMutableArray *) getWordCombinations:(NSString *) prefix word:(NSString *) word {
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    if([word length] == 0 ) {
        return [NSMutableArray arrayWithObject:prefix];
    }
    NSString *charVals = [self getStringcode:[[word substringWithRange:NSMakeRange(0,1)] intValue]];
    for ( NSInteger i=0; i<[charVals length]; i++) {
        NSString *removedStr = [charVals substringWithRange:NSMakeRange(i,1)];
        NSString *remainStr = [word substringWithRange:NSMakeRange(1,[word length]-1)];
        [arr addObjectsFromArray:[self getWordCombinations:[NSString stringWithFormat:tStrFormat,prefix,removedStr] word:remainStr]];
    }
    return arr;
}

-(void) getCombinations:(NSString *) numberSequence numberIndex:(NSInteger)numberIndex groups:(NSMutableArray *)groups lastGroupIndex:(NSInteger)lastGroupIndex remainingPointers:(NSInteger)remainingPointers
{
    if ( groups == nil ) {
        groups = [[NSMutableArray alloc]init];
    }
    
    if(remainingPointers == 0 ) {
        if(numberIndex < [numberSequence length]) {
            [groups addObject:[numberSequence substringWithRange:NSMakeRange(numberIndex, [numberSequence length] - numberIndex)]];
        }
        groupsCount++;
        [self applyWordCombinations:groups index:0 formation:nil];
        return;
    }
    else if( ( numberIndex == [numberSequence length] - 1 ) || ( remainingPointers == [numberSequence length] )){
        return;
    }
    else  {
        NSMutableArray *copy1 = [[NSMutableArray alloc]init];
        [copy1 addObjectsFromArray:groups];
        //place the pointer
        {
            NSString *subStr;
            subStr = [numberSequence substringWithRange:NSMakeRange((lastGroupIndex==0)?0:(lastGroupIndex), (numberIndex-(lastGroupIndex-1)))];
            [copy1 addObject:subStr];
            [self getCombinations:numberSequence numberIndex:numberIndex+1 groups:copy1 lastGroupIndex:numberIndex+1 remainingPointers:remainingPointers-1];
        }
        
        NSMutableArray *copy2 = [[NSMutableArray alloc]init];
        [copy2 addObjectsFromArray:groups];
        //dont place the pointer
        {
            [self getCombinations:numberSequence numberIndex:numberIndex+1 groups:copy2 lastGroupIndex:lastGroupIndex remainingPointers:remainingPointers];
        }
    }
}

-(void) applyWordCombinations: (NSMutableArray *) groups index:(NSInteger)index formation:(NSString*)formation {
    if(!formation){
        formation = [[NSString alloc]init];
    }
    if(index == [groups count]) { //insert
        if(![tempArr containsObject:formation]) {
            NSString *numberRegex = numRegex;
            NSPredicate *numberTest = [NSPredicate predicateWithFormat:matchPredicate, numberRegex];
            if(![numberTest evaluateWithObject:formation]) {
                [tempArr addObject:formation];
            }
        }
        return ;
    }
    NSString *copyStr = [[NSString alloc]initWithString:formation];
    NSMutableArray *combinationArr;
    NSMutableArray *possibleCombos = [[NSMutableArray alloc]init];
    if([groups[index] length] > (([self.searchBar.text length]/2)-1)) {
        combinationArr = [self getWordCombinations:emptyStr word:groups[index]];
        NSMutableSet *set1 = [NSMutableSet setWithArray: combinationArr];
        NSSet *set2 = [NSSet setWithArray: wordArray];
        [set1 intersectSet: set2];
        NSArray *arr = [set1 allObjects];
        [possibleCombos addObjectsFromArray:arr];
    }
    if([possibleCombos count] == 0) {
        copyStr = [copyStr stringByAppendingString:groups[index]];
        if(index+1 < [groups count]) {
            copyStr = [copyStr stringByAppendingString:hypenStr];
        }
        [self applyWordCombinations:groups index:index+1 formation:copyStr];
    } else {
        for( int i = 0; i<[possibleCombos count]; i++) {
            copyStr = [formation stringByAppendingString:possibleCombos[i]];
            if(index+1 < [groups count]) {
                copyStr = [copyStr stringByAppendingString:hypenStr];
            }
            [self applyWordCombinations:groups index:index+1 formation:copyStr];
        }
    }
    
}

-(void) sortArray {
    resArr = [resArr sortedArrayUsingComparator:^NSComparisonResult(NSString *first, NSString *second){
        return [self sortToText:first withLengthOf:second];
    }];
    dispatch_async(dispatch_get_main_queue(),^(void){
        [self.tableView reloadData];
        [self hideActivityIndicator];
    });
}

-(NSMutableSet *)processSet {
    NSMutableSet *refinedSet = [[NSMutableSet alloc]init];
    for(NSString *str in tempArr){
        [refinedSet addObject:[self processString:str]];
    }
    return refinedSet;
}

-(NSString *)processString:(NSString *)str {
    NSString *pString = [[NSString alloc]init];
    NSArray *subArrays = [str componentsSeparatedByString:hypenStr];
    for(int i=0;i<[subArrays count]-1;i++) {
        pString = [pString stringByAppendingString:subArrays[i]];
        if(!([self onlyNumbers:subArrays[i]] && [self onlyNumbers:subArrays[i+1]])){
            pString = [pString stringByAppendingString:hypenStr];
        }
    }
    pString = [pString stringByAppendingString:subArrays[[subArrays count]-1]];
    return pString;
}

-(BOOL) onlyNumbers : (NSString *)str {
    NSString *numberRegex = numRegex;
    NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:matchPredicate, numberRegex];
    return [regexPredicate evaluateWithObject:str];
}

-(NSInteger) countNumbers : (NSString *)str {
    NSInteger count = 0;
    for(int i = 0;i<[str length];i++){
        NSString *val = [str substringWithRange:NSMakeRange(i, 1)];
        NSString *numberRegex = numRegex;
        NSPredicate *test = [NSPredicate predicateWithFormat:matchPredicate, numberRegex];
        if([test evaluateWithObject:val]) {
            count++;        
        }
    }
    return count;
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:updateTime ascending:NO];
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

- (void)addFavourite:(NSString *)sStr searchValue:(NSString *)sVal {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    NSDate *date = [NSDate date];
    [newManagedObject setValue:date forKey:updateTime];
    [newManagedObject setValue:sStr forKey:searchStr];
    [newManagedObject setValue:sVal forKey:searchValue];
    NSError *error = nil;
    if (![context save:&error]) {
        abort();
    }    
}

- (void)removeFavourite:(NSString *)searchStr searchValue:(NSString *)searchValue {
    NSManagedObjectContext *moc = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:favourite];
    NSPredicate *searchStrPredicate = [NSPredicate predicateWithFormat:searchValueEquals, searchValue];
    request.predicate = searchStrPredicate;
    [request setReturnsObjectsAsFaults:NO];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
    if (!results) {
        abort();
    }
    for (NSManagedObject *product in results) {
        [moc deleteObject:product];
    }
}

- (BOOL)retriveFavourite:(NSString *)searchValue {
    NSManagedObjectContext *moc = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:favourite];
    NSPredicate *searchStrPredicate = [NSPredicate predicateWithFormat:searchValueEquals, searchValue];
    request.predicate = searchStrPredicate;
    [request setReturnsObjectsAsFaults:NO];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
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

#pragma mark - UITableView Functions

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([resArr count] == 0) {
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        self.label.center = self.view.center;
        [self.label setText:noResultsStr];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setFont:[Utility getFont:21]];
    }
    else {
    }
    return [resArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:searchResultCell owner:self options:nil];
    cell = [nib objectAtIndex:0];
    NSUInteger colorIndex = (NSUInteger)indexPath.row;
    if( colorIndex > [colors count] - 1 ) {
        colorIndex = colorIndex % [colors count];
    }
    [cell setViewColour:[Utility colorFromHexString:colors[colorIndex]]];
    cell.wordLabel.text = resArr[indexPath.row];
    cell.searchStr = self.searchBar.text;
    cell.searchValue = cell.wordLabel.text;
    cell.viewController = self;
    [cell updateFaviState:[self retriveFavourite:cell.wordLabel.text]];
    return cell;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - NSComparision function

- (NSComparisonResult)compareLengthOf:(NSString *)firstStr withLengthOf:(NSString *)secondStr {
    if ([firstStr length] > [secondStr length])
        return NSOrderedDescending;
    else if ([firstStr length] < [secondStr length])
        return NSOrderedAscending;
    else
        return NSOrderedSame;
}

- (NSComparisonResult)sortToText:(NSString *)firstStr withLengthOf:(NSString *)secondStr {
    NSInteger firstCount = [self countNumbers:firstStr];
    NSInteger secondCount = [self countNumbers:secondStr];
    if (firstCount > secondCount)
        return NSOrderedDescending;
    else if (firstCount < secondCount)
        return NSOrderedAscending;
    else
        return NSOrderedSame;
}

@end

