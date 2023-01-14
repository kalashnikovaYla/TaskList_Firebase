//
//  ListTableViewController.swift
//  TaskList
//
//  Created by sss on 11.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase


class ListTableViewController: UITableViewController {
    
    
    private let identifier = "Cell"
    var user: User!
    var lists = [List]()
    var databaseReference: DatabaseReference!
    
    
    //MARK: - View controller life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ///Get and show data from FirebaseDatabase
        databaseReference.observe(.value) { [weak self] snapshot in
            
            var cloudLists = [List]()
            for list in snapshot.children {
                let list = List(snapshot: list as! DataSnapshot)
                cloudLists.append(list)
            }
            self?.lists = cloudLists
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTableView()
        settingsNavigationItem()
        
        /// Get currentUser uid and make databaseReference
        guard let currenUser = Auth.auth().currentUser else {return}
        user = User(user: currenUser)
        
        databaseReference = Database.database().reference(withPath: "users").child(String(user.uid)).child("list")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ///Delete all observers
        databaseReference.removeAllObservers()
    }
    
    
    //MARK: - Methods
    
    private func settingsTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = UIColor(named: "purpleColor")
    }
    
    private func settingsNavigationItem () {
        title = "Список"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(signOut))
       
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        let editButton = self.editButtonItem
        navigationItem.rightBarButtonItems = [editButton,addButton]
        
    }
    
    /// Save data to FirebaseDatabase use UIAlertController
    
    @objc func addTask() {
        
        let allertController = UIAlertController(title: "Новый список", message: "Хотите новый список?", preferredStyle: .alert)
        allertController.addTextField()
        
        let saveAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            
            guard let textField = allertController.textFields?.first,
                  let text = textField.text, text != ""
            else {return}
            
            let list = List(title: text)
            
            let listRef = self?.databaseReference.child(list.title.lowercased())
            listRef?.setValue(["title": list.title, "count": list.count])
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        allertController.addAction(saveAction)
        allertController.addAction(cancelAction)
        present(allertController, animated: true)
    }
    
    
    /// Sign out and pop to root VC
    @objc func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        navigationController?.popViewController(animated: true)
    }
}



// MARK: - Table view data source and delegate

extension ListTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        var configurationForCell = cell.defaultContentConfiguration()
        
        let currentList = lists[indexPath.row]
        let listTitle = currentList.title

        configurationForCell.text = listTitle
        configurationForCell.textProperties.color = UIColor(named: "purpleColor") ?? UIColor.darkGray
        configurationForCell.textProperties.font  = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        configurationForCell.secondaryText = "Количество невыполненных задач: \(currentList.count)"
        configurationForCell.secondaryTextProperties.color = UIColor(named: "purpleColor") ?? UIColor.darkGray
        configurationForCell.secondaryTextProperties.font = UIFont.systemFont(ofSize: 14)
        cell.backgroundColor = UIColor(named: "pinkColor")
        cell.contentConfiguration = configurationForCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let list = lists[indexPath.row]
            
            /// Remove task from FirebaseDatabase and reload tableView
            list.databaseReference?.removeValue()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentList = lists[indexPath.row]
        let title = currentList.title
        let listRef = databaseReference.child(currentList.title.lowercased())
       
        /// Create and push detail VC
    
        let detailTableViewController = DetailTableViewController()
        detailTableViewController.databaseReference = listRef
        detailTableViewController.title = title
        detailTableViewController.list = currentList
        self.navigationController?.pushViewController(detailTableViewController, animated: true)
    }
    

}
