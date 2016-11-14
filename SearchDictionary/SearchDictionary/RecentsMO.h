//
//  RecentsMO.h
//  SearchDictionary
//
//  Created by Sanjith J K on 14/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface RecentsMO : NSManagedObject
    @property (nullable, nonatomic, copy) NSString *searchStr;
    @property (nullable, nonatomic, copy) NSDate *updateTime;
@end
