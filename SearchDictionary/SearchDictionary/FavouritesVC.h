#import "UIKit/UIKit.h"
#import "CoreData/CoreData.h"
#import "AppDelegate.h"
#import "Hotline.h"
#import "SearchDictionary-Swift.h"
#import "FavouriteCell.h"
#import "Utility.h"

@interface FavouritesVC : UIViewController <NSFetchedResultsControllerDelegate>
    @property (strong, nonatomic) UILabel *label;
    @property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
