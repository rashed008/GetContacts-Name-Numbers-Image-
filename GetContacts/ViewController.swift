//
//  ViewController.swift
//  GetContacts
//
//  Created by Apple iMac on 14/3/23.
//

import UIKit
import Contacts

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchPhoneNumbers: UISearchBar!
    
    var phoneNumbers = [String]()
    var namearray = [String]()
    var logoImages: [UIImage?] = []
    let cache = NSCache<NSString, NSDictionary>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        getDeviceContacts()
        setUpTableView()
    }
    
    private func setUpUI() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        nc.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        print("App moves to background")
    }
    
    @objc func appMovedToForeground() {
        print("App moves to forground")
        getDeviceContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func getDeviceContacts() {
        if let cachedData = cache.object(forKey: "deviceContacts") as? [String: AnyObject],
           let cachedNameArray = cachedData["namearray"] as? [String],
           let cachedPhoneNumbers = cachedData["phoneNumbers"] as? [String],
           let cachedLogoImages = cachedData["logoImages"] as? [UIImage?] {
            var needsUpdate = false
            DispatchQueue.global(qos: .userInitiated).async {
                let contacts = self.fetchContacts()
                var sortedContacts = [Contact]()
                for contact in contacts {
                    let name = "\(contact.givenName) \(contact.familyName)"
                    for number in contact.phoneNumbers {
                        let phoneNumber = number.value.stringValue
                        let imageData = contact.imageData ?? Data()
                        let contact = Contact(name: name, phoneNumber: phoneNumber, imageData: imageData)
                        sortedContacts.append(contact)
                    }
                }
                sortedContacts.sort { $0.name < $1.name }
                let namearray = sortedContacts.map { $0.name }
                let phoneNumbers = sortedContacts.map { $0.phoneNumber }
                let logoImages = sortedContacts.map {
                    let image = UIImage(data: $0.imageData)
                    return image ?? UIImage(named: "User")
                }
                if namearray != cachedNameArray || phoneNumbers != cachedPhoneNumbers || logoImages != cachedLogoImages {
                    self.namearray = namearray
                    self.phoneNumbers = phoneNumbers
                    self.logoImages = logoImages
                    self.cache.setObject([
                        "namearray": namearray as AnyObject,
                        "phoneNumbers": phoneNumbers as AnyObject,
                        "logoImages": logoImages as AnyObject
                    ], forKey: "deviceContacts")
                    needsUpdate = true
                }
                DispatchQueue.main.async {
                    if needsUpdate {
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let contacts = self.fetchContacts()
                var sortedContacts = [Contact]()
                for contact in contacts {
                    let name = "\(contact.givenName) \(contact.familyName)"
                    for number in contact.phoneNumbers {
                        let phoneNumber = number.value.stringValue
                        let imageData = contact.imageData ?? Data()
                        let contact = Contact(name: name, phoneNumber: phoneNumber, imageData: imageData)
                        sortedContacts.append(contact)
                    }
                }
                sortedContacts.sort { $0.name < $1.name }
                self.namearray = sortedContacts.map { $0.name }
                self.phoneNumbers = sortedContacts.map { $0.phoneNumber }
                self.logoImages = sortedContacts.map {
                    let image = UIImage(data: $0.imageData)
                    return image ?? UIImage(named: "User")
                }
                self.cache.setObject([
                    "namearray": self.namearray as AnyObject,
                    "phoneNumbers": self.phoneNumbers as AnyObject,
                    "logoImages": self.logoImages as AnyObject
                ], forKey: "deviceContacts")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func fetchContacts() -> [CNContact] {
        if let cachedContacts = cache.object(forKey: "allContacts") {
            guard let contactsArray = cachedContacts.allValues as? [CNContact] else {
                print("Error converting cached contacts to array of CNContact objects")
                return []
            }
            return contactsArray
        } else {
            var contacts = [CNContact]()
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            let store = CNContactStore()
            
            do {
                try store.enumerateContacts(with: request) { (contact, stop) in
                    contacts.append(contact)
                }
                let contactsDict = NSDictionary(objects: contacts, forKeys: contacts.map({contact in contact.identifier as NSCopying}))
                self.cache.setObject(contactsDict, forKey: "allContacts")
            } catch {
                print("Error fetching contacts: \(error.localizedDescription)")
            }
            return contacts
        }
    }
    
}

extension ViewController {
    
    private func registerCell() {
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    private func setUpTableView() {
        registerCell()
        tableView.dataSource = self
        tableView.delegate = self
    }
}



extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(phoneNumbers.count)
        print(namearray.count)
        return phoneNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        if indexPath.row < namearray.count {
            cell.name.text = namearray[indexPath.row]
        }
        if indexPath.row < phoneNumbers.count {
            cell.phoneNumber.text = phoneNumbers[indexPath.row]
        }
        if indexPath.row < logoImages.count, let image = logoImages[indexPath.row] {
            cell.profileImage.image = image
        }
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(phoneNumbers[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}


extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContacts(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterContacts("")
        searchBar.resignFirstResponder()
    }
    
    private func filterContacts(_ searchText: String) {
        if searchText.isEmpty {
            // If search text is empty, show all contacts
            phoneNumbers = cache.object(forKey: "deviceContacts")?["phoneNumbers"] as? [String] ?? []
            namearray = cache.object(forKey: "deviceContacts")?["namearray"] as? [String] ?? []
            logoImages = cache.object(forKey: "deviceContacts")?["logoImages"] as? [UIImage] ?? []
        } else {
            // Filter contacts based on search text
            let filteredContacts = zip(zip(namearray, phoneNumbers), logoImages)
                .filter { $0.0.0.localizedCaseInsensitiveContains(searchText) || $0.0.1.localizedCaseInsensitiveContains(searchText) }
            namearray = filteredContacts.map { $0.0.0 }
            phoneNumbers = filteredContacts.map { $0.0.1 }
            logoImages = filteredContacts.map { $1 }
        }
        tableView.reloadData()
    }
    
}

