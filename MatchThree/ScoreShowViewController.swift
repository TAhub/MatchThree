//
//  ScoreShowViewController.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/5/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import UIKit

let returnAfter:NSTimeInterval = 4

class ScoreShowViewController: UIViewController {

	@IBOutlet weak var scoreLabel: UILabel!
	
	var score:Int!
	private var returnTimer:NSTimer!
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		scoreLabel.text = "You got \(score) points!"
		
		returnTimer = NSTimer.scheduledTimerWithTimeInterval(returnAfter, target: self, selector: #selector(returnToRoot), userInfo: nil, repeats: false)
		
		//TODO: register score
		
	}
	
	func returnToRoot()
	{
		self.navigationController?.popToRootViewControllerAnimated(true)
	}
}
