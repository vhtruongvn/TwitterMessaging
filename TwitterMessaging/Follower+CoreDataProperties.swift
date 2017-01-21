//
//  Follower+CoreDataProperties.swift
//  TwitterMessaging
//
//  Created by Truong Vo on 1/21/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import Foundation
import CoreData


extension Follower {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Follower> {
        return NSFetchRequest<Follower>(entityName: "Follower");
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var screen_name: String?
    @NSManaged public var verified: Bool
    @NSManaged public var profile_image_url: String?
    @NSManaged public var following: Bool
    @NSManaged public var followingUser: AuthenticatedUser?

}
