#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma - Core Data Stack
/**
 Setting up proper get setter for the fields they run automatically
 **/
@synthesize mom = _mom;
@synthesize moc = _moc;
@synthesize psc = _psc;

/*
 * Url to documentary function which be used in psc
 */

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/*
 * Model  is usually setting up the url link to the file and linking the file
 */
-(NSManagedObjectModel *) mom {
    
    if(_mom != nil) {
        return _mom;
    }
    NSURL *modelUrl = [[NSBundle mainBundle]URLForResource:@"Model" withExtension:@"momd"];
    _mom  = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelUrl];
    return _mom;
}

/* Steps for creating :
 * 1. Allocate itself with mom
 * 2. Get sql url from documents directory
 * 3. addPersistancStoreWithType
 */

-(NSPersistentStoreCoordinator *) psc {
    if(_psc!=nil) {
        return _psc;
    }
    
    _psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self mom]];
    NSURL *storeURL = [[self applicationDocumentsDirectory]URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error;
    NSString *errorDesc = @"Problem in connecting the data %@ %@";
    if(![_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        if(error!=nil)
        {
            NSLog(errorDesc,error,[error userInfo]);
            abort();
        }
    }
    return _psc;
}

/* Steps to create ManagedObjectContext
 * 1. Create moc with concurrency main queue
 * 2. Add Persistent Store Coordinator to moc
 */
-(NSManagedObjectContext *) moc {
    if(_moc != nil) {
        return _moc;
    }
    
    NSPersistentStoreCoordinator *t_psc = [self psc];
    if(t_psc == nil) {
        NSLog(@"PersistentStoreCoordinator is null");
        abort();
    }
    
    _moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_moc setPersistentStoreCoordinator:t_psc];
    return _moc;
}


#pragma - Core Data Utility functions

-(void)saveContext{
    NSManagedObjectContext *managedObject  = self.moc;
    if( managedObject==nil ) {
        return ;
    }
    NSError *error;
    if([managedObject hasChanges] && [managedObject save:&error])
    {
        if(error != nil)
        {
            NSLog(@"Error occured while saving context %@ Desc : %@",error,[error userInfo]);
        }
    }
}

@end
