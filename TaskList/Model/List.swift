//
//  Task.swift
//  TaskList
//
//  Created by sss on 11.01.2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct List {
    let title: String
    let databaseReference: DatabaseReference?
    var count = 0
    
    /// Saving locally
    init(title: String) {
        self.title = title
        self.databaseReference = nil
    }
    
    ///Save to FirebaseDatabase
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue["title"] as! String
        count = snapshotValue["count"] as! Int
        databaseReference = snapshot.ref
    }
}
