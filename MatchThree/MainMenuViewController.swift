//
//  MainMenuViewController.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/5/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import UIKit
import GameKit

class MainMenuViewController: UIViewController, GKGameCenterControllerDelegate {

	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var scoreButton: UIButton!
	@IBOutlet weak var achievementButton: UIButton!
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		startButton.hidden = true
		startButton.alpha = 0
		scoreButton.hidden = true
		scoreButton.alpha = 0
		achievementButton.hidden = true
//		achievementButton.alpha = 0

        GameKitHelper.sharedInstance.authenticateLocalPlayer()
		{
			if let vc = GameKitHelper.sharedInstance.viewController
			{
				self.presentViewController(vc, animated: true, completion: nil)
			}
			else
			{
//				GameKitHelper.sharedInstance.resetAchievements()
				
				self.startButton.hidden = false
				if GameKitHelper.sharedInstance.enableGameCenter
				{
					self.scoreButton.hidden = false
//					self.achievementButton.hidden = false
				}
				UIView.animateWithDuration(0.5)
				{
					self.startButton.alpha = 1
					self.scoreButton.alpha = 1
//					self.achievementButton.alpha = 1
				}
			}
		}
	}
	
	@IBAction func scoreButtonPressed()
	{
		displayGCVC(GKGameCenterViewControllerState.Leaderboards)
	}
	
	@IBAction func achivementButtonPressed()
	{
		displayGCVC(GKGameCenterViewControllerState.Achievements)
	}
	
	private func displayGCVC(state:GKGameCenterViewControllerState)
	{
		if let id = GameKitHelper.sharedInstance.leaderboardIdentifier
		{
			let gcViewController = GKGameCenterViewController()
			gcViewController.gameCenterDelegate = self
			gcViewController.viewState = state
			gcViewController.leaderboardIdentifier = id
			self.presentViewController(gcViewController, animated: true, completion: nil)
		}
	}
	
	func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
		gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
	}
}