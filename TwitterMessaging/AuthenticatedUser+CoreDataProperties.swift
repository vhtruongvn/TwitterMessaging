//
//  AuthenticatedUser+CoreDataProperties.swift
//  TwitterMessaging
//
//  Created by Truong Vo on 1/21/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import Foundation
import CoreData


extension AuthenticatedUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthenticatedUser> {
        return NSFetchRequest<AuthenticatedUser>(entityName: "AuthenticatedUser");
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var screen_name: String?
    @NSManaged public var verified: Bool
    @NSManaged public var profile_image_url: String?
    @NSManaged public var followers: NSSet?

}

// MARK: Generated accessors for followers
extension AuthenticatedUser {

    @objc(addFollowersObject:)
    @NSManaged public func addToFollowers(_ value: Follower)

    @objc(removeFollowersObject:)
    @NSManaged public func removeFromFollowers(_ value: Follower)

    @objc(addFollowers:)
    @NSManaged public func addToFollowers(_ values: NSSet)

    @objc(removeFollowers:)
    @NSManaged public func removeFromFollowers(_ values: NSSet)

}
