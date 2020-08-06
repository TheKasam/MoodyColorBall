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
    var ringSpeeed = CGFloat(1.8)
    var ringWaitDuration = 1.3
    let ringSpeeed2 = CGFloat(1.6)
    var initalRun = false
    var continueGame = true
    var ringInterval: TimeInterval = TimeInterval(2)
    
    //game nodes
    let player = SKSpriteNode(imageNamed: "redBall")
    let gameNode = SKNode()
    let continueNode = SKNode()
    let homeNode = SKNode()
    
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

        addChild(homeNode)
        addChild(gameNode)
        addChild(continueNode)
        let glow = SKEffectNode()
        glow.addChild(SKSpriteNode(texture: SKTexture(imageNamed: "redBall")))
        glow.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": 40])
        glow.shouldRasterize = true
        player.addChild(glow)
    }
    
    
    
    //variables for updateloop
    var delta: TimeInterval = TimeInterval(0)
    var deltaForBlock: TimeInterval = TimeInterval(0)
    var last_update_time: TimeInterval = TimeInterval(0)
    var started: Bool = false
    //control the sppen by changing this variable
    var maxTime: TimeInterval = TimeInterval(1.3)
    
    
    //function that calls the function that spans rings
    //controls speed
    override func update(_ currentTime: TimeInterval) {
        
        
        if gameNode.isPaused == true {
            last_update_time = currentTime
        } else {
            
            
            if started == false {
                delta = TimeInterval(0)
                deltaForBlock = TimeInterval(0.6)
            } else if started == true {
                delta += currentTime - last_update_time
                deltaForBlock += currentTime - last_update_time
            }
            
            last_update_time = currentTime
            
            if delta >= maxTime {
                print(delta, "spawn ring")
                mainActionRepeat()
                delta = TimeInterval(0)
            }
            if deltaForBlock >= maxTime {
                print(deltaForBlock, "block spawned")
                block()
                deltaForBlock = TimeInterval(0)
            }
            
            
        }
        
        
        
    }
    
    //spawns rings and shuffels color array
    func mainActionRepeat(){
        setBallProperty()
        ring1()
        ring2()
        ring3()
        ring4()
        updateShuffleArray()
    }
    
    //did move to view
    override func didMove(to view: SKView) {
        
        //adding player data and physics
        player.userData = ["imageName" : "redBall"]
        player.name = "player"
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.position = CGPoint(x: size.width/2, y: size.height * 0.3)
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        
        //creating score label
        label.text = String(score)
        label.name = "label"
        label.fontSize = 30
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height - label.fontSize - 30)
        
        //creating directions label
        directionLbl.text = "Get the ball into the same colored ring!"
        directionLbl.fontSize = 18
        directionLbl.fontColor = SKColor.white
        directionLbl.position = CGPoint(x: size.width/2, y: size.height * 0.23)
        
        //adding bar
        touchBar.position = CGPoint(x: size.width/2, y: size.height * 0.21)

        //adding pointer
        pointer.position = CGPoint(x: size.width - ((size.width - touchBar.size.width)/2), y: size.height * 0.19)
        
        //adding icons
        fbIcon.position = CGPoint(x: (size.width / 3) + 25, y: size.height * 0.12)
        starIcon.position = CGPoint(x: (size.width / 3) * 2 - 25, y: size.height * 0.12)
        
        //adding titelText
        titleText.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        
        //adding home items and initing monsters
        createHomeScreen()

    }
    
    func createHomeScreen(){
        //resetting values
        maxTime = TimeInterval(1.3)
        player.userData = ["imageName" : "redBall"]
        player.texture = SKTexture(imageNamed: "redBall")
        
        self.homeNode.addChild(player)
        self.homeNode.addChild(directionLbl)
        self.homeNode.addChild(touchBar)
        self.homeNode.addChild(pointer)
        self.homeNode.addChild(fbIcon)
        self.homeNode.addChild(starIcon)
        self.homeNode.addChild(titleText)
        
        //editing inital monsters
        let monster1I = SKSpriteNode(imageNamed:  "blueRing")
        let monster2I = SKSpriteNode(imageNamed:  "greenRing")
        let monster3I = SKSpriteNode(imageNamed:  "redRing")
        let monster4I = SKSpriteNode(imageNamed:  "yellowRing")
        
        let space = ((size.width - 32) - monster1I.size.width * 4)/3
        
        editMonster(monster: monster1I, position: CGPoint(x: monster1I.size.width/2 + 16 , y: size.height - 2 * monster1I.size.height),name:"blueRing")
        editMonster(monster: monster2I, position: CGPoint(x:  (monster1I.size.width * 3 / 2 + 16 + space)  , y: size.height - 2 * monster1I.size.height),name:"greenRing")
        editMonster(monster: monster3I, position: CGPoint(x:  (monster1I.size.width * 5 / 2 + 16 + space * 2) , y: size.height - 2 * monster1I.size.height),name:"redRing")
        editMonster(monster: monster4I, position: CGPoint(x:   (monster1I.size.width * 7 / 2 + 16 + space * 3), y: size.height - 2 * monster1I.size.height),name:"yellowRing")
        //monstersnames
        
        let wait = SKAction.wait(forDuration: 3.0)
        
        let repeatPointer = SKAction.repeatForever(
            SKAction.sequence([ SKAction.run(runPointer),wait ])
        )
        
        homeNode.run(SKAction.sequence([repeatPointer]))
    }
    
    
    //adding properties to all 4 monsters
    func editMonster(monster: SKSpriteNode, position: CGPoint,name:String) {
        monster.userData = ["imageName" : name]
        monster.name = name
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        monster.position = position
        self.gameNode.addChild(monster)
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
        let actionMove = SKAction.move(to: CGPoint(x: ((size.width - touchBar.size.width)/2) , y: size.height * 0.19), duration: TimeInterval(actualDuration))
        let actionMove2 = SKAction.move(to: CGPoint(x: size.width - ((size.width - touchBar.size.width)/2) , y: size.height * 0.19), duration: TimeInterval(actualDuration))
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
        self.gameNode.addChild(monster)
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
            self.gameNode.addChild(monster)
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
        self.gameNode.addChild(monster)
        
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
        self.gameNode.addChild(monster)
        
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
        self.gameNode.addChild(monster)
        
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
//        monster.addGlow()
        
        
        monster.userData = ["imageName" : self.shuffledRingArray[3]]
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        
        let space = ((size.width - 32) - monster.size.width * 4)/3
        
        monster.position = CGPoint(x: (monster.size.width * 7 / 2 + 16 + space * 3) , y: size.height + monster.size.height/2)
        
        // Add the monster to the scene
        self.gameNode.addChild(monster)
        
        // Determine speed of the monster
        let actualDuration =   ringSpeeed//random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: (monster.size.width * 7 / 2 + 16 + space * 3) , y: 0), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    //runs inital row of rings
    func run1(){
        gameNode.childNode(withName: "blueRing")?.removeFromParent()
        gameNode.childNode(withName: "greenRing")?.removeFromParent()
        gameNode.childNode(withName: "redRing")?.removeFromParent()
        gameNode.childNode(withName: "yellowRing")?.removeFromParent()
        
        func addPhysics(monster: SKSpriteNode, name: String, position: CGPoint){
            monster.userData = ["imageName" : name]
            
            monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
            monster.physicsBody?.isDynamic = true // 2
            monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
            monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
            monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
            
            monster.position = position
            self.gameNode.addChild(monster)
        }
        
        let monster1 = SKSpriteNode(imageNamed: "blueRing")
        let space = ((size.width - 32) - monster1.size.width * 4)/3
        
        addPhysics(monster: monster1, name: "blueRing", position: CGPoint(x: monster1.size.width/2 + 16 , y: size.height - 2 * monster1.size.height))
        
        let monster2 = SKSpriteNode(imageNamed: "greenRing")
        addPhysics(monster: monster2, name: "greenRing", position: CGPoint(x:  (monster1.size.width * 3 / 2 + 16 + space)  , y: size.height - 2 * monster1.size.height))

        let monster3 = SKSpriteNode(imageNamed: "redRing")
        addPhysics(monster: monster3, name: "redRing",position: CGPoint(x:  (monster1.size.width * 5 / 2 + 16 + space * 2) , y: size.height - 2 * monster1.size.height))

        let monster4 = SKSpriteNode(imageNamed: "yellowRing")
        addPhysics(monster: monster4, name: "yellowRing", position: CGPoint(x:   (monster1.size.width * 7 / 2 + 16 + space * 3), y: size.height - 2 * monster1.size.height))

        print("run run1")
        let actualDuration =   ringSpeeed2
        let actionMoveDone = SKAction.removeFromParent()

        let actionMove = SKAction.move(to: CGPoint(x: (monster1.size.width * 1 / 2 + 16) , y: 0), duration: TimeInterval(actualDuration))
        monster1.run(SKAction.sequence([actionMove, actionMoveDone]))

        let actionMove2 = SKAction.move(to: CGPoint(x: (monster1.size.width * 3 / 2 + 16 + space) , y: 0), duration: TimeInterval(actualDuration))
        monster2.run(SKAction.sequence([actionMove2, actionMoveDone]))

        let actionMove3 = SKAction.move(to: CGPoint(x: (monster1.size.width * 5 / 2 + 16 + space * 2) , y: 0), duration: TimeInterval(actualDuration))
        monster3.run(SKAction.sequence([actionMove3, actionMoveDone]))

        let actionMove4 = SKAction.move(to: CGPoint(x: (monster1.size.width * 7 / 2 + 16 + space * 3) , y: 0), duration: TimeInterval(actualDuration))
        monster4.run(SKAction.sequence([actionMove4, actionMoveDone]))
    }
    
    func waitFunc(){
        print(self.ringWaitDuration)
        run(SKAction.wait(forDuration: self.ringWaitDuration))
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
            
                if gameNode.isPaused == false{

            
                print("inital")
                //logic to only start running once
                if self.initalRun == false{
                    
                    
                        score = 0 //reseting score
                        label.text = String(0)
                        self.gameNode.addChild(label)
            
                        //removing home elements
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
                
                        func startMain(){
                            self.started = true
                            mainActionRepeat()
                        }
                        gameNode.run(SKAction.sequence([SKAction.run(run1),wait,SKAction.run(startMain)]))
            
                        //running block
//                        let repeatBlock = SKAction.repeatForever(
//                            SKAction.sequence([
//                                SKAction.run(block),
//                                SKAction.wait(forDuration: 1.3)
//                                ]))

                        let wait2 = SKAction.wait(forDuration: 0.45)

                        gameNode.run(SKAction.sequence([wait2,SKAction.run(block)]))
            
                        self.initalRun = true
                    }
            player.position = CGPoint(x: touchLocation.x , y: size.height * 0.3)
            }
        }
        
        if let continueNode = continueNode.childNode(withName: "continueCir"){
            if continueNode.contains(touchLocation){
                
                print("continue")
                continueGame = false
                removeContinueScreen()
                self.gameNode.addChild(label)
                timeOut()
                gameNode.isPaused = false
            }
        }
        
        //restarts game from start
        func restartGame(){
            print("no thanks")
            self.ringSpeeed = CGFloat(1.8)
            self.ringWaitDuration = 1.3

            print("reset speed")
            print(self.ringSpeeed)
            continueGame = true
            
            //removing all children and actions
            gameNode.isPaused = false

            continueNode.removeAllChildren()
            continueNode.removeAllActions()
            
            gameNode.removeAllChildren()
            gameNode.removeAllActions()

            homeNode.removeAllChildren()
            homeNode.removeAllActions()
            
            
            if let layers = view?.layer.sublayers{
                for layer in layers {
                    if layer.name == "circleLayer" {
                        layer.removeFromSuperlayer()
                    }
                }
            }
            //bug if i dont
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2/10), execute: {
                
                self.createHomeScreen()
                self.initalRun = false
                self.started = false//so actions can run again
                
            })
            print("done")
        }
        if let noThanks = continueNode.childNode(withName: "noThanksLabel"){
            if noThanks.contains(touchLocation){
                restartGame()
            }
            
        }
        
        if let tryAgain = continueNode.childNode(withName: "tryImg"){
            if tryAgain.contains(touchLocation){
                restartGame()
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
            if gameNode.isPaused == false{
            // 2 - Set up initial location of projectile
            //        let monster = SKSpriteNode(imageNamed: "monster")
            player.position = touchLocation
            player.position = CGPoint(x: touchLocation.x , y: size.height * 0.3)
            }
        }

    }
    
    func randomPlayerColor() {
        var randomInt = arc4random_uniform(5)
        
        if randomInt == 1 {
            player.userData = ["imageName" : "redBall"]
            player.texture = SKTexture(imageNamed: "redBall")
            
            
        } else if randomInt == 2 {
            player.userData = ["imageName" : "blueBall"]
            player.texture = SKTexture(imageNamed: "blueBall")
            
            
        } else if randomInt == 3 {
            player.userData = ["imageName" : "greenBall"]
            player.texture = SKTexture(imageNamed: "greenBall")
            
            
        } else if randomInt == 4 {
            player.userData = ["imageName" : "yellowBall"]
            player.texture = SKTexture(imageNamed: "yellowBall")
            
        } else {
            player.userData = ["imageName" : "redBall"]
            player.texture = SKTexture(imageNamed: "redBall")
            
        }
        
        
    }
    
    func pulseEffect(){
        var ringColor = UIColor(red:0.82, green:0.01, blue:0.11, alpha:1.0).cgColor
        if player.userData!["imageName"] as! String == "redBall" {
            ringColor = UIColor(red:0.82, green:0.01, blue:0.11, alpha:1.0).cgColor
        } else if player.userData!["imageName"] as! String == "blueBall" {
            ringColor = UIColor(red:0.00, green:0.02, blue:1.00, alpha:1.0).cgColor
        } else if player.userData!["imageName"] as! String == "greenBall" {
            ringColor = UIColor(red:0.06, green:0.98, blue:0.00, alpha:1.0).cgColor
        } else if player.userData!["imageName"] as! String == "yellowBall" {
            ringColor = UIColor(red:0.99, green:1.00, blue:0.00, alpha:1.0).cgColor
        }
        let pulseEffect = LFTPulseAnimation(repeatCount: 1, radius:240, position: CGPoint(x:  self.player.position.x , y:  size.height * 0.7), color: ringColor)
        view?.layer.insertSublayer(pulseEffect, below: self.view?.layer)
    }
    
    var countTillChange: UInt32 = 3
    func randomColorChange(){
        
        randomPlayerColor()
        if countTillChange == 1 {
            
        }
        else if countTillChange == 0 {
            
            countTillChange = arc4random_uniform(7) + 3 ;
        }
        countTillChange -= 1
        
        
    }
    
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        let imageName = monster.userData?["imageName"] as! String
        let playerImageName = self.player.userData?["imageName"] as! String
        
        if imageName.prefix(1) ==  playerImageName.prefix(1){
            self.score += 1
            
            randomColorChange()
            pulseEffect()
            
            maxTime -= 0.05
            ringSpeeed -= 0.05
            label.text = String(self.score)
            
            let playerNode  = self.childNode(withName: "player")
            
            
        } else {
            gameNode.isPaused = true
            //pauses ring spawning function
            
            let highScore = userDefault.integer(forKey: "highScore")
            if score > highScore{
                    userDefault.set(score, forKey: "highScore")
            }
            gameNode.childNode(withName: "label")?.removeFromParent() //removes score label
            
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
    
    func removeContinueScreen(){
        for name in names{
            continueNode.childNode(withName: name)?.removeFromParent()
        }
        if let layers = view?.layer.sublayers{
            for layer in layers {
                if layer.name == "circleLayer" {
                    layer.removeFromSuperlayer()
                }
            }
        } else {
            print("layer didnt work")
        }
        
    }
    
    //containes all the nodes of the continue screen
    var names = [String]()
    
    //adds nodes to screen
    func addContinueScreen() {
        
        
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
            self.continueNode.addChild(rectLayer)
        }
        
        func gameOverLabel(){
            
            let gameOverLabel = SKSpriteNode(imageNamed: "GAME OVER")
            
            gameOverLabel.zPosition = 101
            gameOverLabel.position = CGPoint(x: size.width/2 , y: size.height * 0.9)
            
            gameOverLabel.name = "GAME OVER"
            names.append("GAME OVER")
            self.continueNode.addChild(gameOverLabel)
        }
        
        func scoreLbl(){
            
            let scoreLbl = SKSpriteNode(imageNamed: "Score")
            
            scoreLbl.zPosition = 101
            scoreLbl.position = CGPoint(x: size.width/2 - 40 , y: size.height * 0.8)
            
            scoreLbl.name = "Score"
            names.append("Score")
            self.continueNode.addChild(scoreLbl)
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
            self.continueNode.addChild(cscoreLbl)
        }
        
        func bestLbl(){
            
            let bestLbl = SKSpriteNode(imageNamed: "Best")
            
            bestLbl.zPosition = 101
            bestLbl.position = CGPoint(x: size.width/2 - 45 , y: size.height * 0.73)
            
            bestLbl.name = "Best"
            names.append("Best")
            self.continueNode.addChild(bestLbl)
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
            self.continueNode.addChild(cscoreLbl)
        }
        
        func continueBar(){
            
            let continueBar = SKSpriteNode(imageNamed: "continueBar")
            
            continueBar.zPosition = 101
            continueBar.position = CGPoint(x: size.width/2 , y: size.height * 0.68)
            
            continueBar.name = "continueBar"
            names.append("continueBar")
            self.continueNode.addChild(continueBar)
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
            self.continueNode.addChild(circle)
        }
        
        func continueLabel(){
            
            let continueLabel = SKSpriteNode(imageNamed: "CONTINUE PLAYING?")


            continueLabel.zPosition = 102
            continueLabel.position = CGPoint(x: size.width/2 , y: size.height/2)

            continueLabel.name = "continueLabel"
            names.append("continueLabel")
            self.continueNode.addChild(continueLabel)
        }
        
        func tryAgain(){
            let tryImg = SKSpriteNode(imageNamed: "TRY AGAIN")
            
            
            tryImg.zPosition = 102
            tryImg.position = CGPoint(x: size.width/2 , y: size.height/2)
            
            tryImg.name = "tryImg"
            names.append("tryImg")
            self.continueNode.addChild(tryImg)
            
        }

        func noThanksLabel(){
            
            let noThanksLabel = SKSpriteNode(imageNamed: "NO THANKS")
            
            noThanksLabel.zPosition = 110
            noThanksLabel.position = CGPoint(x: size.width/2 , y: size.height * 0.29)
            
            noThanksLabel.name = "noThanksLabel"
            names.append("noThanksLabel")
            self.continueNode.addChild(noThanksLabel)
        }

        func fbIcon(){
            
            let fbIcon = SKSpriteNode(imageNamed: "facebookIcon")
            
            fbIcon.zPosition = 110
            fbIcon.position = CGPoint(x: size.width/3 , y: size.height * 0.18)
            
            fbIcon.name = "fbIcon"
            names.append("fbIcon")
            self.continueNode.addChild(fbIcon)
        }
        func starIcon(){

            let starIcon = SKSpriteNode(imageNamed: "starIcon")

            starIcon.zPosition = 110
            starIcon.position = CGPoint(x: size.width/2 , y: size.height * 0.18)

            starIcon.name = "starIcon"
            names.append("starIcon")
            self.continueNode.addChild(starIcon)
        }
        func shareIcon(){

            let shareIcon = SKSpriteNode(imageNamed: "shareIcon1")

            shareIcon.zPosition = 110
            shareIcon.position = CGPoint(x: size.width/3 * 2 , y: size.height * 0.18)

            shareIcon.name = "shareIcon"
            names.append("shareIcon")
            self.continueNode.addChild(shareIcon)
        }


        backGroundRect()
        gameOverLabel()
        scoreLbl()
        cscoreLbl()
        bestLbl()
        cbestLbl()
        continueBar()
        noThanksLabel()
        
        if continueGame == true{
            continueCircle()
            continueLabel()
            ContinueScreen.animateCircle(frame: frame,view: view)
            
            func switchItems(){
                
                if gameNode.childNode(withName: "label") != nil{
                    print("playing game")
                } else {

                    self.continueNode.childNode(withName: "continueLabel")?.removeFromParent()
                    self.continueNode.childNode(withName: "continueCir")?.removeFromParent()
                    if let layers = self.view?.layer.sublayers{
                        for layer in layers {
                            if layer.name == "circleLayer" {
                                layer.removeFromSuperlayer()
                            } }
                        
                    } else {
                        print("layer didnt work")
                    }
                    tryAgain()
                }
            }
            
            let wait = SKAction.wait(forDuration: 5.0)

            continueNode.run(SKAction.sequence([wait,SKAction.run(switchItems)]))

        } else {
            continueNode.childNode(withName: "noThanksLabel")?.removeFromParent()
            tryAgain()
        }
        
        fbIcon()
        starIcon()
        shareIcon()
       
    }
    
}

extension SKSpriteNode {
    /// Initializes a textured sprite with a glow using an existing texture object.
    convenience init(texture: SKTexture, glowRadius: CGFloat) {
        self.init(texture: texture, color: .red, size: texture.size())
        
        let glow: SKEffectNode = {
            let glow = SKEffectNode()
            glow.addChild(SKSpriteNode(texture: texture))
            glow.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": glowRadius])
            glow.shouldRasterize = true
            return glow
        }()
        
        let glowRoot: SKNode = {
            let node = SKNode()
            node.name = "Glow"
            node.zPosition = -1
            return node
        }()
        
        glowRoot.addChild(glow)
        addChild(glowRoot)
}
}
