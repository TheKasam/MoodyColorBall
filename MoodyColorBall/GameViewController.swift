//
//  GameViewController.swift
//  MoodyColorBall
//
//  Created by Sai Kasam on 1/31/18.
//  Copyright © 2018 DevHandles. All rights reserved.
//

import GoogleMobileAds

import UIKit
import SpriteKit

class GameViewController: UIViewController, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        let request: GADRequest = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
        bannerView.delegate = self

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
}

