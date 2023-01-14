//
//  Task.swift
//  TaskList
//
//  Created by sss on 13.01.2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct Task {
    let title: String
    let databaseReference: DatabaseReference?
    var completed = false
    
    /// Saving locally
    init(title: String) {
        self.title = title
        self.databaseReference = nil
    }
    
    ///Save to FirebaseDatabase
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue["title"] as! String
        completed = snapshotValue["completed"] as! Bool 
        databaseReference = snapshot.ref
    }
}
