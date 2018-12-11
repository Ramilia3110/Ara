//
//  GameScene.swift
//  Ara
//
//  Created by Ramilia Imankulova on 12/1/18.
//  Copyright © 2018 Ramilia Imankulova. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var man : SKSpriteNode?
    var beerTimer : Timer?
    var spiderTimer : Timer?
    var ceil : SKSpriteNode?
    var scoreLbl : SKLabelNode?
    var yourScoreLbl : SKLabelNode?
    var finalScoreLbl : SKLabelNode?

    let manCategory : UInt32 = 0x1 << 1
    let beerCategory : UInt32 = 0x1 << 2
    let spiderCategory : UInt32 = 0x1 << 3
    let floorAndCeilCategory : UInt32 = 0x1 << 4
    var score = 0
    
    override func sceneDidLoad() {
        physicsWorld.contactDelegate = self
        
        man = childNode(withName: "man") as? SKSpriteNode
        man?.physicsBody?.categoryBitMask = manCategory
        man?.physicsBody?.contactTestBitMask = beerCategory | spiderCategory
        man?.physicsBody?.collisionBitMask = floorAndCeilCategory
        var manRun : [SKTexture] = []
        for number in 0...7 {
            manRun.append(SKTexture(imageNamed: "run\(number)"))
        }
        man?.run(SKAction.repeatForever(SKAction.animate(with: manRun, timePerFrame: 0.5)))
        
        ceil = childNode(withName: "ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = floorAndCeilCategory
        ceil?.physicsBody?.collisionBitMask = manCategory
        
        scoreLbl = childNode(withName: "scoreLbl") as? SKLabelNode
        startTimer()
        createFloor()
        
    }
    
    func createFloor() {
        let sizingFloor = SKSpriteNode(imageNamed: "floor")
        let numberbOfFloor = Int(size.width / sizingFloor.size.width) + 1
        for number in 0...numberbOfFloor {
            let floor = SKSpriteNode(imageNamed: "floor")
            floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
            floor.physicsBody?.categoryBitMask = floorAndCeilCategory
            floor.physicsBody?.collisionBitMask = manCategory
            floor.physicsBody?.affectedByGravity = false
            floor.physicsBody?.isDynamic = false
            addChild(floor)
            
            let floorX = -size.width/2 + floor.size.width / 2 +  floor.size.width * CGFloat(number)
            floor.position = CGPoint(x: floorX, y: -size.height/2 + floor.size.height / 2 - 20)
            let speed = 100.0
            let firstMoveLeft = SKAction.moveBy(x: -floor.size.width - floor.size.width * CGFloat(number), y: 0, duration: TimeInterval(floor.size.width + floor.size.width * CGFloat(number)) / speed)
            let resetFloor = SKAction.moveBy(x: size.width + floor.size.width, y: 0, duration: 0)
            let floorFullMove = SKAction.moveBy(x: -size.width - floor.size.width, y: 0, duration: TimeInterval(size.width + floor.size.width) / speed)
            let floorMovingForever = SKAction.repeatForever(SKAction.sequence([floorFullMove, resetFloor]))
            floor.run(SKAction.sequence([firstMoveLeft, resetFloor, floorMovingForever]))
        }
    }
    
    func startTimer(){
        beerTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createBeer()
        })
        
        spiderTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { (timer) in
            self.createSpider()
        })
    }
    
    //MARK Create Beers
    func createBeer(){
        let beer = SKSpriteNode(imageNamed: "beer")
        beer.physicsBody = SKPhysicsBody(rectangleOf: beer.size)
        beer.physicsBody?.affectedByGravity = false
        beer.physicsBody?.categoryBitMask = beerCategory
        beer.physicsBody?.contactTestBitMask = manCategory
        beer.physicsBody?.collisionBitMask = 0
        addChild(beer)
        
        let sizingFloor = SKSpriteNode(imageNamed: "floor")
        
        let maxY = size.height / 2 - beer.size.height / 2
        let minY = -size.height / 2 + beer.size.height / 2 + sizingFloor.size.height
        
        let range = maxY - minY
        let beerY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        beer.position = CGPoint(x: size.width / 2, y: beerY)
        
        
        let moveLeft = SKAction.moveBy(x: -size.width - beer.size.width, y: 0, duration: 4)
        beer.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    //MARK Create Spiders
    func createSpider() {
        let spider = SKSpriteNode(imageNamed: "spider")
        spider.physicsBody = SKPhysicsBody(rectangleOf: spider.size)
        spider.physicsBody?.affectedByGravity = false
        spider.physicsBody?.categoryBitMask = spiderCategory
        spider.physicsBody?.contactTestBitMask = manCategory
        spider.physicsBody?.collisionBitMask = 0
        addChild(spider)
        
        let sizingFloor = SKSpriteNode(imageNamed: "floor")
        
        let maxY = size.height / 2 - spider.size.height / 2
        let minY = -size.height / 2 + spider.size.height / 2 + sizingFloor.size.height
        
        let range = maxY - minY
        let spiderY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        spider.position = CGPoint(x: size.width / 2, y: spiderY)
        
        
        let moveLeft = SKAction.moveBy(x: -size.width - spider.size.width, y: 0, duration: 4)
        spider.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
       
        
        if contact.bodyA.categoryBitMask == beerCategory {
            contact.bodyA.node?.removeFromParent()
            score += 1
            scoreLbl?.text = "Score : \(score)"
            
        }
        
        if contact.bodyB.categoryBitMask == beerCategory {
            contact.bodyB.node?.removeFromParent()
            score += 1
            scoreLbl?.text = "Score : \(score)"
        }
        
        if contact.bodyA.categoryBitMask == spiderCategory{
            gameOver()
        }
        
        if contact.bodyB.categoryBitMask == spiderCategory {
            gameOver()
        }
        
    }
    
    func gameOver() {
        scene?.isPaused = true
        
        beerTimer?.invalidate()
        spiderTimer?.invalidate()
        
        yourScoreLbl = SKLabelNode(text: "Your Score:")
        yourScoreLbl?.position = CGPoint(x: 0, y: 200)
        yourScoreLbl?.fontSize = 100
        yourScoreLbl?.zPosition = 1
        if yourScoreLbl != nil {
            addChild(yourScoreLbl!)
        }
        
        
        finalScoreLbl = SKLabelNode(text: "\(score)")
        finalScoreLbl?.position = CGPoint(x: 0, y: 0)
        finalScoreLbl?.fontSize = 200
        finalScoreLbl?.zPosition = 1
        if finalScoreLbl != nil {
           addChild(finalScoreLbl!)
        }
        
        
        let replayBtn = SKSpriteNode(imageNamed: "replay")
        replayBtn.position = CGPoint(x: 0, y: -200)
        replayBtn.name = "play"
        replayBtn.zPosition = 1
        addChild(replayBtn)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scene?.isPaused == false {
             man?.physicsBody?.applyForce(CGVector(dx: 0, dy: 60000))
        }
      
        
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let theNodes = nodes(at: location)
            
            for node in theNodes {
                if node.name == "play" {
                    score = 0
                    node.removeFromParent()
                    finalScoreLbl?.removeFromParent()
                    yourScoreLbl?.removeFromParent()
                    scene?.isPaused = false
                    scoreLbl?.text = "Score : \(score)"
                    startTimer()
                }
            }
        }
        
    }
    //guy who created beer icon
//    <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
//    
}
