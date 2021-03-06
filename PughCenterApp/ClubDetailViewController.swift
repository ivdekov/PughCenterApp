//
//  ClubDetailViewController.swift
//  PughCenterApp
//
//  Created by Iavor Dekov on 2/15/16.
//  Copyright © 2016 Iavor Dekov. All rights reserved.
//

import UIKit

// MARK: - ClubDetailViewController
class ClubDetailViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var clubName: UILabel!
    @IBOutlet var clubDescription: UILabel!
    @IBOutlet var urlTextView: UITextView!
    @IBOutlet var urlHeightConstaint: NSLayoutConstraint!
    @IBOutlet var imageView: UIImageView!
    
    // MARK: Properties
    var club: Club!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clubName.text = club.name
        clubDescription.text = club.clubDescription
        urlTextView.text = club.url
        loadImage(club.imageURL)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let size = urlTextView.contentSize
        urlHeightConstaint.constant = size.height
    }
    
    // MARK: Helper Methods
    func loadImage(imageURL: String) {
        
        if imageURL != "" {
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED,  0)) {
                
                let url = NSURL(string: imageURL)
                let imageData = NSData(contentsOfURL: url!)
                let image = UIImage (data: imageData!)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.imageView.image = image
                }
            }
        }
    }
}