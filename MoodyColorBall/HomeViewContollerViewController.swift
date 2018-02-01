//
//  HomeViewContollerViewController.swift
//  MoodyColorBall
//
//  Created by Sai Kasam on 2/1/18.
//  Copyright © 2018 DevHandles. All rights reserved.
//

import UIKit

class HomeViewContollerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.onViewTapped(sender:)))
        self.viewToTouch.addGestureRecognizer(gesture)
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var viewToTouch: UIView!
    
    @objc func onViewTapped(sender: UITapGestureRecognizer){
        

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first as! UITouch
        
        if (touch.view == viewToTouch){
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "gameID") as! GameViewController
            newViewController.modalTransitionStyle = .crossDissolve
            
            self.present(newViewController, animated: true, completion: nil)
            
            
        }else{
            print("bb")
        }
    }

}
