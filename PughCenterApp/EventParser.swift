//
//  EventParser.swift
//  NSXMLTest
//
//  Created by Iavor Dekov on 3/2/16.
//  Copyright © 2016 Iavor Dekov. All rights reserved.
//

import Foundation

class EventParser: NSObject, NSXMLParserDelegate {
    
//    let url = NSURL(string: "https://www.colby.edu/pugh/events-feed/")!
    let url = NSBundle.mainBundle().URLForResource("TestData", withExtension: "xml")!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var events = [Event]()
    
    var newLinkDictionary = [String: [String: String]]()
    var oldLinkDictionary = [String: [String: String]]()
    
    // Parsing variables
    let validElements = ["title", "description", "ev:startdate", "link"]
    var currentValue: String?
    var eventTitle: String?
    var eventDescription: String?
    var eventDate: NSDate?
    var eventLink: String?
    
    func beginParsing() {

        if let dictionary = defaults.objectForKey("linkDictionary") as? [String: [String: String]] {
            oldLinkDictionary = dictionary
        }
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
            guard error == nil else {
                print(error)
                return
            }
            
            guard let data = data else {
                print("Data not received")
                return
            }
            
            let parser = NSXMLParser(data: data)
            parser.delegate = self
            parser.parse()
            
            NSNotificationCenter.defaultCenter().postNotificationName("reloadData", object: self)
        }
        task.resume()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if validElements.contains(elementName) {
            currentValue = String()
        }
    }
    
    // found characters
    // if this is an element we care about, append those characters.
    // if currentValue is still nil, then do nothing.
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        currentValue? += string
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
            case "title":
                eventTitle = currentValue
            case "description":
                eventDescription = currentValue
            case "ev:startdate":
                eventDate = DateFormatters.inDateFormatter.dateFromString(currentValue!)!
            case "link":
                eventLink = currentValue
            case "item":
                
                // Trim description string (remove whitespace from beginning and end)
                eventDescription = eventDescription!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                // Set the buttonTitle
                let buttonTitle = getButtonTitleFromOldDictionary(eventLink!)
                // Set the parseObjectID
                let parseObjectID = getObjectIDFromOldDictionary(eventLink!)
                
                // Add the event to the array of Event objects
                events += [Event(title: eventTitle!, description: eventDescription!, startDate: eventDate!, link: eventLink!, buttonStatus: buttonTitle, parseObjectID: parseObjectID)]
                
                let newData = ["buttonTitle": buttonTitle, "parseObjectID": parseObjectID]
                
                // Add button title and Parse object ID to the new dictionary
                newLinkDictionary.updateValue(newData, forKey: eventLink!)
            
            default: break
        }
        currentValue = nil
    }
    
    // Persist new dictionary once parsing has finished
    func parserDidEndDocument(parser: NSXMLParser) {
        defaults.setObject(newLinkDictionary, forKey: "linkDictionary")
    }
    
    // Obtain the button title from persistent dictionary; return default state otherwise
    func getButtonTitleFromOldDictionary(eventLink: String) -> String {
        if let buttonTitle = oldLinkDictionary[eventLink]?["buttonTitle"] {
            return buttonTitle
        }
        return "RSVP"
    }
    
    // Obtain the Parse object ID from persistent dictionary; return nil otherwise
    func getObjectIDFromOldDictionary(eventLink: String) -> String {
        if let parseObjectID = oldLinkDictionary[eventLink]?["parseObjectID"] {
            return parseObjectID
        }
        return ""
    }
    
}