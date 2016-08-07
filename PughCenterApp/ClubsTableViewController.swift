//
//  ClubsTableViewController.swift
//  PughCenterApp
//
//  Created by Iavor Dekov on 2/15/16.
//  Copyright © 2016 Iavor Dekov. All rights reserved.
//

import UIKit

// MARK: - ClubsTableViewController
class ClubsTableViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    var activityIndicator: UIActivityIndicatorView!
    var clubs = [Club]()
    let url = NSURL(string: "https://www.colby.edu/pugh/wp-json/colby-rest/v0/acf-options?clubs=1")!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 46.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        if revealViewController() != nil {
            revealViewController().rearViewRevealWidth = screenWidth / 2
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Loading indicator is displayed before event data has loaded
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.center = CGPointMake(view.center.x, view.center.y - 50)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // request club info from WordPress API
        loadClubs()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showClubDetails" {
            
            let indexPath = tableView.indexPathForSelectedRow!
            
            let detailsController = segue.destinationViewController as! ClubDetailViewController
            
            detailsController.club = clubs[indexPath.row]
        }
    }
    
    // MARK: - Wordpress JSON Parsing Methods
    
    func loadClubs() {
        
        // create request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url)
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // if an error occurs, print it
            func displayError(error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            // get list of club dictionaries form the parsed results
            guard let clubsList = parsedResult["clubs"] as? [[String: AnyObject]] else {
                print("clubList was not succesfully parsed")
                return
            }
            
            // create each club object and fill in details
            for club in clubsList {
                let name = club["title"] as! String
                let description = club["description"] as! String
                let url = club["url"] as! String
                var imageURL = ""
                if let url = club["image"] as? String {
                    imageURL = url
                }
                self.clubs.append(Club(name: name, description: description, url: url, imageURL: imageURL))
            }
            
            // update the table view
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                self.tableView.reloadData()
            }
        }
        
        // start the task!
        task.resume()
    }
}

// MARK: - ClubsTableViewController DataSource Methods
extension ClubsTableViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ClubCell")!
        
        cell.textLabel!.text = clubs[indexPath.row].name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showClubDetails", sender: self)
    }
}
