//
//  Favourite+CoreDataProperties.swift
//  SearchDictionary
//
//  Created by Sanjith J K on 13/11/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Favourite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favourite> {
        return NSFetchRequest<Favourite>(entityName: "Favourite");
    }

    @NSManaged public var searchStr: String?
    @NSManaged public var searchValue: String?
    @NSManaged public var updateTime: NSDate?

}
