//
//  FavouritesVC.h
//  SearchDictionary
//
//  Created by Sanjith J K on 13/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "CoreData/CoreData.h"
#import "AppDelegate.h"
#import "Utility.h"

@interface FavouritesVC : UIViewController <NSFetchedResultsControllerDelegate>
    @property (strong, nonatomic) UILabel *label;
    @property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
