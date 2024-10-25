

import UIKit
import RealmSwift
import Chameleon

class CategoryViewContoller: SwipeTableViewController {
    
    
    let realm = try! Realm()
    var categoryArray : Results<CategoryData>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        loadCategories()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navBar = navigationController?.navigationBar {
            navigationItem.title = "Todoey"
            navBar.backgroundColor = .systemBlue
            if let color = UIColor(contrastingBlackOrWhiteColorOn: .systemBlue, isFlat: true) {
                navBar.largeTitleTextAttributes = [.foregroundColor: color]
                navBar.tintColor = color
            }
            
        }
        
    }
    
    
    //MARK: TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].color)

        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added"
        cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: UIColor(hexString: categoryArray?[indexPath.row].color), isFlat: true)
        
        return cell
    }
    
    //MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
        
        
    }
    
    
    //MARK: Data Manipulation
    func save(category: CategoryData) {
        do {
            try realm.write{
                
                realm.add(category)
            }
        } catch {
            print("Error Saving Data: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categoryArray = realm.objects(CategoryData.self)
        
        tableView.reloadData()
        
    }
    
    //MARK: Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        do {
            try self.realm.write {
                if let category = self.categoryArray?[indexPath.row] {
                    self.realm.delete(category)
                }
                
            }
        } catch {
            print("Error deleting category: \(error)")
        }
        
    }
    
    //MARK: Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            // Checking if user typed something
            if textField.text != "" {
                let newCategory = CategoryData()
                newCategory.name = textField.text!
                newCategory.color = UIColor.randomFlat().hexValue()
                // Asking Realm to save new datas
                self.save(category: newCategory)
                
                
            } else {
                // If not typed anything , alert them to type
                let alert = UIAlertController(title: "Error", message: "Please enter an Category", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
}

