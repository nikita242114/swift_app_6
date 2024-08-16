// Блок 1.

import UIKit

class TableViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    var data: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedData = defaults.array(forKey: "savedData") as? [String] {
            data = savedData
        }
        
        tableView.reloadData()
        
        fetchData()
    }
    
    func fetchData() {
        let newData = ["New Data 1", "New Data 2", "New Data 3"]
        data = newData
        
        defaults.set(data, forKey: "savedData")
        
        tableView.reloadData()
    }
}

// Блок 2.

class ThemeSelectionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose Theme"
        
        let colors: [UIColor] = [.white, .cyan, .green]
        
        var yPosition: CGFloat = 100
        let buttonHeight: CGFloat = 50
        
        for (index, color) in colors.enumerated() {
            let colorButton = UIButton(type: .system)
            colorButton.setTitle("Theme \(index + 1)", for: .normal)
            colorButton.frame = CGRect(x: 20, y: yPosition, width: view.frame.width - 40, height: buttonHeight)
            colorButton.backgroundColor = color
            colorButton.tag = index
            colorButton.addTarget(self, action: #selector(themeButtonTapped(_:)), for: .touchUpInside)
            view.addSubview(colorButton)
            
            yPosition += buttonHeight + 20
        }
    }
    
    @objc func themeButtonTapped(_ sender: UIButton) {
        let selectedTheme = sender.tag
        UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        
        let application = UIApplication.shared
        for window in application.windows {
            for view in window.subviews {
                view.backgroundColor = sender.backgroundColor
            }
        }
    }
}

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Main Screen"
        
        let themeButton = UIButton(type: .system)
        themeButton.setTitle("Choose Theme", for: .normal)
        themeButton.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 50)
        themeButton.addTarget(self, action: #selector(chooseThemeButtonTapped), for: .touchUpInside)
        view.addSubview(themeButton)
    }
    
    @objc func chooseThemeButtonTapped() {
        let themeSelectionVC = ThemeSelectionViewController()
        navigationController?.pushViewController(themeSelectionVC, animated: true)
    }
}

// Д.З.

import Foundation
import CoreData
import CoreData
import SwiftUI

class Friend: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var age: Int
    @NSManaged var address: String
    @NSManaged var phoneNumber: String
    
    static var entityName: String {
        return "Friend"
    }
}

class Group: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var category: String
    @NSManaged var membersCount: Int
    
    static var entityName: String {
        return "Group"
    }
}

### CoreDataManager:

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    func loadFriends() -> [Friend] {
        var friends: [Friend] = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return friends
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Friend>(entityName: Friend.entityName)
        
        do {
            friends = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return friends
    }
    
    func saveFriend(_ friend: Friend) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

### ContentView (для отображения списка друзей и групп):

struct ContentView: View {
    @State private var friends: [Friend] = []
    
    var body: some View {
        List {
            ForEach(friends, id: \.id) { friend in
                NavigationLink(destination: FriendProfileView(friend: friend)) {
                    Text(friend.name)
                }
            }
        }
        .onAppear {
            friends = CoreDataManager.shared.loadFriends()
        }
    }
}

### FriendProfileView (для отображения профиля друга):

struct FriendProfileView: View {
    let friend: Friend
    
    var body: some View {
        VStack {
            Text(friend.name)
                .font(.title)
                .padding()
            
            Text("Age: \(friend.age)")
                .font(.headline)
                .padding()
            
            Text("Address: \(friend.address)")
                .font(.headline)
                .padding()
            
            Text("Phone Number: \(friend.phoneNumber)")
                .font(.headline)
                .padding()
        }
    }
}