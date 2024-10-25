

import UIKit
import Chameleon
import RealmSwift

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems : Results<TodoData>?
    let realm = try! Realm()
    var selectedCategory : CategoryData? {
        didSet {
            loadItems()
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.color {
            navigationItem.title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Bar not found")}
            
            if let navBarColor = UIColor(hexString: colorHex) {
                searchBar.barTintColor = navBarColor
                navBar.backgroundColor = navBarColor
                navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: navBarColor, isFlat: true)
                
                
                navBar.largeTitleTextAttributes = [.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: navBarColor, isFlat: true)!]
            }
        }

    }
    
    
    //MARK: TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.text
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                //self.navigationController?.navigationBar.backgroundColor = UIColor(hexString: selectedCategory?.color)
                cell.backgroundColor = color
                cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: color, isFlat: true)
            }
            
            
            cell.accessoryType = item.checked ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Found"
        }
        
        
        return cell
    }
    
    
    //MARK: TableView Delegate
    //-> check/uncheck datas , Deselecting rows
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.checked = !item.checked
                }
            } catch {
                print("Error saving data: \(error)")
            }
            
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: Add New Items
    //-> Receiving data/defining our context/saving our new data to SQLite using CoreData
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            // Checking if user typed something
            if textField.text != "" {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = TodoData()
                            newItem.text = textField.text!
                            newItem.createdAt = Date()
                            currentCategory.todoDatas.append(newItem)
                        }
                    } catch {
                        print("Error Saving Data: \(error)")
                    }
                    
                    self.tableView.reloadData()
                    
                    
                }
                
                
                
            } else {
                // If not typed anything , alert them to type
                let alert = UIAlertController(title: "Error", message: "Please enter an item", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: Data Manipulation
    
    func loadItems() {
        
        todoItems = selectedCategory?.todoDatas.sorted(by: \.createdAt, ascending: false)
        
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try self.realm.write {
                if let todoData = self.todoItems?[indexPath.row] {
                    self.realm.delete(todoData)
                }
                
            }
        } catch {
            print("Error deleting category: \(error)")
        }
    }
    
    
}

//MARK: Searchbar Delegate

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dispatchQUEUE(with: searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            
            dispatchQUEUE(with: searchBar)
            
//        } else if searchText.count -= 1 {
//            
        } else {
            loadItems()
            todoItems = todoItems?.filter("text CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdAt", ascending: false)
            
            tableView.reloadData()
        }
    }
    
    func dispatchQUEUE(with searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
}





