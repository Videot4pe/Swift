//
//  GameScene.swift
//  shot
//
//  Created by Garanya Kvasnikov on 24.08.17.
//  Copyright © 2017 l0tus. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Train     : UInt32 = 0b10
    
    static let Bullet1   : UInt32 = 0b100
    static let Bullet2   : UInt32 = 0b10000

    static let Player1   : UInt32 = 0b1
    static let Player2   : UInt32 = 0b1000
    
    static let Check     : UInt32 = 0b100000
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

struct player {
    let score = SKLabelNode(fontNamed: "score")
    var kills = 0
    var revolver = false
    let image = SKSpriteNode(imageNamed: "player")
}
extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    let moveAnalogStick1 = 🕹(diameter: 110, colors: (UIColor.blue, UIColor.green))
    let moveAnalogStick2 = 🕹(diameter: 110, colors: (UIColor.blue, UIColor.green))

    //let player1 = SKSpriteNode(imageNamed: "player")
    //let player2 = SKSpriteNode(imageNamed: "player")
    
    var player1 = player()
    var player2 = player()
    
    var background = SKSpriteNode(imageNamed: "background")
    
    func addTrain() {
        
        let train = SKSpriteNode(imageNamed: "train1")
        
        train.physicsBody = SKPhysicsBody(rectangleOf: train.size)
        train.physicsBody?.isDynamic = true
        train.physicsBody?.categoryBitMask = PhysicsCategory.Train
        train.physicsBody?.contactTestBitMask = PhysicsCategory.Player1 | PhysicsCategory.Bullet1 | PhysicsCategory.Player2 | PhysicsCategory.Bullet2
        train.physicsBody?.collisionBitMask = PhysicsCategory.None
        train.physicsBody?.usesPreciseCollisionDetection = true
        

        train.position = CGPoint(x: size.width/7, y: -80)
        train.zRotation = -0.72
        addChild(train)
        
        let actualDuration = 3
        
        let actionMove = SKAction.move(to: CGPoint(x: size.width*6/7, y: size.height+80), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        train.run(SKAction.sequence([actionMove, actionMoveDone]))
    }

    func playerDidCollideWithTrain(player: SKSpriteNode, train: SKSpriteNode) {
        player.removeAllActions()
    }
    
    func trainDidCollideWithBullet(train: SKSpriteNode, bullet: SKSpriteNode) {
        bullet.removeAllActions()
        bullet.removeFromParent()
    }
    
    func bulletDidCollideWithPlayer(bullet: SKSpriteNode, player: SKSpriteNode) {
        bullet.removeFromParent()
        player.removeFromParent()
    }
    
    func score() {
        player1.score.text = String(player1.kills)
        player2.score.text = String(player2.kills)
        if (player1.kills == 5 || player2.kills == 5)
        {
            gameOver()
        }
    }
    
    func gameOver()
    {
        self.removeAllActions()
        self.removeAllChildren()
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
        
        self.view?.addSubview(newDuo)
        self.view?.addSubview(newSingle)
    }
    
    func duoPlayer(sender: UIButton!) {
        while let viewWithTag = self.view?.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        let scene = GameScene(size: (view?.bounds.size)!)
        let skView = view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        //skView.showsPhysics = true
    }
    
    func singlePlayer(sender: UIButton!) {
        while let viewWithTag = self.view?.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        let scene = GameSceneSinglePlayer(size: (view?.bounds.size)!)
        let skView = view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        //skView.showsPhysics = true
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //bulelt1 vs train
        if ((firstBody.categoryBitMask & PhysicsCategory.Train != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bullet1 != 0)) {
            if let train = firstBody.node as? SKSpriteNode, let
                bullet = secondBody.node as? SKSpriteNode {
                trainDidCollideWithBullet(train: train, bullet: bullet)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Bullet1 != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Train != 0)) {
            if let bullet = firstBody.node as? SKSpriteNode, let
                train = secondBody.node as? SKSpriteNode {
                trainDidCollideWithBullet(train: train, bullet: bullet)
            }
        }
        //bulelt1 vs train
        
        //bulelt2 vs train
        if ((firstBody.categoryBitMask & PhysicsCategory.Train != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bullet2 != 0)) {
            if let train = firstBody.node as? SKSpriteNode, let
                bullet = secondBody.node as? SKSpriteNode {
                trainDidCollideWithBullet(train: train, bullet: bullet)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Bullet2 != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Train != 0)) {
            if let bullet = firstBody.node as? SKSpriteNode, let
                train = secondBody.node as? SKSpriteNode {
                trainDidCollideWithBullet(train: train, bullet: bullet)
            }
        }
        //bulelt2 vs train
        
        //bulelt1 vs player2
        if ((firstBody.categoryBitMask & PhysicsCategory.Bullet1 != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player2 != 0)) {
            if let bullet = firstBody.node as? SKSpriteNode, let
                player = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithPlayer(bullet: bullet, player: player)
                player1.kills += 1
                score()
                createPlayer2()
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Player2 != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bullet1 != 0)) {
            if let player = firstBody.node as? SKSpriteNode, let
                bullet = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithPlayer(bullet: bullet, player: player)
                player2.kills += 1
                score()
                createPlayer2()
            }
        }
        //bulelt1 vs player2
        
        //bulelt2 vs player1
        if ((firstBody.categoryBitMask & PhysicsCategory.Bullet2 != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player1 != 0)) {
            if let bullet = firstBody.node as? SKSpriteNode, let
                player = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithPlayer(bullet: bullet, player: player)
                player2.kills += 1
                score()
                createPlayer1()
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Player1 != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bullet2 != 0)) {
            if let player = firstBody.node as? SKSpriteNode, let
                bullet = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithPlayer(bullet: bullet, player: player)
                player2.kills += 1
                score()
                createPlayer1()
            }
        }
        //bulelt2 vs player1
        
        //player1 vs train
        if ((firstBody.categoryBitMask & PhysicsCategory.Train != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player1 != 0)) {
            if let train = firstBody.node as? SKSpriteNode, let
                player = secondBody.node as? SKSpriteNode {
                playerDidCollideWithTrain(player: player, train: train)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Player1 != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Train != 0)) {
            if let player = firstBody.node as? SKSpriteNode, let
                train = secondBody.node as? SKSpriteNode {
                playerDidCollideWithTrain(player: player, train: train)
            }
        }
        //player1 vs train
        
        //player2 vs train
        if ((firstBody.categoryBitMask & PhysicsCategory.Train != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player2 != 0)) {
            if let train = firstBody.node as? SKSpriteNode, let
                player = secondBody.node as? SKSpriteNode {
                playerDidCollideWithTrain(player: player, train: train)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Player2 != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Train != 0)) {
            if let player = firstBody.node as? SKSpriteNode, let
                train = secondBody.node as? SKSpriteNode {
                playerDidCollideWithTrain(player: player, train: train)
            }
        }
        //player2 vs train
    }
    
    func addBullet1(owner: SKSpriteNode, velocity: CGPoint) {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        
        bullet.position = owner.position
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet1
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Player2 | PhysicsCategory.Train
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true

        addChild(bullet)

        let actionMove = SKAction.move(to: CGPoint(x: owner.position.x + 30*velocity.x, y: owner.position.y + 30*velocity.y), duration: TimeInterval(0.4))
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addBullet2(owner: SKSpriteNode, velocity: CGPoint) {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        
        bullet.position = owner.position
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet2
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Player1 | PhysicsCategory.Train
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(bullet)
        
        let actionMove = SKAction.move(to: CGPoint(x: owner.position.x + 30*velocity.x, y: owner.position.y + 30*velocity.y), duration: TimeInterval(0.4))
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
    }


    override func didMove(to view: SKView) {
        
        player1.score.text = String(player1.kills)
        player1.score.fontSize = 65
        player1.score.fontColor = SKColor.green
        player1.score.position = CGPoint(x: 40, y: 20)

        player2.score.text = String(player2.kills)
        player2.score.fontSize = 65
        player2.score.fontColor = SKColor.green
        player2.score.position = CGPoint(x: size.width - 40, y: size.height - 60)
        addChild(player1.score)
        addChild(player2.score)
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        moveAnalogStick1.position = CGPoint(x: 60, y: size.height-60)
        addChild(moveAnalogStick1)
        moveAnalogStick2.position = CGPoint(x: size.width-60, y: 60)
        addChild(moveAnalogStick2)

        moveAnalogStick1.trackingHandler = { [unowned self] data in
            //self.player1.position = CGPoint(x: self.player1.position.x + (data.velocity.x * 0.12), y: self.player1.position.y + (data.velocity.y * 0.12))
            if (self.player1.revolver){
                if (abs(data.velocity.x) + abs(data.velocity.y) > 55) {
                    self.player1.revolver = !self.player1.revolver
                    self.addBullet1(owner: self.player1.image, velocity: data.velocity)
                }
            }
        }
        moveAnalogStick1.stopHandler = { [unowned self] in
            self.player1.revolver = !self.player1.revolver
        }
        
        
        moveAnalogStick2.trackingHandler = { [unowned self] data in
            //self.player2.position = CGPoint(x: self.player1.position.x + (data.velocity.x * 0.12), y: self.player1.position.y + (data.velocity.y * 0.12))
            if (self.player2.revolver){
                if (abs(data.velocity.x) + abs(data.velocity.y) > 55) {
                    self.player2.revolver = !self.player2.revolver
                    self.addBullet2(owner: self.player2.image, velocity: data.velocity)
                }
            }
        }
        moveAnalogStick2.stopHandler = { [unowned self] in
            self.player2.revolver = !self.player2.revolver
        }
        

        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        createPlayer1()
        createPlayer2()

        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        background.zPosition = -1
        addChild(background)
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addTrain),
                SKAction.wait(forDuration: 1.3)
                ])
        ))

    }
    
    func createPlayer1() {
        player1.image.physicsBody = SKPhysicsBody(circleOfRadius: 24)
        player1.image.physicsBody?.isDynamic = true
        player1.image.physicsBody?.categoryBitMask = PhysicsCategory.Player1
        player1.image.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet2 | PhysicsCategory.Train
        player1.image.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        player1.image.position = CGPoint(x: size.width * 0.25, y: size.height * 0.75)
        addChild(player1.image)
    }
    
    func createPlayer2() {
        
        player2.image.physicsBody = SKPhysicsBody(circleOfRadius: 24)
        player2.image.physicsBody?.isDynamic = true
        player2.image.physicsBody?.categoryBitMask = PhysicsCategory.Player2
        player2.image.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet1 | PhysicsCategory.Train
        player2.image.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        player2.image.position = CGPoint(x: size.width * 0.75, y: size.height * 0.25)
        addChild(player2.image)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        if (touchLocation.x < size.width/5 - 25) {
            player1.image.removeAllActions()
            
            let distance = (sqrt(pow(Float(touchLocation.x - player1.image.position.x), 2) + pow(Float(touchLocation.y - player1.image.position.y), 2)))/230
            //print(distance)
        
            let actionMove = SKAction.move(to: touchLocation, duration: TimeInterval(distance))
            player1.image.run(SKAction.sequence([actionMove]))
        }
        if (touchLocation.x > size.width*4/5 - 25) {
            player2.image.removeAllActions()
            
            let distance = (sqrt(pow(Float(touchLocation.x - player2.image.position.x), 2) + pow(Float(touchLocation.y - player2.image.position.y), 2)))/230
            //print(distance)
            
            let actionMove = SKAction.move(to: touchLocation, duration: TimeInterval(distance))
            player2.image.run(SKAction.sequence([actionMove]))
        }
        if (touchLocation.x - size.width*1/7 > 0 && touchLocation.x-size.width*6/7 < 0) {
            if (touchLocation.y > (touchLocation.x - size.width*1/7)*0.954 + 15) {
                player1.image.removeAllActions()
                
                let distance = (sqrt(pow(Float(touchLocation.x - player1.image.position.x), 2) + pow(Float(touchLocation.y - player1.image.position.y), 2)))/230
                //print(distance)
                
                let actionMove = SKAction.move(to: touchLocation, duration: TimeInterval(distance))
                player1.image.run(SKAction.sequence([actionMove]))
            }
            else if (touchLocation.y < ((touchLocation.x - size.width*1/7)*0.954 - 75)) {
                player2.image.removeAllActions()
                
                let distance = (sqrt(pow(Float(touchLocation.x - player2.image.position.x), 2) + pow(Float(touchLocation.y - player2.image.position.y), 2)))/230
                //print(distance)
                
                let actionMove = SKAction.move(to: touchLocation, duration: TimeInterval(distance))
                player2.image.run(SKAction.sequence([actionMove]))
            }
            
        }
        
    }

}
