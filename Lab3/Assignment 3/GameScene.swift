//
//  GameScene.swift
//  Assignment 3
//
//  Created by Ranger on 9/26/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

// set value by ViewController.swift
var bonusMode = false

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion)
        }
    }

    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
        }
    }
    
    // MARK: View Hierarchy Functions
    let spinBlock = SKSpriteNode()
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    
    // MARK: Start here
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white

        // start motion for gravity
        self.startMotionUpdates()

        // make Maze for sides and stationary blocks
        self.buildMaze()

        self.addBall()

        self.addScore()

        self.score = 0
    }
    
    // MARK: Create Sprites Functions
    func addScore(){
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY)
        
        addChild(scoreLabel)
    }

    func addBall(){
        let ballRadius: CGFloat = 12
        var ball = SKSpriteNode(imageNamed: "ball")
        if (bonusMode) {
            ball = SKSpriteNode(imageNamed: "gold")
        }
        ball.size = CGSize(width:ballRadius*2 ,height:ballRadius*2)

        let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        ball.position = CGPoint(x: size.width * randNumber, y: size.height * 0.9)

        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.contactTestBitMask = 0x00000001
        ball.physicsBody?.collisionBitMask = 0x00000001
        ball.physicsBody?.categoryBitMask = 0x00000001
        ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))

        self.addChild(ball)
    }

    func buildMaze(){
        // make side and top
        self.addSidesAndTop()

        // make maze
        self.addStaticBlock(x:0.5, y:0.8, w:0.7, h:0.04)
        self.addStaticBlock(x:0.25, y:0.7, w:0.4, h:0.04)
        self.addStaticBlock(x:0.75, y:0.7, w:0.4, h:0.04)
        self.addStaticBlock(x:0.5, y:0.6, w:0.7, h:0.04)
        self.addStaticBlock(x:0.25, y:0.5, w:0.4, h:0.04)
        self.addStaticBlock(x:0.75, y:0.5, w:0.4, h:0.04)
        
        // make wind mill
        self.addWindmill(CGPoint(x: size.width * 0.8, y: size.height * 0.2))
        self.addWindmill(CGPoint(x: size.width * 0.2, y: size.height * 0.2))
        self.addWindmill(CGPoint(x: size.width * 0.5, y: size.height * 0.3))
        
        // add a spinning block
        self.addBlockAtPoint()
    }

    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.1)
        // 30 is for UINavigationItem height
        top.position = CGPoint(x:size.width*0.5, y:size.height - 30)
        
        for obj in [left,right,top]{
            obj.color = UIColor.blue
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    func addStaticBlock(x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat){
        let block = SKSpriteNode()
        block.color = UIColor.blue
        
        block.position = CGPoint(x: size.width * x, y: size.height * y)
        block.size = CGSize(width:size.width * w, height: size.height * h)

        block.physicsBody = SKPhysicsBody(rectangleOf:block.size)
        block.physicsBody?.isDynamic = true
        block.physicsBody?.pinned = true
        block.physicsBody?.allowsRotation = false
        
        self.addChild(block)
    }
    
    func addWindmill(_ point:CGPoint){
        let mill = SKSpriteNode()
        
        mill.color = UIColor.blue
        mill.size = CGSize(width:size.width*0.25,height:size.height * 0.02)
        mill.position = point
        
        mill.physicsBody = SKPhysicsBody(rectangleOf:mill.size)
        mill.physicsBody?.isDynamic = true
        mill.physicsBody?.pinned = true
        mill.physicsBody?.allowsRotation = true
        let randNumber = random(min: CGFloat(-1), max: CGFloat(1))
        mill.physicsBody?.angularVelocity = (randNumber > 0) ? 4 : -4
        mill.physicsBody?.angularDamping = 0

        self.addChild(mill)
    }

    func addBlockAtPoint(){
        spinBlock.color = UIColor.red
        spinBlock.size = CGSize(width:size.width*0.5,height:size.height * 0.03)
        spinBlock.position = CGPoint(x: size.width * 0.5, y: size.height * 0.05)
        
        spinBlock.physicsBody = SKPhysicsBody(rectangleOf:spinBlock.size)
        spinBlock.physicsBody?.contactTestBitMask = 0x00000001
        spinBlock.physicsBody?.collisionBitMask = 0x00000001
        spinBlock.physicsBody?.categoryBitMask = 0x00000001
        spinBlock.physicsBody?.isDynamic = true
        spinBlock.physicsBody?.pinned = true
        spinBlock.physicsBody?.allowsRotation = false
        
        self.addChild(spinBlock)
    }
    
    // MARK: =====Delegate Functions=====
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addBall()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node == spinBlock || contact.bodyB.node == spinBlock) {
            let ball = (contact.bodyA.node == spinBlock) ? contact.bodyB.node : contact.bodyA.node
            self.score += bonusMode ? 3 : 1
            ball?.removeFromParent()
            ball?.physicsBody = nil
            ball?.removeAllActions()
        }
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}

