//
//  Favourite.h
//  SearchDictionary
//
//  Created by Sanjith J K on 13/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Favourite : NSManagedObject
    @property (nonatomic, retain) NSString * searchStr;
    @property (nonatomic, retain) NSString *searchValue;
    @property (nonatomic, retain) NSDate *updateTime;
@end
