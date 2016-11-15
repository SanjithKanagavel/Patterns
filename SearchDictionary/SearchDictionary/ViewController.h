#import "UIKit/UIKit.h"
#import "CoreData/CoreData.h"
#import "AppDelegate.h"
#import "hotline.h"
#import "Utility.h"
#import "Constants.h"


@interface ViewController : UIViewController <NSFetchedResultsControllerDelegate>
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
    @property (strong, nonatomic) UIActivityIndicatorView *indicator;
    @property (strong, nonatomic) UIVisualEffectView *indicatorVisualView;
    @property (strong, nonatomic) UILabel *label;
    @property (strong, nonatomic) NSFetchedResultsController *favouritesResultsController;
    @property (strong, nonatomic) NSFetchedResultsController *recentResultsController;
    @property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
    @property (strong, nonatomic) UIVisualEffectView *suggestionView;
    @property (strong, nonatomic) UITableView *suggestionTableView;
    - (void)addFavourite:(NSString *)searchStr searchValue:(NSString *)searchValue;
    - (void)removeFavourite:(NSString *)searchStr searchValue:(NSString *)searchValue;
@end

