#import "ViewController.h"
#import "SearchResultCell.h"
#import "RecentsMO.h"
#import "FavouriteMO.h"
#import "CustomSearchCell.h"
#import "RecentSearch.h"
#import "Contacts/Contacts.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate>
@end

@implementation ViewController

BOOL startChange;
NSInteger count,screenWidth,screenHeight;
NSArray *colors;
NSMutableArray *recentSearches,*resArr,*contacts,*suggestions;
NSMutableSet *tempSet;
NSSet *wordSet;
NSThread *reloadThread;
CGFloat KeyboardHeight;

#pragma mark - ViewController functions

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBaseScreen];
    [self configureCoreData];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateNavigationBar];
    [self registerForKeyboardNotifications];
}

-(void) viewDidDisappear:(BOOL)animated {
    [self deregisterForKeyboardNotification];
    [super viewDidDisappear:animated];
}

-(void)deregisterForKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow: (NSNotification *) notification{
    if(self.suggestionView == nil){
        NSDictionary *keyboardInfo = [notification userInfo];
        CGRect keyboardSize = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        KeyboardHeight = keyboardSize.size.height;
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.suggestionView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.suggestionView.frame = CGRectMake( CGRectGetMinX(self.searchBar.frame),CGRectGetMaxY(self.searchBar.frame), screenWidth, screenHeight - CGRectGetMaxY(self.searchBar.frame) );
        self.suggestionTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - KeyboardHeight - 100) style:UITableViewStylePlain];
        self.suggestionTableView.backgroundColor = [UIColor clearColor];
        self.suggestionTableView.delegate = self;
        self.suggestionTableView.dataSource = self;
        [self.suggestionTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [self.suggestionTableView setSeparatorColor:[UIColor clearColor]];
        [self.suggestionTableView registerClass:[CustomSearchCell class] forCellReuseIdentifier:searchResultCell];
        [self.suggestionTableView setAlpha:0];
        [self.suggestionView setAlpha:0];
        [self.suggestionView addSubview:self.suggestionTableView];
    }
    [self.suggestionTableView setContentOffset:CGPointZero animated:YES];
    [self.view addSubview:self.suggestionView];
    [self fetchRecentSearches];
    [self showSuggestions:emptyStr];
    [UIView animateWithDuration:0 delay:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.suggestionView setAlpha:1.0];
        [self.suggestionTableView setAlpha:1.0];
    } completion:nil];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    [self.suggestionView removeFromSuperview];
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Memory low");
}

#pragma mark - Screen related functions

-(void) configureBaseScreen {
    wordSet = [NSSet setWithArray: [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:wordsStr ofType:txtStr] encoding:NSUTF8StringEncoding error:NULL] componentsSeparatedByString:newLineStr]];
    count = 0;
    startChange = false;
    resArr = [[NSMutableArray alloc]init];
    screenWidth = [[UIScreen mainScreen]bounds].size.width;
    screenHeight = [[UIScreen mainScreen]bounds].size.height;
    tempSet = [[NSMutableSet alloc]init];
    colors = @[ asbestos ]; //removed all other colors
    recentSearches = [[NSMutableArray alloc]init];
    contacts = [[NSMutableArray alloc]init];
    suggestions = [[NSMutableArray alloc]init];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.indicatorVisualView  = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.indicatorVisualView .frame = CGRectMake( CGRectGetMinX(self.searchBar.frame),CGRectGetMaxY(self.searchBar.frame), screenWidth, screenHeight - CGRectGetMaxY(self.searchBar.frame) - CGRectGetMinY(self.navigationController.navigationBar.frame) );
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
    [self.indicator setColor:[UIColor whiteColor]];
    [self.indicatorVisualView addSubview:self.indicator];
    [self.view addSubview:self.indicatorVisualView];
    [self.indicator setCenter:CGPointMake(self.indicatorVisualView.center.x,self.indicatorVisualView.frame.size.height/2)];
    [self hideActivityIndicator];
    
    [self.tableView registerClass:[SearchResultCell class] forCellReuseIdentifier:searchResultCell];
    UIView *view = [[UIView alloc]init];
    view.frame = self.tableView.frame;
    [view setAlpha:0.85];
    [view setBackgroundColor:[Utility colorFromHexString:colors[0]]];
    [self.tableView setBackgroundView:view];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchBar setTintColor:[UIColor whiteColor]];
    [self.searchBar setKeyboardAppearance:UIKeyboardAppearanceDark];
    UITextField *textField = [self.searchBar valueForKey: _searchFieldStr];
    [textField setTextColor:[UIColor blackColor]];
    [textField setFont:[Utility getFont:17]];
    UIButton *button = [self.searchBar valueForKey: cancelBtnStr];
    [button setTintColor:[UIColor whiteColor]];
    [button.titleLabel setFont:[Utility getFont:17]];
    [button setTitle:search forState:UIControlStateNormal];
    [self styleNavigation];
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    [self fetchContacts];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:cancelStr
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor grayColor];
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary *fontValues = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName,shadow, NSShadowAttributeName,[Utility getFont:17], NSFontAttributeName, nil];
    [doneButton setTitleTextAttributes:fontValues forState:UIControlStateNormal];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flex,doneButton, nil]];
    self.searchBar.inputAccessoryView = keyboardDoneButtonView;

}

- (IBAction)doneClicked:(id)sender {
    [self.searchBar resignFirstResponder];
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
    [btnRight setTitle:helpStr forState:UIControlStateNormal];
    [btnRight setImage:[UIImage imageNamed:helpStr ] forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    [barBtnRight setTintColor:[UIColor whiteColor]];
    [[[self tabBarController] navigationItem] setRightBarButtonItem:barBtnRight];
}

- (void) reloadData:(NSString *) searchStr {
    for(int i=0; i<[searchStr length]; i++) {
        [self getCombinations:searchStr numberIndex:0 groups:nil lastGroupIndex:0 remainingPointers:i];
        NSLog(@"3");
    }
    tempSet = [self processSet];
    [resArr removeAllObjects];
    [resArr addObjectsFromArray:[tempSet allObjects]];
    NSLog(@"5");
    [self sortArray];
}

#pragma mark - Help functions

-(void)showHelp {
    [[Hotline sharedInstance] showFAQs:self];
}

#pragma mark - Search bar functions

-(void)startSearch :(NSString *)str{
    self.searchBar.text = str;
    [self searchBarSearchButtonClicked:self.searchBar];
    [self.suggestionView removeFromSuperview];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [self searchBarSearchButtonClicked:self.searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if([searchBar.text isEqual:emptyStr]){
        return;
    }
    [self addSearches:searchBar.text];
    if( reloadThread != nil ) {
        reloadThread = nil;
        [reloadThread cancel];
    }
    reloadThread = [[NSThread alloc] initWithBlock:^(void){
        [tempSet removeAllObjects];
        [self reloadData:searchBar.text];
    }];
    
    [self showActivityIndicator];
    [reloadThread start];
    [searchBar resignFirstResponder];
    
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self showSuggestions:searchText];
}

#pragma mark - Activity Indicator functions

-(void) showActivityIndicator{
    [self.indicatorVisualView setHidden:NO];
    [self.indicator startAnimating];
}

-(void) hideActivityIndicator {
    [self.indicator stopAnimating];
    [self.indicatorVisualView setHidden:YES];
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
        NSLog(@"2");
        return;
    }
    else if( ( numberIndex == [numberSequence length] - 1 ) || ( remainingPointers == [numberSequence length] )){
        // not the last index pointer and it dont have the pointers left
        return;
    }
    else  {
        NSMutableArray *copy1 = [[NSMutableArray alloc]init];
        [copy1 addObjectsFromArray:groups];
        //Use pointer in this number
        {
            NSString *subStr;
            subStr = [numberSequence substringWithRange:NSMakeRange(lastGroupIndex, (numberIndex-(lastGroupIndex-1)))];
            [copy1 addObject:subStr];
            [self getCombinations:numberSequence numberIndex:numberIndex+1 groups:copy1 lastGroupIndex:numberIndex+1 remainingPointers:remainingPointers-1];
        }
        
        NSMutableArray *copy2 = [[NSMutableArray alloc]init];
        [copy2 addObjectsFromArray:groups];
        //Dont use the pointer and pass it on to the next combination
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
        if(![tempSet containsObject:formation] && ![[NSPredicate predicateWithFormat:matchPredicate, numRegex] evaluateWithObject:formation]) { //Check for duplicates
                [tempSet addObject:formation];
        }
        return;
    }
    NSString *copyStr = [[NSString alloc]initWithString:formation];
    NSMutableArray *combinationArr;
    NSMutableArray *possibleCombos = [[NSMutableArray alloc]init];
    //long limit = ([self.searchBar.text length]/2)-1;
    //if([groups[index] length] > ( limit < 0 ? 1 : limit )) {
    if([groups[index] length] > 2) {
        NSLog(@"1");
        combinationArr = [self getWordCombinations:emptyStr word:groups[index]];
        NSMutableSet *set1 = [NSMutableSet setWithArray: combinationArr];
        [set1 intersectSet: wordSet];
        NSArray *arr = [set1 allObjects];
        [possibleCombos addObjectsFromArray:arr];
    }
    //Retrieve combos possible and find prepare word combos to find in dict.
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
    NSLog(@"6");
    NSArray *t_Array = [NSArray arrayWithArray:resArr];
    t_Array = [t_Array sortedArrayUsingComparator:^NSComparisonResult(NSString *first, NSString *second){
        return [self sortToText:first withLengthOf:second];
    }];
    [resArr removeAllObjects];
    [resArr addObjectsFromArray:t_Array];
    dispatch_async(dispatch_get_main_queue(),^(void){
        [self.tableView setContentOffset:CGPointMake(0, 0 - self.tableView.contentInset.top)];
        [self.tableView reloadData];
        [self hideActivityIndicator];
        NSLog(@"8");
    });
}

-(NSMutableSet *)processSet {
    NSMutableSet *refinedSet = [[NSMutableSet alloc]init];
    for(NSString *str in tempSet){
        NSString *val = [self processString:str];
        if(![[NSPredicate predicateWithFormat:matchPredicate, numRegex] evaluateWithObject:val]) {
            [refinedSet addObject:val];
        }
    }
    return refinedSet;
}

-(NSString *)processString:(NSString *)str {
    NSString *pString = [[NSString alloc]init];
    NSArray *subArrays = [str componentsSeparatedByString:hypenStr];
    for(int i=0;i<[subArrays count]-1;i++) {
        pString = [pString stringByAppendingString:subArrays[i]];
        if(!([[NSPredicate predicateWithFormat:matchPredicate, numRegex] evaluateWithObject:subArrays[i]] && [[NSPredicate predicateWithFormat:matchPredicate, numRegex] evaluateWithObject:subArrays[i+1]])){
            pString = [pString stringByAppendingString:hypenStr];
        }
    }
    pString = [pString stringByAppendingString:subArrays[[subArrays count]-1]];
    return pString;
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

- (NSFetchedResultsController *)favouritesResultsController {
    if( _favouritesResultsController != nil) {
        return _favouritesResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:favourite inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:updateTime ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.favouritesResultsController = aFetchedResultsController;
    NSError *error = nil;
    if (![self.favouritesResultsController performFetch:&error]) {
        abort(); //
    }
    return _favouritesResultsController;
}

- (NSFetchedResultsController *)recentResultsController {
    if(_recentResultsController != nil) {
        return _recentResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:recents inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:updateTime ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.recentResultsController = aFetchedResultsController;
    NSError *error = nil;
    if (![self.recentResultsController performFetch:&error]) {
        abort();
    }
    return _recentResultsController;
}


- (void)addSearches:(NSString *)str {
    if(![self deleteExisitingSimilarSearch:str]){
        return;
    }
    NSManagedObjectContext *context = [self.recentResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.recentResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    NSDate *date = [NSDate date];
    [newManagedObject setValue:date forKey:updateTime];
    [newManagedObject setValue:str forKey:searchStr];
    NSError *error = nil;
    if (![context save:&error]) {
        abort();
    }
}

-(BOOL) deleteExisitingSimilarSearch:(NSString *)str {
    NSManagedObjectContext *moc = [self.recentResultsController managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:recents];
    NSPredicate *searchStrPredicate = [NSPredicate predicateWithFormat:searchStrEquals, str];
    request.predicate = searchStrPredicate;
    [request setReturnsObjectsAsFaults:NO];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
    if (!results) {
        return NO;
    }
    for (NSManagedObject *product in results) {
        [moc deleteObject:product];
    }
    if([moc hasChanges] && [moc save:&error]) {
        NSLog(@"deleted successfully");
    }
    return YES;

}

-(void) fetchRecentSearches {
    NSManagedObjectContext *moc = [self.recentResultsController managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:recents];
    [request setReturnsObjectsAsFaults:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:updateTime ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
    if (!results) {
        abort();
    }
    [recentSearches removeAllObjects];
    for(RecentsMO *recent in results) {
        RecentSearch *rs = [[RecentSearch alloc]init];
        rs.phoneNumber = recent.searchStr;
        rs.fromPhoneBook = NO;
        [recentSearches addObject:rs];
    }
}

-(void) fetchContacts {
    CNContactStore *store = [[CNContactStore alloc]init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted,NSError *_Nullable error){
        if(granted == YES) {
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:store.defaultContainerIdentifier];
            NSArray *rawContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactPhoneNumbersKey] error:nil];
            for(CNContact *contact in rawContacts){
                for(CNLabeledValue *phone in contact.phoneNumbers) {
                    [contacts addObject:[self formatPhoneNumber:[phone.value stringValue]]];
                }
            }
        }
    }];
    for(NSString *contact in contacts) {
        NSLog(@"%@",contact);
    }
}

-(NSString *)formatPhoneNumber :(NSString *)phoneNumber {
    if([phoneNumber isEqualToString:@"9994491892"]) {
        NSLog(@"Equal");
    }
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
    return phoneNumber;
}

-(void) showSuggestions : (NSString *) str {
    [suggestions removeAllObjects];
    if( [str length] == 0 ) {
        [suggestions addObjectsFromArray:recentSearches];
    } else {
        for(RecentSearch *rS in recentSearches){
            if([rS.phoneNumber hasPrefix:str]){
                RecentSearch *recSearch = [[RecentSearch alloc]init];
                recSearch.phoneNumber = rS.phoneNumber;
                recSearch.fromPhoneBook = NO;
                [suggestions addObject:recSearch];
            }
        }
        for(NSString *contact in contacts){
            if([contact hasPrefix:str] && ![self isDuplicateSuggestion:contact suggestionsArr:suggestions]){
                RecentSearch *recSearch = [[RecentSearch alloc]init];
                recSearch.phoneNumber = contact;
                recSearch.fromPhoneBook = YES;
                [suggestions addObject:recSearch];
            }
        }
    }
    [self.suggestionTableView reloadData];
}

-(BOOL) isDuplicateSuggestion :(NSString *)str suggestionsArr:(NSMutableArray *)suggestionsArr {
    for(RecentSearch *rS in suggestionsArr) {
        if([rS.phoneNumber isEqual:str]) {
            return YES;
        }
    }
    return NO;
}

- (void)addFavourite:(NSString *)sStr searchValue:(NSString *)sVal {
    NSManagedObjectContext *context = [self.favouritesResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.favouritesResultsController fetchRequest] entity];
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
    NSManagedObjectContext *moc = [self.favouritesResultsController managedObjectContext];
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
    if([moc hasChanges] && [moc save:&error]) {
        NSLog(@"deleted successfully");
    }
}

- (BOOL)retriveFavourite:(NSString *)searchValue {
    NSManagedObjectContext *moc = [self.favouritesResultsController managedObjectContext];
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
    if(tableView == self.tableView) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else {
        RecentSearch *rs = suggestions[indexPath.row];
        [self startSearch:rs.phoneNumber];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tableView) {
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
    else {
        return [suggestions count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tableView) {
        SearchResultCell *cell;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:searchResultCell owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    else {
        CustomSearchCell *cell;
        RecentSearch *rs = suggestions[indexPath.row];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:customSearchCell owner:self options:nil];
        cell = [nib objectAtIndex:0];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.recentTextLbl.text = rs.phoneNumber;
        cell.vewCont = self;
        [cell updateIcon:rs.fromPhoneBook];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*SearchResultCell *cell =  [self.tableView cellForRowAtIndexPath:indexPath];
    UITableViewRowAction *starUnstar = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Star" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){}];
    starUnstar.backgroundColor = cell.bgView.backgroundColor;*/
    //return @[starUnstar];
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*if(self.tableView == tableView) {
        return 70;
    }
    else {
        return 40;
    }*/
    return 50;
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
    
    //sort by groups Group is major priority and name is the minor priority
    NSInteger firstNoCount = [self countNumbers:firstStr];
    NSInteger secondNoCount = [self countNumbers:secondStr];
    
    NSInteger firstGroupCount = [[firstStr componentsSeparatedByString:@"-"] count];
    NSInteger secondGroupCount = [[secondStr componentsSeparatedByString:@"-"] count];
    
    if ( firstNoCount == secondNoCount ) {
        if(firstGroupCount==secondGroupCount)
            return NSOrderedSame;
        else if(firstGroupCount < secondGroupCount)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }
    else if (firstNoCount > secondNoCount) {
        return NSOrderedDescending;
    }
    else if (firstGroupCount > secondGroupCount && firstGroupCount < secondGroupCount) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedAscending;
    }
    //else if (firstNoCount == secondNoCount && firstGroupCount == secondGroupCount)
    //    return NSOrderedSame;
    
    /*NSInteger firstCount = [self countNumbers:firstStr];
    NSInteger secondCount = [self countNumbers:secondStr];
    if (firstCount > secondCount)
        return NSOrderedDescending;
    else if (firstCount < secondCount)
        return NSOrderedAscending;
    else
        return NSOrderedAscending;
     */
}

@end

