//
//  GameScene.swift
//  shot
//
//  Created by Garanya Kvasnikov on 24.08.17.
//  Copyright © 2017 l0tus. All rights reserved.
//

import SpriteKit

class GameSceneSinglePlayer: SKScene, SKPhysicsContactDelegate {
    let moveAnalogStick = 🕹(diameter: 110, colors: (UIColor.blue, UIColor.green))
    
    var checkRevolver = false
    var player1 = player()
    var player2 = player()
    var AIPath: [CGPoint] = [CGPoint(x:  172.499984741211 , y:  261.999969482422 ),
                             CGPoint(x:  329.999969482422 , y:  305.5 ),
                             CGPoint(x:  375.499938964844 , y:  358.999969482422 ),
                             CGPoint(x:  291.999969482422 , y:  360.999969482422 ),
                             CGPoint(x:  154.999969482422 , y:  363.499969482422 ),
                             CGPoint(x:  129.499984741211 , y:  259.999969482422 ),
                             CGPoint(x:  191.499984741211 , y:  294.999969482422 ),
                             CGPoint(x:  71.0 , y:  306.999969482422 ),
                             CGPoint(x:  33.5 , y:  220.999984741211 ),
                             CGPoint(x:  43.5 , y:  80.4999923706055 ),
                             CGPoint(x:  27.5 , y:  15.5 ),
                             CGPoint(x:  88.0 , y:  16.5000152587891 ),
                             CGPoint(x:  203.499984741211 , y:  140.999984741211 ),
                             CGPoint(x:  145.999984741211 , y:  118.0 ),
                             CGPoint(x:  233.499984741211 , y:  232.999984741211 ),
                             CGPoint(x:  299.499969482422 , y:  251.999969482422 ),
                             CGPoint(x:  256.999969482422 , y:  321.499969482422 ),
                             CGPoint(x:  176.999984741211 , y:  255.999969482422 ), 
                             CGPoint(x:  181.999984741211 , y:  318.5 ), 
                             CGPoint(x:  126.999984741211 , y:  199.999984741211 ), 
                             CGPoint(x:  114.5 , y:  286.499969482422 ), 
                             CGPoint(x:  71.0 , y:  223.499969482422 ), 
                             CGPoint(x:  120.499969482422 , y:  342.999969482422 ), 
                             CGPoint(x:  66.0 , y:  313.999969482422 ), 
                             CGPoint(x:  43.0 , y:  137.999969482422 ), 
                             CGPoint(x:  206.999969482422 , y:  352.999969482422 )]
    
    var background = SKSpriteNode(imageNamed: "background")
    
    func addTrain() {
        
        let train = SKSpriteNode(imageNamed: "train1")
        
        train.physicsBody = SKPhysicsBody(rectangleOf: train.size)
        train.physicsBody?.isDynamic = true
        train.physicsBody?.categoryBitMask = PhysicsCategory.Train
        train.physicsBody?.contactTestBitMask = PhysicsCategory.Player1 | PhysicsCategory.Bullet1 | PhysicsCategory.Player2 | PhysicsCategory.Bullet2 | PhysicsCategory.Check
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
    
    var i = 0
    override func update(_ currentTime: CFTimeInterval) {
        if (!(player1.image.hasActions()))
        {
            var number = Int(arc4random_uniform(UInt32(AIPath.count - 1)) + 1)
            let distance = (sqrt(pow(Float(AIPath[number].x - player1.image.position.x), 2) + pow(Float(AIPath[number].y - player1.image.position.y), 2)))/230
            //print(distance)
        
            let actionMove = SKAction.move(to: AIPath[number], duration: TimeInterval(distance))
            player1.image.run(SKAction.sequence([actionMove]))
        }
        i = i + 1
        print(i)
        if (i%5 == 0) {
            checkForBullet()
        }
    }
    
    func trainDidCollideWithBullet(train: SKSpriteNode, bullet: SKSpriteNode) {
        bullet.removeAllActions()
        bullet.removeFromParent()
    }
    
    func trainDidCollideWithCheck(train: SKSpriteNode, check: SKSpriteNode) {
        check.removeFromParent()
        self.checkRevolver = true
    }
    
    func checkDidCollideWithPlayer(check: SKSpriteNode, player: SKSpriteNode) {
        var random = Int(arc4random_uniform(2) + 1)
        if (self.checkRevolver == true && random == 1) {
            //let aiBullet = CGPoint(dictionaryRepresentation: player2.image.position as! CFDictionary)
            addBullet(owner: self.player1.image)
            self.checkRevolver = false
        }
        check.removeFromParent()
    }
    
    func bulletDidCollideWithPlayer(bullet: SKSpriteNode, player: SKSpriteNode) {
        bullet.removeFromParent()
        player.removeFromParent()
    }
    
    func score() {
        player1.score.text = String(player1.kills)
        player2.score.text = String(player2.kills)
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
        
        //check vs train
        if ((firstBody.categoryBitMask & PhysicsCategory.Check != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Train != 0)) {
            if let check = firstBody.node as? SKSpriteNode, let
                train = secondBody.node as? SKSpriteNode {
                trainDidCollideWithCheck(train: train, check: check)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Train != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Check != 0)) {
            if let train = firstBody.node as? SKSpriteNode, let
                check = secondBody.node as? SKSpriteNode {
                trainDidCollideWithCheck(train: train, check: check)
            }
        }
        //check vs train
        
        //player2 vs check
        if ((firstBody.categoryBitMask & PhysicsCategory.Player2 != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Check != 0)) {
            if let player = firstBody.node as? SKSpriteNode, let
                check = secondBody.node as? SKSpriteNode {
                checkDidCollideWithPlayer(check: check, player: player)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Check != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player2 != 0)) {
            if let check = firstBody.node as? SKSpriteNode, let
                player = secondBody.node as? SKSpriteNode {
                checkDidCollideWithPlayer(check: check, player: player)
            }
        }
        //player2 vs check
    }
    
    func addBullet(owner: SKSpriteNode) {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position = owner.position
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet1
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Player2 | PhysicsCategory.Train
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(bullet)
        
        let distanceX = player2.image.position.x - bullet.position.x
        let distanceY = player2.image.position.y - bullet.position.y

        let actionMove = SKAction.move(to: CGPoint(x: bullet.position.x + distanceX*2, y: bullet.position.y + distanceY*2), duration: TimeInterval(0.4))
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addBulletPlayer(owner: SKSpriteNode, velocity: CGPoint) {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        
        bullet.position = owner.position
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet2
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Player1 | PhysicsCategory.Train
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(bullet)
        
        let actionMove = SKAction.move(to: CGPoint(x: owner.position.x + 30*velocity.x, y: owner.position.y + 30*velocity.y), duration: TimeInterval(0.3))
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
    }

    
    func checkForBullet() {
        let check = SKSpriteNode(imageNamed: "checkForBullet")
        check.alpha = 0.0
        check.position = player1.image.position
        check.physicsBody = SKPhysicsBody(rectangleOf: check.size)
        check.physicsBody?.isDynamic = true
        check.physicsBody?.categoryBitMask = PhysicsCategory.Check
        check.physicsBody?.contactTestBitMask = PhysicsCategory.Player2 | PhysicsCategory.Train
        check.physicsBody?.collisionBitMask = PhysicsCategory.None
        check.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(check)
        
        let distanceX = player2.image.position.x - check.position.x
        let distanceY = player2.image.position.y - check.position.y
        
        let actionMove = SKAction.move(to: CGPoint(x: check.position.x + distanceX, y: check.position.y + distanceY), duration: TimeInterval(0.25))
        let actionMoveDone = SKAction.removeFromParent()
        check.run(SKAction.sequence([actionMove, actionMoveDone]))
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

        moveAnalogStick.position = CGPoint(x: size.width-60, y: 60)
        addChild(moveAnalogStick)
        
        moveAnalogStick.trackingHandler = { [unowned self] data in
            //self.player2.position = CGPoint(x: self.player1.position.x + (data.velocity.x * 0.12), y: self.player1.position.y + (data.velocity.y * 0.12))
            if (self.player2.revolver){
                if (abs(data.velocity.x) + abs(data.velocity.y) > 55) {
                    self.player2.revolver = !self.player2.revolver
                    self.addBulletPlayer(owner: self.player2.image, velocity: data.velocity)
                }
            }
        }
        moveAnalogStick.stopHandler = { [unowned self] in
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
        player2.image.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet1 | PhysicsCategory.Train | PhysicsCategory.Check
        player2.image.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        player2.image.position = CGPoint(x: size.width * 0.75, y: size.height * 0.25)
        addChild(player2.image)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)

        if (touchLocation.x > size.width*4/5 - 25) {
            player2.image.removeAllActions()
            
            let distance = (sqrt(pow(Float(touchLocation.x - player2.image.position.x), 2) + pow(Float(touchLocation.y - player2.image.position.y), 2)))/230
            //print(distance)
            
            let actionMove = SKAction.move(to: touchLocation, duration: TimeInterval(distance))
            player2.image.run(SKAction.sequence([actionMove]))
        }
        if (touchLocation.x - size.width*1/7 > 0 && touchLocation.x-size.width*6/7 < 0) {
            if (touchLocation.y < ((touchLocation.x - size.width*1/7)*0.954 - 75)) {
                player2.image.removeAllActions()
                
                let distance = (sqrt(pow(Float(touchLocation.x - player2.image.position.x), 2) + pow(Float(touchLocation.y - player2.image.position.y), 2)))/230
                //print(distance)
                
                let actionMove = SKAction.move(to: touchLocation, duration: TimeInterval(distance))
                player2.image.run(SKAction.sequence([actionMove]))
            }
            
        }

        //print("CGPoint(x: ", touchLocation.x, ", y: ", touchLocation.y, "), ")
    }
    
}
