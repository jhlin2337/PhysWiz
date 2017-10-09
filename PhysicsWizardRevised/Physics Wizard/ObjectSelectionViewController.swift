//
//  ObjectSelectionViewController.swift
//  Physics Wizard
//
//  Created by James Lin on 2/4/17.
//  Copyright © 2017 James Lin. All rights reserved.
//

import Foundation

class ObjectSelectionViewController: UITableViewController {
    
    @IBOutlet var objectSelectionMenu: UITableView!
    
    let dynamicObjects = ["circle.png", "square.png", "triangle.png"]
    let staticObjects = ["circle", "rectangle", "triangle"]
    var selectedCell = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (objectSelectionMenu != nil) {
            self.objectSelectionMenu!.separatorStyle = UITableViewCellSeparatorStyle.none
        }
    }
    
    // Sets up the number of cells in the object selection menu
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        // Size of the shapes table
        if (objectSelectionMenu != nil) {
            if tableView == self.objectSelectionMenu {
                count = self.dynamicObjects.count + self.staticObjects.count + 1
            }
        }
        
        return count
    }
    
    // Sets up the contents of the cells in the object selection menu
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        let menuObjectImages = ["circle.png", "square.png", "triangle.png", "blank.png", "orb.png", "platform.png", "ramp.png"]
        
        if (objectSelectionMenu != nil) {
            if tableView == self.objectSelectionMenu {
                cell.imageView!.image = UIImage(named: menuObjectImages[indexPath.row])
                cell.backgroundColor = UIColor.clear
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath != selectedCell {
            selectedCell = indexPath
        } else {
            selectedCell = IndexPath()
            tableView.deselectRow(at: indexPath, animated: false)
        }
        self.performSegue(withIdentifier: "toGameViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameViewController" {
            let destinationViewController = segue.destination as! GameViewController;
            if (objectSelectionMenu != nil) {
                if objectSelectionMenu.indexPathForSelectedRow != nil {
                    let menuObjectNames = ["circle.png", "square.png", "triangle.png", "blank", "circle", "rectangle", "triangle"]
                    let objectIndex = objectSelectionMenu.indexPathForSelectedRow?.row
                    destinationViewController.setSelectedMenuObject(objectName: menuObjectNames[objectIndex!])
                }
            }
        }
    }
}
