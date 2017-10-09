//
//  MenuController.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    @IBOutlet var objectMenu: UITableView!
    @IBOutlet var gadgetMenu: UITableView!
    var currentlySelected = NSIndexPath()
    var shapes = ["circle.png", "square.png", "triangle.png", "crate.png", "baseball.png", "brickwall.png", "airplane.png", "bike.png", "car.png"]
    var gadgets = ["rope.png", "spring.png", "rod.png", "ramp.png", "platform.png", "vertical_line.png", "circle_gadget.png", "pulley.png"]
    struct gadgetIndex {
        let blank = 0
        let rope = 1
        let spring = 2
        let rod = 3
        let ramp = 4
        let platform = 5
        let wall = 6
        let round = 7
        let pulley = 8
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if (objectMenu != nil) {
        self.objectMenu!.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        if (gadgetMenu != nil) {
        self.gadgetMenu!.separatorStyle = UITableViewCellSeparatorStyle.None
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        
        // Size of the shapes table
         if (objectMenu != nil) {
        if tableView == self.objectMenu {
            
            count = self.shapes.count
        }
        }
        // Size of the gadgets table
        if (gadgetMenu != nil) {
        if tableView == self.gadgetMenu {
            count = self.gadgets.count
        }
        }
        return count!
    }
    
    // Sets the contents of the two table views
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if (gadgetMenu != nil) {
        // Contents of the gadgets Table
        if tableView == self.gadgetMenu {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            //cell.textLabel?.text = shapes[indexPath.row]
            cell!.imageView!.image = UIImage(named: gadgets[indexPath.row] )
            cell!.backgroundColor = UIColor.clearColor()
        }
        }
        
        // Contents of the shapes table
        if (objectMenu != nil) {
        if tableView == self.objectMenu {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            //cell.textLabel?.text = shapes[indexPath.row]
            cell!.imageView!.image = UIImage(named: shapes[indexPath.row])
            cell!.backgroundColor = UIColor.clearColor()
        }
        }
        return cell!
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == currentlySelected {
            currentlySelected = NSIndexPath()
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
                self.performSegueWithIdentifier("toHomeView", sender: self)
        }
        else {
        currentlySelected = indexPath
        self.performSegueWithIdentifier("toHomeView", sender: self)
        }
    }
    
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toHomeView" {
            // Set the GameViewController as a global variable.
            // This will later be used to unify the game scene.
            let destinationViewController = segue.destinationViewController as!ContainerViewController;
            if (objectMenu != nil) {
                if objectMenu.indexPathForSelectedRow != nil {
        destinationViewController.setObjectFlag((objectMenu.indexPathForSelectedRow?.row)!)
            }
                else {
                    destinationViewController.setObjectFlag(9)
                }
            }
            if (gadgetMenu != nil) {
              if gadgetMenu.indexPathForSelectedRow != nil {
        destinationViewController.setGadgetFlag((gadgetMenu.indexPathForSelectedRow?.row)!)
            }
              else{
                destinationViewController.setGadgetFlag(9)
                }
            }
            destinationViewController.TableVC = self
            // setup the destination controller
        }
    }
}