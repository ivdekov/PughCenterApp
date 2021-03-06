//
//  NotificationsViewController.swift
//  PughCenterApp
//
//  Created by Iavor Dekov on 6/12/16.
//  Copyright © 2016 Iavor Dekov. All rights reserved.
//

import UIKit
import Parse

// MARK: - NotificationsViewController
class NotificationsViewController: UIViewController {
    
    // MARK: Outlets and Variables
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var notificationData: [PFObject]?
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 155.0
        tableView.rowHeight = UITableViewAutomaticDimension

        activityIndicator.startAnimating()
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        if revealViewController() != nil {
            revealViewController().rearViewRevealWidth = screenWidth / 2
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        loadData()
    }
    
    // MARK: Helper Methods
    func loadData() {
        let query = PFQuery(className: "Notification")
        query.orderByDescending("createdAt")
        query.limit = 10
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // Do something with the found objects
                self.notificationData = objects
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
}

// MARK: Table View Data Source Methods
extension NotificationsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = notificationData {
            return data.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell", forIndexPath: indexPath) as! NotificationTableViewCell
        
        if let notification = notificationData?[indexPath.row] {
            let dateAsString = DateFormatters.outDateFormatter.stringFromDate(notification.createdAt!)
            
            cell.titleLabel.text = notification["title"] as? String
            cell.messageTextView.text = notification["message"] as? String
            cell.dateLabel.text = "Sent on \(dateAsString)"

        }

        return cell
    }
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		cell.backgroundColor = .clearColor()
	}
}
