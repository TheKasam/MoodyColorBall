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
    var continueGame = true
    
    //game nodes
    let player = SKSpriteNode(imageNamed: "redBall")
    let monster1I = SKSpriteNode(imageNamed:  "blueRing")
    let monster2I = SKSpriteNode(imageNamed:  "greenRing")
    let monster3I = SKSpriteNode(imageNamed:  "redRing")
    let monster4I = SKSpriteNode(imageNamed:  "yellowRing")
    
    //view nodes
    let label = SKLabelNode(fontNamed: "Hiragino Sans W3") //score
    let touchBar = SKSpriteNode(imageNamed: "bar")
    let titleText = SKSpriteNode(imageNamed: "titleTextImg")
    let directionLbl = SKLabelNode(fontNamed: "Hiragino Sans W3")
    let pointer = SKSpriteNode(imageNamed: "hand")
    let fbIcon = SKSpriteNode(imageNamed: "facebookIcon")
    let starIcon = SKSpriteNode(imageNamed: "starIcon")
    
    //user defaults
    let userDefault = UserDefaults.standard
    
    
    override func sceneDidLoad() {
        //making sure it exits. Default value seems to be zero
        userDefault.integer(forKey: "highScore")

        //physics settings
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        //background color
        backgroundColor = SKColor.black

        
    }
    
    
    
    //did move to view
    override func didMove(to view: SKView) {
        
        //adding player data and physics
        player.userData = ["imageName" : "redBall"]
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.position = CGPoint(x: size.width/2, y: size.height * 0.3)
        player.physicsBody?.usesPreciseCollisionDetection = true

        
        
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

        
        //adding bar
        touchBar.position = CGPoint(x: size.width/2, y: size.height * 0.19)

        
        //adding pointer
        pointer.position = CGPoint(x: size.width - ((size.width - touchBar.size.width)/2), y: size.height * 0.17)
        
        
        //adding icons
        fbIcon.position = CGPoint(x: (size.width / 3) + 25, y: size.height * 0.10)
        
        
        starIcon.position = CGPoint(x: (size.width / 3) * 2 - 25, y: size.height * 0.10)
        
        
        //adding titelText
        titleText.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        
        //adding home items and initing monsters

        createHomeScreen()
        

        
    }
    
    func createHomeScreen(){
        addChild(player)
        addChild(directionLbl)
        addChild(touchBar)
        addChild(pointer)
        addChild(fbIcon)
        addChild(starIcon)
        addChild(titleText)
        
        //editing inital monsters
        let space = ((size.width - 32) - monster1I.size.width * 4)/3
        
        editMonster(monster: monster1I, position: CGPoint(x:    monster1I.size.width/2 + 16 , y: size.height - 2 * monster1I.size.height),name:"blueRing")
        editMonster(monster: monster2I, position: CGPoint(x:  (monster1I.size.width * 3 / 2 + 16 + space)  , y: size.height - 2 * monster1I.size.height),name:"greenRing")
        editMonster(monster: monster3I, position: CGPoint(x:  (monster1I.size.width * 5 / 2 + 16 + space * 2) , y: size.height - 2 * monster1I.size.height),name:"redRing")
        editMonster(monster: monster4I, position: CGPoint(x:   (monster1I.size.width * 7 / 2 + 16 + space * 3), y: size.height - 2 * monster1I.size.height),name:"yellowRing")
        //monstersnames

        
        let wait = SKAction.wait(forDuration: 3.0)
        
        let repeatPointer = SKAction.repeatForever(
            SKAction.sequence([ SKAction.run(runPointer),wait ])
        )
        
        run(SKAction.sequence([repeatPointer]))
    }
    
    func editMonster(monster: SKSpriteNode, position: CGPoint,name:String) {
        monster.userData = ["imageName" : name]
        monster.name = name
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
        
        print("run run1")
        let actualDuration =   ringSpeeed2
        let actionMoveDone = SKAction.removeFromParent()
        
        guard let monster1 = childNode(withName: "blueRing") else {
            print("no inital monster found")
            return
        }
        
        let space = ((size.width - 32) - monster1I.size.width * 4)/3
        
        let actionMove = SKAction.move(to: CGPoint(x: (monster1I.size.width * 1 / 2 + 16) , y: 0), duration: TimeInterval(actualDuration))
        
        do{
        monster1.run(SKAction.sequence([actionMove, actionMoveDone]))
        }
        catch {
            print("nope")
        }
        let actionMove2 = SKAction.move(to: CGPoint(x: (monster1I.size.width * 3 / 2 + 16 + space) , y: 0), duration: TimeInterval(actualDuration))
        self.monster2I.run(SKAction.sequence([actionMove2, actionMoveDone]))
        
        let actionMove3 = SKAction.move(to: CGPoint(x: (monster1I.size.width * 5 / 2 + 16 + space * 2) , y: 0), duration: TimeInterval(actualDuration))
        self.monster3I.run(SKAction.sequence([actionMove3, actionMoveDone]))
        
        let actionMove4 = SKAction.move(to: CGPoint(x: (monster1I.size.width * 7 / 2 + 16 + space * 3) , y: 0), duration: TimeInterval(actualDuration))
        self.monster4I.run(SKAction.sequence([actionMove4, actionMoveDone]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
       
        
        
        if fbIcon.contains(touchLocation) {
            print("fb touched")
        } else if starIcon.contains(touchLocation){
            print("star touched")
        } else {
                print("inital ")
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

            player.position = touchLocation

            
            
            
        }
        
        if let continueNode = childNode(withName: "continueCir"){
            if continueNode.contains(touchLocation){
                print("continue")
                removeContinueScreen()
                timeOut()
                scene?.view?.isPaused = false

            }
        }
        if let noThanks = childNode(withName: "noThanksLabel"){
            if noThanks.contains(touchLocation){

                print("no thanks")
                
                //removing all children and actions
                scene?.removeAllChildren()
                scene?.removeAllActions()
                scene?.view?.isPaused = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2/10), execute: {
                    self.createHomeScreen()
                    self.initalRun = false //so actions can run again
                    
                })
                
                

                print("done")
                
            }
            
        }
    
        

        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        if fbIcon.contains(touchLocation) {
            print("fb touched")
        } else if starIcon.contains(touchLocation){
            print("star touched")
        } else {
            // 2 - Set up initial location of projectile
            //        let monster = SKSpriteNode(imageNamed: "monster")
            player.position = touchLocation
            player.position = CGPoint(x: touchLocation.x , y: size.height * 0.3)
            
            player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
            player.physicsBody?.isDynamic = true
            player.physicsBody?.categoryBitMask = PhysicsCategory.Player
            player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            player.physicsBody?.collisionBitMask = PhysicsCategory.None
            player.physicsBody?.usesPreciseCollisionDetection = true
            
        }

    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        let imageName = monster.userData?["imageName"] as! String
        let playerImageName = self.player.userData?["imageName"] as! String
        
        if imageName.prefix(1) ==  playerImageName.prefix(1){
            self.score += 1
            label.text = String(self.score)
            
        } else {
            scene?.view?.isPaused = true
            let highScore = userDefault.integer(forKey: "highScore")
            if score > highScore{
                    userDefault.set(score, forKey: "highScore")
            }
            addContinueScreen()
            
        }
    }
    
    
    var collide = true
    func timeOut(){
        self.collide = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
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
    
    //containes all the nodes of the continue screen
    var names = [String]()
    //adds nodes to screen
    func addContinueScreen() {
        
        label.removeFromParent() //removes score label
        
        //transparent layer added
        var colorStart = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.0)
        func backGroundRect() {
            let rectLayer = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
            rectLayer.name = "bar"
            rectLayer.fillColor = colorStart//SKColor.black
            rectLayer.position = CGPoint(x: size.width/2 , y: size.height/2)
            rectLayer.alpha = 0.8
            rectLayer.zPosition = 100
            rectLayer.isAntialiased = false
            rectLayer.lineWidth = 0.01;
            rectLayer.name = "continueBackground"
            names.append("continueBackground")
            self.addChild(rectLayer)
        }
        
        func gameOverLabel(){
            
            let gameOverLabel = SKSpriteNode(imageNamed: "GAME OVER")
            
            gameOverLabel.zPosition = 101
            gameOverLabel.position = CGPoint(x: size.width/2 , y: size.height * 0.9)
            
            gameOverLabel.name = "GAME OVER"
            names.append("GAME OVER")
            self.addChild(gameOverLabel)
        }
        
        func scoreLbl(){
            
            let scoreLbl = SKSpriteNode(imageNamed: "Score")
            
            scoreLbl.zPosition = 101
            scoreLbl.position = CGPoint(x: size.width/2 - 40 , y: size.height * 0.8)
            
            scoreLbl.name = "Score"
            names.append("Score")
            self.addChild(scoreLbl)
        }
        
        func cscoreLbl(){
            
            //creating score label
            let cscoreLbl = SKLabelNode(fontNamed: "Hiragino Sans W3")
            
            cscoreLbl.text = String(score)
            cscoreLbl.fontSize = 20
            cscoreLbl.fontColor = SKColor.white
            cscoreLbl.position = CGPoint(x: size.width/2 + 40, y: size.height * 0.787)
            
            cscoreLbl.zPosition = 102
            
            cscoreLbl.name = "scoreLbl"
            names.append("scoreLbl")
            self.addChild(cscoreLbl)
        }
        
        func bestLbl(){
            
            let bestLbl = SKSpriteNode(imageNamed: "Best")
            
            bestLbl.zPosition = 101
            bestLbl.position = CGPoint(x: size.width/2 - 45 , y: size.height * 0.73)
            
            bestLbl.name = "Best"
            names.append("Best")
            self.addChild(bestLbl)
        }
        func cbestLbl(){
            
            //creating score label
            let cscoreLbl = SKLabelNode(fontNamed: "Hiragino Sans W3")
            
            cscoreLbl.text = String(userDefault.integer(forKey: "highScore"))
            cscoreLbl.fontSize = 20
            cscoreLbl.fontColor = SKColor.white
            cscoreLbl.position = CGPoint(x: size.width/2 + 40, y: size.height * 0.716)
            
            cscoreLbl.zPosition = 102
            
            cscoreLbl.name = "scoreLbl"
            names.append("scoreLbl")
            self.addChild(cscoreLbl)
        }
        
        func continueBar(){
            
            let continueBar = SKSpriteNode(imageNamed: "continueBar")
            
            continueBar.zPosition = 101
            continueBar.position = CGPoint(x: size.width/2 , y: size.height * 0.68)
            
            continueBar.name = "continueBar"
            names.append("continueBar")
            self.addChild(continueBar)
        }
        
        func continueCircleBorder() {
            let circle = SKShapeNode(circleOfRadius: 70)
            circle.name = "bar"
            circle.strokeColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.0)
            circle.lineWidth = 5
            

            circle.position = CGPoint(x: size.width/2 , y: size.height/2)
            circle.zPosition = 101
            circle.name = "continueCirBorder"
            names.append("continueCirBorder")
            self.addChild(circle)
        }
        
        func continueCircle() {
            let circle = SKShapeNode(circleOfRadius: 67)
            circle.name = "bar"
            circle.fillColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
            circle.strokeColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
            circle.position = CGPoint(x: size.width/2 , y: size.height/2)
            circle.zPosition = 101
            circle.name = "continueCir"
            names.append("continueCir")
            self.addChild(circle)
        }
        
        func continueLabel(){
            
            let continueLabel = SKSpriteNode(imageNamed: "CONTINUE PLAYING?")


            continueLabel.zPosition = 102
            continueLabel.position = CGPoint(x: size.width/2 , y: size.height/2)

            continueLabel.name = "continueLabel"
            names.append("continueLabel")
            self.addChild(continueLabel)
        }

        func noThanksLabel(){
            
            let noThanksLabel = SKSpriteNode(imageNamed: "NO THANKS")
            
            noThanksLabel.zPosition = 110
            noThanksLabel.position = CGPoint(x: size.width/2 , y: size.height * 0.25)
            
            noThanksLabel.name = "noThanksLabel"
            names.append("noThanksLabel")
            self.addChild(noThanksLabel)
        }

        func fbIcon(){
            
            let fbIcon = SKSpriteNode(imageNamed: "facebookIcon")
            
            fbIcon.zPosition = 110
            fbIcon.position = CGPoint(x: size.width/3 , y: size.height * 0.15)
            
            fbIcon.name = "fbIcon"
            names.append("fbIcon")
            self.addChild(fbIcon)
        }
        func starIcon(){

            let starIcon = SKSpriteNode(imageNamed: "starIcon")

            starIcon.zPosition = 110
            starIcon.position = CGPoint(x: size.width/2 , y: size.height * 0.15)

            starIcon.name = "starIcon"
            names.append("starIcon")
            self.addChild(starIcon)
        }
        func shareIcon(){

            let shareIcon = SKSpriteNode(imageNamed: "shareIcon1")

            shareIcon.zPosition = 110
            shareIcon.position = CGPoint(x: size.width/3 * 2 , y: size.height * 0.15)

            shareIcon.name = "shareIcon"
            names.append("shareIcon")
            self.addChild(shareIcon)
        }


        
        backGroundRect()
        gameOverLabel()
        scoreLbl()
        cscoreLbl()
        bestLbl()
        cbestLbl()
        continueBar()
        continueCircleBorder()
        continueCircle()
        continueLabel()
        noThanksLabel()
        fbIcon()
        starIcon()
        shareIcon()
        
    }
    
    func removeContinueScreen(){
        for name in names{
            childNode(withName: name)?.removeFromParent()
        }
        
    }
    
    
}


