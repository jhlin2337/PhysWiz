//
//  LoadingViewController.swift
//  PhysWiz
//
//  Created by James Lin on 4/29/16.
//  Copyright © 2016 Intuition. All rights reserved.
//

import Foundation

class LoadingViewController: UIViewController {
    
    var GameVC: GameViewController!
    var parentVC: ContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameVC = parentVC.GameVC
        self.definesPresentationContext = true
    }
    
    @IBAction func loadOne(sender: AnyObject) {
        GameVC.currentGame.loadSave(1)
    }
    
    @IBAction func loadTwo(sender: AnyObject) {
        GameVC.currentGame.loadSave(2)
    }
    
    @IBAction func loadThree(sender: AnyObject) {
        GameVC.currentGame.loadSave(3)
    }
}