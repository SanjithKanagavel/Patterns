//
//  FavouriteMO.h
//  SearchDictionary
//
//  Created by Sanjith J K on 13/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface FavouriteMO : NSManagedObject
    @property (nonatomic, strong) NSString *searchStr;
    @property (nonatomic, strong) NSString *searchValue;
    @property (nonatomic, strong) NSDate *updateTime;
@end
