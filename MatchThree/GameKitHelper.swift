//
//  GameKitHelper.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/5/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import GameKit

class GameKitHelper
{
	static let sharedInstance = GameKitHelper()
	
	var enableGameCenter:Bool = true
	var lastError:NSError?
	var viewController:UIViewController?
	var leaderboardIdentifier:String?
	
	func authenticateLocalPlayer(completion:()->())
	{
		let localPlayer = GKLocalPlayer.localPlayer()
		
		localPlayer.authenticateHandler =
		{ (viewController, error) in
			self.lastError = error
			if let error = error
			{
				print("GameKit error: \(error.userInfo.description)")
			}
			
			self.viewController = viewController
			if viewController == nil
			{
				if localPlayer.authenticated
				{
					self.enableGameCenter = true
					
					localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler()
					{ (identifier, error) in
						if let error = error
						{
							print("GameKit leaderboard error: \(error.userInfo.description)")
						}
						else
						{
							self.leaderboardIdentifier = identifier
						}
					}
				}
				else
				{
					self.enableGameCenter = false
				}
			}
			
			completion()
		}
	}
	
	func reportScore(score:Int)
	{
		if let id = leaderboardIdentifier
		{
			let gkscore = GKScore(leaderboardIdentifier: id)
			gkscore.value = Int64(score)
			
			GKScore.reportScores([gkscore])
			{ (error) in
				if let error = error
				{
					print("GameKit score error: \(error.userInfo.description)")
				}
			}
		}
	}
}