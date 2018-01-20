// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Location.swift instead.

import CoreData

// MARK: - Class methods
extension Location {

    public class var entityName: String {
        return "Location"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: entityName)
    }

}

public extension Location {

	public struct Attributes {
		static let displayOrderNumber = "displayOrderNumber"
		static let latitude = "latitude"
		static let locationID = "locationID"
		static let longitude = "longitude"
		static let name = "name"
		static let selected = "selected"
	}

    // MARK: - Properties

    @NSManaged public var displayOrderNumber: Int64

    @NSManaged public var latitude: NSNumber?

    @NSManaged public var locationID: Int64

    @NSManaged public var longitude: NSNumber?

    @NSManaged public var name: String!

    @NSManaged public var selected: Bool

    // MARK: - Relationships

}
