//
//  SavingViewController.swift
//  PhysWiz
//
//  Created by James Lin on 4/29/16.
//  Copyright © 2016 Intuition. All rights reserved.
//

import Foundation

class SavingViewController: UIViewController {
    
    var GameVC: GameViewController!
    var parentVC: ContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameVC = parentVC.GameVC
    }
    
    @IBAction func saveOne(sender: AnyObject) {
        GameVC.currentGame.saveSprites(1)
    }
    
    @IBAction func saveTwo(sender: AnyObject) {
        GameVC.currentGame.saveSprites(2)
    }
    
    @IBAction func saveThree(sender: AnyObject) {
        GameVC.currentGame.saveSprites(3)
    }
}