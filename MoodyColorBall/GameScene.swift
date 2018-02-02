//
//  GameScene.swift
//  MoodyColorBall
//
//  Created by Sai Kasam on 2/1/18.
//  Copyright © 2018 DevHandles. All rights reserved.
//
import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Monster   : UInt32 = 0b1       // 1
        static let Player: UInt32 = 0b10      // 2
    }
    
    // variables
    var shuffledRingArray = ["blueRing","greenRing","redRing","yellowRing"]
    var score = 0
    var touch: UITouch?
    let ringSpeeed = CGFloat(1.8)
    let ringSpeeed2 = CGFloat(1.6)
    var initalRun = false
    
    //game nodes
    let player = SKSpriteNode(imageNamed: "redBall")
    let monster1I = SKSpriteNode(imageNamed:  "blueRing")
    let monster2I = SKSpriteNode(imageNamed:  "greenRing")
    let monster3I = SKSpriteNode(imageNamed:  "redRing")
    let monster4I = SKSpriteNode(imageNamed:  "yellowRing")
    
    //view nodes
    let label = SKLabelNode(fontNamed: "Hiragino Sans W3")
    let touchBar = SKSpriteNode(imageNamed: "bar")
    let titleText = SKSpriteNode(imageNamed: "titleTextImg")
    let directionLbl = SKLabelNode(fontNamed: "Hiragino Sans W3")
    let pointer = SKSpriteNode(imageNamed: "hand")
    let fbIcon = SKSpriteNode(imageNamed: "facebookIcon")
    let starIcon = SKSpriteNode(imageNamed: "starIcon")
    
    override func sceneDidLoad() {
        //physics settings
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        //background color
        backgroundColor = SKColor.black
        
    }
    
    
    override func didMove(to view: SKView) {
        
        //adding player data and physics
        player.userData = ["imageName" : "redBall"]
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.position = CGPoint(x: size.width/2, y: size.height * 0.3)
        addChild(player)
        
        
        //creating score label
        label.text = String(score)
        label.fontSize = 30
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height - label.fontSize - 30)
        
        //creating directions label
        directionLbl.text = "Get the ball into the same colored ring!"
        directionLbl.fontSize = 18
        directionLbl.fontColor = SKColor.white
        directionLbl.position = CGPoint(x: size.width/2, y: size.height * 0.21)
        addChild(directionLbl)
        
        //adding bar
        touchBar.position = CGPoint(x: size.width/2, y: size.height * 0.19)
        addChild(touchBar)
        
        //adding pointer
        pointer.position = CGPoint(x: size.width - ((size.width - touchBar.size.width)/2), y: size.height * 0.17)
        addChild(pointer)
        
        //adding icons
        fbIcon.position = CGPoint(x: (size.width / 3) + 25, y: size.height * 0.10)
        addChild(fbIcon)
        
        starIcon.position = CGPoint(x: (size.width / 3) * 2 - 25, y: size.height * 0.10)
        addChild(starIcon)
        
        //adding titelText
        titleText.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        addChild(titleText)
        
        //editing inital monsters
        let space = ((size.width - 32) - monster1I.size.width * 4)/3
        
        editMonster(monster: monster1I, position: CGPoint(x:    monster1I.size.width/2 + 16 , y: size.height - 2 * monster1I.size.height),name:"blueRing")
        editMonster(monster: monster2I, position: CGPoint(x:  (monster1I.size.width * 3 / 2 + 16 + space)  , y: size.height - 2 * monster1I.size.height),name:"greenRing")
        editMonster(monster: monster3I, position: CGPoint(x:  (monster1I.size.width * 5 / 2 + 16 + space * 2) , y: size.height - 2 * monster1I.size.height),name:"redRing")
        editMonster(monster: monster4I, position: CGPoint(x:   (monster1I.size.width * 7 / 2 + 16 + space * 3), y: size.height - 2 * monster1I.size.height),name:"yellowRing")
        
        let wait = SKAction.wait(forDuration: 3.0)
        
        let repeatPointer = SKAction.repeatForever(
            SKAction.sequence([ SKAction.run(runPointer),wait ])
        )
        
        run(SKAction.sequence([repeatPointer]))
        
    }
    
    func editMonster(monster: SKSpriteNode, position: CGPoint,name:String) {
        monster.userData = ["imageName" : name]
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        monster.position = position
        addChild(monster)
    }
    
    //shuffels Ring Array and returns
    func shuffleArray() -> [String]{
        var ringArray = ["redRing","blueRing","yellowRing","greenRing"]
        var shuffledRingArray = [String]();
        
        for _ in 0..<ringArray.count
        {
            let rand = Int(arc4random_uniform(UInt32(ringArray.count)))
            
            shuffledRingArray.append(ringArray[rand])
            ringArray.remove(at: rand)
        }
        return shuffledRingArray
        
    }
    
    //shuffel and updates RingArray
    func updateShuffleArray(){
        self.shuffledRingArray = shuffleArray()
        print("arr",self.shuffledRingArray)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    //select's the color of the ball
    func setBallProperty() {
        //        self.player.userData = ["imageName" : player.texture.image]
        if let imageName = self.player.userData?["imageName"] as? String {
            print("data",imageName)
        }
    }
    
    //moves pointer left and right on main screen
    func runPointer() {
        
        let actualDuration =  1.5
        let actionMove = SKAction.move(to: CGPoint(x: ((size.width - touchBar.size.width)/2) , y: size.height * 0.17), duration: TimeInterval(actualDuration))
        let actionMove2 = SKAction.move(to: CGPoint(x: size.width - ((size.width - touchBar.size.width)/2) , y: size.height * 0.17), duration: TimeInterval(actualDuration))
        pointer.run(SKAction.sequence([actionMove, actionMove2]))
        
        
    }
    
    //makes block
    
    func block(){
        
        let monster = SKSpriteNode(imageNamed: "block")
        monster.userData = ["imageName" : "block"]

        //physics properties
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5

        var pointsArray = [SKAction]()

        
        let randomNum = arc4random_uniform(_:2)
        
        let intPoints = 1
        
        if randomNum == 1{
            
        let startX = random(min: monster.size.width/2 + 16, max: size.width - monster.size.width/2 - 16)
        monster.position = CGPoint(x: startX , y: size.height + monster.size.height/2)
        let intSpeed = size.height / ringSpeeed
        
        let screenWidth = size.width
        let screenHeight = size.height

        let section = screenHeight / CGFloat(intPoints)
            

        let initialSectionYLength =  screenHeight - ((startX / screenWidth) * section)

        let initialTime =  (screenHeight - initialSectionYLength) / CGFloat(intSpeed)
        let initalAction = SKAction.move(to: CGPoint(x: 16 , y: initialSectionYLength), duration: TimeInterval(initialTime))
        pointsArray.append(initalAction)

        let regualarTime =  (section)  / CGFloat(intSpeed)
        

        var left = false
        var yDist = initialSectionYLength
        for _ in 0 ..< (intPoints ){
            if left == true{

                let action = SKAction.move(to: CGPoint(x: 16 , y:  yDist - section), duration: TimeInterval(regualarTime))
                yDist -= section
                pointsArray.append(action)
                left = false

            } else {
                let action = SKAction.move(to: CGPoint(x: screenWidth - 16 , y:  yDist - section), duration: TimeInterval(regualarTime))

                yDist -= section

                pointsArray.append(action)
                left = true

            }
        }

        let finalTime = (screenHeight - initialSectionYLength) / CGFloat(intSpeed)
        let finalAction = SKAction.move(to: CGPoint(x:  16 , y: yDist), duration: TimeInterval(finalTime))
        pointsArray.append(finalAction)

        // Add the monster to the scene
        addChild(monster)
        let actionMoveDone = SKAction.removeFromParent()
        pointsArray.append(actionMoveDone)

        monster.run(SKAction.sequence(pointsArray))
        } else {

            
            let startX = random(min: monster.size.width/2 + 16, max: size.width - monster.size.width/2 - 16)
            monster.position = CGPoint(x: 16 , y: size.height + monster.size.height/2)
            let intSpeed = size.height / ringSpeeed
            
            let screenWidth = size.width
            let screenHeight = size.height
            
            let section = screenHeight / CGFloat(intPoints)
            
            
            var initialSectionYLength =  screenHeight - ((startX / screenWidth) * section)
            initialSectionYLength = size.height - section
            let initialTime =  (screenHeight - initialSectionYLength) / CGFloat(intSpeed)
            let initalAction = SKAction.move(to: CGPoint(x: screenWidth - 16 , y:initialSectionYLength ), duration: TimeInterval(initialTime))
            pointsArray.append(initalAction)
            
            let regualarTime =  (section)  / CGFloat(intSpeed)
            
            
            var left = true
            var yDist = initialSectionYLength
            for _ in 0 ..< (intPoints ){
                if left == true{
                    
                    let action = SKAction.move(to: CGPoint(x: 16 , y:  yDist - section), duration: TimeInterval(regualarTime))
                    yDist -= section
                    pointsArray.append(action)
                    left = false
                    
                } else {
                    let action = SKAction.move(to: CGPoint(x: screenWidth - 16 , y:  yDist - section), duration: TimeInterval(regualarTime))
                    
                    yDist -= section
                    
                    pointsArray.append(action)
                    left = true
                    
                }
            }
            
//            let finalTime = (screenHeight - initialSectionYLength) / CGFloat(intSpeed)
//            let finalAction = SKAction.move(to: CGPoint(x:  16 , y: yDist), duration: TimeInterval(finalTime))
//            pointsArray.append(finalAction)
            
            // Add the monster to the scene
            addChild(monster)
            let actionMoveDone = SKAction.removeFromParent()
            pointsArray.append(actionMoveDone)
            
            monster.run(SKAction.sequence(pointsArray))
            
        }
    }
    
    //makes ring sprites
    func ring1() {
        
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed:  self.shuffledRingArray[0])
        monster.userData = ["imageName" : self.shuffledRingArray[0]]
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        
        monster.position = CGPoint(x:   monster.size.width/2 + 16 , y: size.height + monster.size.height/2)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration =   ringSpeeed//random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: (monster.size.width/2 + 16) , y: 0), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        }
        
        
    
    
    func ring2() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: self.shuffledRingArray[1])
        monster.userData = ["imageName" : self.shuffledRingArray[1]]
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        
        //        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        let space = ((size.width - 32) - monster.size.width * 4)/3
        monster.position = CGPoint(x: (monster.size.width * 3 / 2 + 16 + space) , y: size.height + monster.size.height/2)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration =   ringSpeeed//random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: (monster.size.width * 3 / 2 + 16 + space), y: 0), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func ring3() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: self.shuffledRingArray[2])
        monster.userData = ["imageName" : self.shuffledRingArray[2]]
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        
        //        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        let space = ((size.width - 32) - monster.size.width * 4)/3
        monster.position = CGPoint(x: (monster.size.width * 5 / 2 + 16 + space * 2) , y: size.height + monster.size.height/2)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration =   ringSpeeed//random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: (monster.size.width * 5 / 2 + 16 + space * 2), y: 0), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func ring4() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: self.shuffledRingArray[3])
        monster.userData = ["imageName" : self.shuffledRingArray[3]]
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        
        //        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        let space = ((size.width - 32) - monster.size.width * 4)/3
        monster.position = CGPoint(x: (monster.size.width * 7 / 2 + 16 + space * 3) , y: size.height + monster.size.height/2)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration =   ringSpeeed//random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: (monster.size.width * 7 / 2 + 16 + space * 3) , y: 0), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    //runs inital row of rings
    func run1(){
        let actualDuration =   ringSpeeed2
        let actionMoveDone = SKAction.removeFromParent()
        let space = ((size.width - 32) - monster1I.size.width * 4)/3
        
        let actionMove = SKAction.move(to: CGPoint(x: (self.monster1I.size.width/2 + 16) , y: 0), duration: TimeInterval(actualDuration))
        self.monster1I.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        let actionMove2 = SKAction.move(to: CGPoint(x: (monster1I.size.width * 3 / 2 + 16 + space) , y: 0), duration: TimeInterval(actualDuration))
        self.monster2I.run(SKAction.sequence([actionMove2, actionMoveDone]))
        
        let actionMove3 = SKAction.move(to: CGPoint(x: (monster1I.size.width * 5 / 2 + 16 + space * 2) , y: 0), duration: TimeInterval(actualDuration))
        self.monster3I.run(SKAction.sequence([actionMove3, actionMoveDone]))
        
        let actionMove4 = SKAction.move(to: CGPoint(x: (monster1I.size.width * 7 / 2 + 16 + space * 3) , y: 0), duration: TimeInterval(actualDuration))
        self.monster4I.run(SKAction.sequence([actionMove4, actionMoveDone]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //logic to only start running once
        if self.initalRun == false{
            
            addChild(label)

            //removing elements
            touchBar.removeFromParent()
            titleText.removeFromParent()
            directionLbl.removeFromParent()
            pointer.removeFromParent()
            starIcon.removeFromParent()
            fbIcon.removeFromParent()
            
            //starting game
            let wait = SKAction.wait(forDuration: 1.1)
            
            let repeatRun = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(setBallProperty),
                    SKAction.run(ring1),
                    SKAction.run(ring2),
                    SKAction.run(ring3),
                    SKAction.run(ring4),
                    SKAction.run(updateShuffleArray),
                    SKAction.wait(forDuration: 1.3)
                    ]))
            
            
            run(SKAction.sequence([SKAction.run(run1),wait,repeatRun]))
            
            //running block
            let repeatBlock = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(block),
                    SKAction.wait(forDuration: 1.3)
                    ]))
            let wait2 = SKAction.wait(forDuration: 0.45)

            run(SKAction.sequence([wait2,repeatBlock]))

            self.initalRun = true
        }
        
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        // 2 - Set up initial location of projectile
        //        let monster = SKSpriteNode(imageNamed: "monster")
        player.position = touchLocation
        player.position = CGPoint(x: touchLocation.x , y: size.height * 0.3)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        //        player.physicsBody?.usesPreciseCollisionDetection = true
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        // 2 - Set up initial location of projectile
        //        let monster = SKSpriteNode(imageNamed: "monster")
        player.position = touchLocation
        player.position = CGPoint(x: touchLocation.x , y: size.height * 0.3)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        //        player.physicsBody?.usesPreciseCollisionDetection = true
        
        
    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        let imageName = monster.userData?["imageName"] as! String
        let playerImageName = self.player.userData?["imageName"] as! String
        
        if imageName.prefix(1) ==  playerImageName.prefix(1){
            self.score += 1
            label.text = String(self.score)
//            monster.removeFromParent()
//            run( SKAction.sequence([SKAction.run({self.addChild(monster)})]))
            
        } else {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
            
        }
        
    }
    
    var collide = true
    func timeOut(){
        self.collide = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
            // Put your code which should be executed with a delay here
            self.collide = true
        })
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let
                player = secondBody.node as? SKSpriteNode {
                
                if self.collide == true{
                    projectileDidCollideWithMonster(projectile: player, monster: monster)
                    timeOut()
                    
                }
            }
        }
        
    }
    
    
}

