#import "UIKit/UIKit.h"
#import "CoreData/CoreData.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
    @property (strong, nonatomic) UIWindow *window;
    @property (strong,readonly,nonatomic) NSManagedObjectModel *mom;
    @property (strong,readonly,nonatomic) NSManagedObjectContext *moc;
    @property (strong,readonly,nonatomic) NSPersistentStoreCoordinator *psc;
    -(void)saveContext;
    - (NSURL *)applicationDocumentsDirectory;
@end

