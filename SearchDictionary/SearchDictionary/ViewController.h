//
//  ViewController.h
//  SearchDictionary
//
//  Created by Sanjith J K on 08/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "CoreData/CoreData.h"
#import "Constants.h"
#import "Utility.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController <NSFetchedResultsControllerDelegate>
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
    @property (strong, nonatomic) UIActivityIndicatorView *indicator;
    @property (strong, nonatomic) UILabel *label;
    @property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
    @property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
    - (void)addFavourite:(NSString *)searchStr searchValue:(NSString *)searchValue;
    - (void)removeFavourite:(NSString *)searchStr searchValue:(NSString *)searchValue;
@end
