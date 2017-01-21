//
//  HomeViewController.swift
//  TwitterMessaging
//
//  Created by Truong Vo on 1/21/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit
import TwitterKit
import PagedArray
import AERecord

let PAGE_SIZE = 20
let PRELOAD_MARGIN = 10

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var loading: UIActivityIndicatorView!
    
    var followersPagedArray: PagedArray<Follower>!
    var cursor = -1
    var firstLoad = true
    var shouldPreload = true
    var dataLoadingOperations = [Int: NSURLRequest]()
    var selectedFollower: Follower?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Welcome!"
        
        // Register to receive 'LoginSuccess' notification
        NotificationCenter.default.addObserver(self, selector: #selector(loginSucceed), name: NSNotification.Name(rawValue: "LoginSuccess"), object: nil)

        // Logout button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped(sender:)))
        
        // Loading indicator
        self.loading = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.loading.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.loading)
        
        // Ask user to login first
        let store = Twitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            print("Old login with userID = \(userID)")
            self.loadUserDetails(userID: userID)
        } else {
            // delay 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showLoginView()
            }
        }
    }
    
    func loginSucceed() {
        let store = Twitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            print("New login with userID = \(userID)")
            self.loadUserDetails(userID: userID)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showChat" {
            let chatViewController = segue.destination as! ChatViewController
            chatViewController.selectedFollower = self.selectedFollower!
        }
    }
    
    // MARK: - Private Methods
    
    private func showLoginView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.present(loginViewController, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    func logoutButtonTapped(sender: AnyObject) {
        let store = Twitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            store.logOutUserID(userID) // logout
            AERecord.truncateAllData() // delete all cached data
            self.followersPagedArray.removeAllPages()
            self.cursor = -1
            self.firstLoad = true
            self.dataLoadingOperations.removeAll(keepingCapacity: true)
            self.tableView.reloadData()
            
            self.showLoginView()
        }
    }
    
    // MARK: - Data & Networking
    
    func loadUserDetails(userID: String) {
        let authenticatedUser = AuthenticatedUser.first(with: ["id": userID])
        if authenticatedUser != nil {
            // Get user details with followers_count
            self.getUserDetails(userID: "\(authenticatedUser!.id)", screenName: authenticatedUser!.screen_name!)
        } else {
            // Request screen_name first
            // then user details with followers_count
            let client = TWTRAPIClient()
            client.loadUser(withID: userID) { (user, error) -> Void in
                if let user = user {
                    print("screenName = @\(user.screenName)")
                    
                    // Cache authenticated user
                    let _ = AuthenticatedUser.firstOrCreate(with: ["id": (user.userID as NSString).intValue,
                                                                   "name" : user.name,
                                                                   "screen_name" : user.screenName,
                                                                   "verified" : user.isVerified,
                                                                   "profile_image_url" : user.profileImageURL])
                    AERecord.saveAndWait()
                    
                    // Get user details with followers_count
                    self.getUserDetails(userID: userID, screenName: user.screenName)
                }
            }
        }
    }
    
    func getUserDetails(userID: String, screenName: String) {
        // Update screen title
        self.title = "Welcome @\(screenName)!"
        
        let userDetailsEndpoint = "https://api.twitter.com/1.1/users/show.json"
        let params = ["user_id": "\(userID)", "screen_name": "\(screenName)", "include_entities": "false"]
        print("--Request params = \(params)")
        var clientError : NSError?
        let client = TWTRAPIClient()
        let request = client.urlRequest(withMethod: "GET", url: userDetailsEndpoint, parameters: params, error: &clientError)
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("ERROR = \(connectionError)")
            }
            
            do {
                let JSON: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                //print("JSON = \(JSON)")
                
                let followers_count = JSON.object(forKey: "followers_count") as! Int
                print("followers_count = \(followers_count)")
                
                // Init followersPagedArray
                self.followersPagedArray = PagedArray<Follower>(count: followers_count, pageSize: PAGE_SIZE)
                self.followersPagedArray.updatesCountWhenSettingPages = true
                
                // Start loading followers data
                self.loadDataForPage(0)
            } catch let jsonError as NSError {
                print("JSON ERROR =  \(jsonError.localizedDescription)")
            }
        }
    }
    
    func loadDataIfNeededForRow(_ row: Int) {
        if self.firstLoad {
            self.loadDataForPage(0)
            return
        }
        
        let currentPage = self.followersPagedArray.page(for: row)
        if self.needsLoadDataForPage(currentPage) {
            self.loadDataForPage(currentPage)
        }
        
        let preloadIndex = row + PRELOAD_MARGIN
        if preloadIndex < self.followersPagedArray.endIndex && shouldPreload {
            let preloadPage = self.followersPagedArray.page(for: preloadIndex)
            if preloadPage > currentPage && self.needsLoadDataForPage(preloadPage) {
                self.loadDataForPage(preloadPage)
            }
        }
    }
    
    func needsLoadDataForPage(_ page: Int) -> Bool {
        return self.followersPagedArray.elements[page] == nil && self.dataLoadingOperations[page] == nil && self.cursor != 0
    }
    
    func loadDataForPage(_ page: Int) {
        let store = Twitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let followersEndpoint = "https://api.twitter.com/1.1/followers/list.json"
            let params = ["cursor": "\(cursor)", "count": "\(PAGE_SIZE)", "skip_status": "true", "include_user_entities": "false"]
            print("--Request params = \(params)")
            var clientError : NSError?
            let request = client.urlRequest(withMethod: "GET", url: followersEndpoint, parameters: params, error: &clientError)
            self.loading.startAnimating()
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                self.loading.stopAnimating()
                
                if connectionError != nil {
                    print("ERROR = \(connectionError)")
                }
                
                if data == nil {
                    print("## Empty response data")
                    return
                }
                
                do {
                    let JSON: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    //print("JSON = \(JSON)")
                    
                    // Set next cursor
                    // Twitter is using cursors to navigate collections
                    let next_cursor = JSON.object(forKey: "next_cursor") as! Int
                    self.cursor = next_cursor
                    print("+ next_cursor = \(next_cursor)")
                    if self.cursor == 0 {
                        print("## Last page!!!")
                    }
                    
                    let previousTotalPageCount = self.followersPagedArray.count // to detect the change of total elements count
                    print("+ before loading new page, followersPagedArray count = \(previousTotalPageCount)")
                    
                    let followersData: [NSDictionary] = JSON.object(forKey: "users") as! [NSDictionary]
                    var pageData: [Follower] = []
                    for follower in followersData {
                        let id = follower.object(forKey: "id") as! Int
                        let name = follower.object(forKey: "name") as! String
                        let screen_name = follower.object(forKey: "screen_name") as! String
                        let verified = follower.object(forKey: "verified") as! Bool
                        let profile_image_url = follower.object(forKey: "profile_image_url") as! String
                        let following = follower.object(forKey: "following") as! Bool
                        let follower = Follower.firstOrCreate(with: ["id": id,
                                                                     "name" : name,
                                                                     "screen_name" : screen_name,
                                                                     "verified" : verified,
                                                                     "profile_image_url" : profile_image_url,
                                                                     "following" : following])
                        AERecord.saveAndWait()
                        pageData.insert(follower, at: 0)
                    }
                    
                    // Alphabetical sorting & set page elements
                    pageData.sort(by: { (this: Follower, that: Follower) -> Bool in
                        this.id < that.id
                    })
                    self.followersPagedArray.set(pageData, forPage: page)
                    
                    let currentTotalPageCount = self.followersPagedArray.count
                    print("+ after loading new page, followersPagedArray count = \(currentTotalPageCount)")
                    
                    // Reload cells
                    if self.firstLoad || previousTotalPageCount != currentTotalPageCount {
                        // for first or last request, # of cells & # of follows may be different -> call reloadData instead
                        self.firstLoad = false
                        self.tableView.reloadData()
                    } else {
                        let indexes = self.followersPagedArray.indexes(for: page)
                        if let indexPathsToReload = self.visibleIndexPathsForIndexes(indexes) {
                            self.tableView.reloadRows(at: indexPathsToReload, with: .automatic)
                        }
                    }
                    
                    // Cleanup
                    self.dataLoadingOperations[page] = nil
                } catch let jsonError as NSError {
                    print("JSON ERROR = \(jsonError.localizedDescription)")
                }
            }
            
            self.dataLoadingOperations[page] = request as NSURLRequest?
        }
    }
    
    private func visibleIndexPathsForIndexes(_ indexes: CountableRange<Int>) -> [IndexPath]? {
        return tableView.indexPathsForVisibleRows?.filter { indexes.contains(($0 as NSIndexPath).row) }
    }

}

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Followers"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.firstLoad ? 0 : self.followersPagedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.loadDataIfNeededForRow((indexPath as NSIndexPath).row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UserCell, atIndexPath indexPath: IndexPath) {
        let follower = self.followersPagedArray[indexPath.row]
        cell.nameLabel?.text = follower == nil ? "Loading" : follower!.name
        cell.screenNameLabel?.text = follower == nil ? "..." : "@\(follower!.screen_name!)"
        if follower != nil {
            ImageLoader.sharedLoader.imageForUrl(urlString: follower!.profile_image_url!, completionHandler: { (image, urlString) in
                cell.profileImageView.image = image
            })
        }
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selectedFollower = self.followersPagedArray[indexPath.row]
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        // See segue for pushViewController action
    }
    
}
