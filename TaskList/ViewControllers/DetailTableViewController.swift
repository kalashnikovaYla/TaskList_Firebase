//
//  DetailTableViewController.swift
//  TaskList
//
//  Created by sss on 12.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class DetailTableViewController: UITableViewController {

    private let identifier = "Cell"
    var titleController: String!
    
    var list: List?
    var tasksArray = [Task]()
    var databaseReference: DatabaseReference!
    
    
    
    //MARK: - View controller life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ///Get and show data from FirebaseDatabase
        databaseReference.child("taskArray").observe(.value) { [weak self] snapshot in
            var cloudTask = Array<Task>()
            for task in snapshot.children {
                let task = Task(snapshot: task as! DataSnapshot)
                cloudTask.append(task)
            }
            self?.tasksArray = cloudTask
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingsTableView()
        settingsNavigationItem()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ///Save to FirebaseDatabase the number of uncompleted tasks
        var numberOfElements = 0
        for task in tasksArray {
            if !task.completed {
                numberOfElements += 1
            }
        }
        list?.databaseReference?.updateChildValues(["count": numberOfElements])
        
        ///Delete all observers 
        databaseReference.removeAllObservers()
    }
    
    
    //MARK: - Methods
    
    private func settingsTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.backgroundColor = UIColor(named: "purpleColor")
    }
    
    private func settingsNavigationItem(){
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        let editButton = self.editButtonItem
        navigationItem.rightBarButtonItems = [editButton,addButton]
    }
    
    /// Save data to FirebaseDatabase use UIAlertController
    @objc func addTask() {
        
        let allertController = UIAlertController(title: "Новая задача", message: "Хотите новую задачу?", preferredStyle: .alert)
        allertController.addTextField()
        
        let saveAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
           
            guard let textField = allertController.textFields?.first,
                  let text = textField.text, text != "",
                  let self = self
            else {return}
            
    
            let task = Task(title: text)
            self.tasksArray.append(task)
            
            let ref = self.databaseReference.child("taskArray").child(text)
            ref.setValue(["title": task.title, "completed": task.completed])
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        allertController.addAction(saveAction)
        allertController.addAction(cancelAction)
        present(allertController, animated: true)
    }
    
}


// MARK: - Table view data source and delegate

extension DetailTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        var configurationForCell = cell.defaultContentConfiguration()
        configurationForCell.text = tasksArray[indexPath.row].title
        configurationForCell.textProperties.color = UIColor(named: "purpleColor") ?? UIColor.darkGray
        cell.contentConfiguration = configurationForCell
        cell.backgroundColor = UIColor(named: "pinkColor")
        cell.tintColor = UIColor(named: "purpleColor")

        tasksArray[indexPath.row].completed ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let task = tasksArray[indexPath.row]
            
            /// Remove task from FirebaseDatabase and reload tableView 
            task.databaseReference?.removeValue()
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        let task = tasksArray[indexPath.row]
        let isCompleted = !task.completed
        cell.accessoryType = isCompleted ? .checkmark: .none
        
        ///Update values in FirebaseDatabase if task is completed
        task.databaseReference?.updateChildValues(["completed": isCompleted])
    }

}
