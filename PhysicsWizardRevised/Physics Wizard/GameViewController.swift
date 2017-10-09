//
//  GameViewController.swift
//  Physics Wizard
//
//  Created by James Lin on 1/30/17.
//  Copyright © 2017 James Lin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var objectSelectionButton: UIBarButtonItem!
    @IBOutlet weak var containerVC: UIView!
    
    let REAR_VIEW_CONTROLLER_WIDTH: CGFloat = 84
    
    var selectedMenuObject = "circle.png"
    var scene: GameScene!
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        if self.revealViewController() != nil {
            objectSelectionButton.target = self.revealViewController()
            objectSelectionButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        self.revealViewController().rearViewRevealWidth = REAR_VIEW_CONTROLLER_WIDTH
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func setSelectedMenuObject(objectName: String) {
        selectedMenuObject = objectName
        scene.setSelectedMenuObject(objectName: selectedMenuObject)
    }
    
    func getSelectedMenuObject() -> String {
        return selectedMenuObject
    }
    
    @IBAction func unwindToGameVC(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func showObjectPropertiesVC(_ sender: Any) {
        if containerVC.alpha == 0 {
            containerVC.alpha = 1
        } else {
            containerVC.alpha = 0
        }
    }
}
