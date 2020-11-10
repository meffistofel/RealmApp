//
//  TaskListsViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListViewController: UITableViewController {
    
    var taskLists: Results<TaskList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        
        let taskList = taskLists[indexPath.row]
        cell.configure(with: taskList)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let taskList = taskLists[indexPath.row]
        let tasksVC = segue.destination as! TasksViewController
        tasksVC.currentList = taskList
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.shared.delete(taskList: currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showAlert(with: currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { (_, _, isDone) in
            StorageManager.shared.done(taskList: currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction ,editAction, deleteAction])
    }
    
    @IBAction func  addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
            ? taskLists.sorted(byKeyPath: "name")
            : taskLists.sorted(byKeyPath: "date")
        
        tableView.reloadData()
    }
}

extension TaskListViewController {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        
        let title = taskList != nil ? "Update" : "New List"
        
        let alert = AlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        
        alert.action(with: taskList) { newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList: taskList, newValue: newValue)
                completion()
            } else {
                let taskList = TaskList()
                taskList.name = newValue
                
                StorageManager.shared.save(taskList: taskList)
                let rowIndex = IndexPath(row: self.taskLists.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        
        present(alert, animated: true)
    }
    
}
