#import "AppDelegate.h"
#import "Hotline.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    HotlineConfig *config = [[HotlineConfig alloc]initWithAppID:@"<APP-ID>"  andAppKey:@"<APP-KEY>"];
    config.voiceMessagingEnabled = YES;
    config.pictureMessagingEnabled = YES;
    config.cameraCaptureEnabled = YES;
    config.agentAvatarEnabled = YES;
    config.showNotificationBanner = YES;
    
    [[Hotline sharedInstance] initWithConfig:config];
    [self.window makeKeyAndVisible];
    if ([[Hotline sharedInstance]isHotlineNotification:launchOptions]) {
        [[Hotline sharedInstance]handleRemoteNotification:launchOptions
                                              andAppstate:application.applicationState];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void) application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)info{
    if ([[Hotline sharedInstance]isHotlineNotification:info]) {
        [[Hotline sharedInstance]handleRemoteNotification:info andAppstate:app.applicationState];
    }
}

#pragma - Core Data Stack

@synthesize mom = _mom;
@synthesize moc = _moc;
@synthesize psc = _psc;

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSManagedObjectModel *) mom {
    
    if(_mom != nil) {
        return _mom;
    }
    NSURL *modelUrl = [[NSBundle mainBundle]URLForResource:@"Model" withExtension:@"momd"];
    _mom  = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelUrl];
    return _mom;
}

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
