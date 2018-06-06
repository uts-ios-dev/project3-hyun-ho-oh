//
//  Memorable.swift
//  Memorable
//
//  Created by Hyun Ho Oh on 4/6/18.
//  Copyright © 2018 University of Technology Sydney. All rights reserved.
//

import Foundation
import os.log

class Memorable: NSObject, NSCoding {
    
    var id: Int
    var head: String
    var body: String
    var category: String
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("memorables")
    
    init(id: Int, head: String, body: String, category: String) {
        self.id = id
        self.head = head
        self.body = body
        self.category = category
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        guard let head = aDecoder.decodeObject(forKey: "head") as? String else {
            os_log("Unable to decode the name for a Memorable object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let body = aDecoder.decodeObject(forKey: "body") as? String else {
            os_log("Unable to decode the body for a Memorable object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let category = aDecoder.decodeObject(forKey: "category") as? String else {
            os_log("Unable to decode the category for a Memorable object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.init(id: id, head: head, body: body, category: category)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(head, forKey: "head")
        aCoder.encode(body, forKey: "body")
        aCoder.encode(category, forKey: "category")
    }
    
}
