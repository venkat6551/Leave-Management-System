//
//  Employee.swift
//  LexmarkHub
//
//  Created by Rambabu N on 8/30/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import Foundation

// JSON Keys for Response

let kEmployeeID:String = "empID"
let kFirstName:String = "firstName"
let kLastName:String = "lastName"
let kRole:String = "role"
let kEmail:String = "email"

class Employee: NSObject {
    private (set)var id: NSNumber?
    private (set)var name, role,  email: String?
    
    init(withDictionary dict:NSDictionary){
       
        
        if let firstName = dict[kFirstName] {
            self.name = firstName as? String
        }
        if let empId = dict[kEmployeeID] {
            self.id = NSNumber.init(integer: (empId.integerValue)!)
        }
        if let lastName = dict[kLastName] {
            self.name = (self.name != nil) ? ("\(self.name!) " + (lastName as! String)): (lastName as! String)
        }
        
        if dict[kRole] != nil {
            self.role = dict[kRole] as? String
        }
        if dict[kEmail] != nil {
            self.email = dict[kEmail] as? String
        }
        
        super.init()
    }
}
