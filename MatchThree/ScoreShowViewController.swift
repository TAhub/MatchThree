//
//  ScoreShowViewController.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/5/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import UIKit

let returnAfter:NSTimeInterval = 2.5
let yayPoint = 25
let clapPoint = 100

class ScoreShowViewController: UIViewController {

	@IBOutlet weak var scoreLabel: UILabel!
	
	var score:Int!
	private var returnTimer:NSTimer!
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		scoreLabel.text = "You got \(score > 0 ? "\(score)" : "no") points!"
		
		returnTimer = NSTimer.scheduledTimerWithTimeInterval(returnAfter, target: self, selector: #selector(returnToRoot), userInfo: nil, repeats: false)
		
		GameKitHelper.sharedInstance.reportScore(score)
		
		SoundHelper.sharedInstance.playSound(score >= clapPoint ? SoundIDs.Clap : (score >= yayPoint ? SoundIDs.Yay : SoundIDs.Boo))
		
		if score == 0
		{
			GameKitHelper.sharedInstance.reportAchievement(.Lazy, newI: 100, target: 1, checkOld: false)
		}
		else
		{
			GameKitHelper.sharedInstance.reportAchievement(.LotsaPoints, newI: score, target: 120, checkOld: false)
		}
	}
	
	func returnToRoot()
	{
		self.navigationController?.popToRootViewControllerAnimated(true)
	}
}