//
//  GameViewController.swift
//  shot
//
//  Created by Garanya Kvasnikov on 24.08.17.
//  Copyright © 2017 l0tus. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newDuo = UIButton(frame: CGRect(x: 280, y: 150, width: 100, height: 50))
        newDuo.backgroundColor = .blue
        newDuo.setTitle("Duo", for: .normal)
        newDuo.tag = 100
        newDuo.addTarget(self, action: #selector(duoPlayer), for: .touchUpInside)
        
        let newSingle = UIButton(frame: CGRect(x: 280, y: 210, width: 100, height: 50))
        newSingle.backgroundColor = .blue
        newSingle.setTitle("Single", for: .normal)
        newSingle.tag = 100
        newSingle.addTarget(self, action: #selector(singlePlayer), for: .touchUpInside)
        
        self.view.addSubview(newDuo)
        self.view.addSubview(newSingle)
    }
    
    func duoPlayer(sender: UIButton!) {
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        skView.showsPhysics = true
        
        while let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func singlePlayer(sender: UIButton!) {
        let scene = GameSceneSinglePlayer(size: view.bounds.size)
        let skView = view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        //skView.showsPhysics = true
        
        while let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }

    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
