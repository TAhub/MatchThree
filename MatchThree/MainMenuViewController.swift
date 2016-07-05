//
//  MainMenuViewController.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/5/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var scoreButton: UIButton!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		startButton.hidden = true
		startButton.alpha = 0
		scoreButton.hidden = true
		scoreButton.alpha = 0

        GameKitHelper.sharedInstance.authenticateLocalPlayer()
		{
			if let vc = GameKitHelper.sharedInstance.viewController
			{
				self.presentViewController(vc, animated: true, completion: nil)
			}
			else
			{
				self.startButton.hidden = false
				if GameKitHelper.sharedInstance.enableGameCenter
				{
					self.scoreButton.hidden = false
				}
				UIView.animateWithDuration(0.5)
				{
					self.startButton.alpha = 1
					self.scoreButton.alpha = 1
				}
			}
		}
	}
}