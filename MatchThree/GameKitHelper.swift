//
//  GameKitHelper.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/5/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import GameKit

enum AchievementIDs:String
{
	case LotsaPoints = "M3LotsaPoints"
	case Junk = "M3Junk"
	case Rotate = "M3Rotate"
	case Treasure = "M3Treasure"
	case Lazy = "M3Lazy"
}

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
	
	func resetAchievements()
	{
		GKAchievement.resetAchievementsWithCompletionHandler()
		{ (error) in
			if let error = error
			{
				print("GameKit achievement reset error: \(error.userInfo.description)")
			}
		}
	}
	
	func reportAchievement(identifier:AchievementIDs, newI:Int, target:Int, checkOld:Bool)
	{
		var i = newI
		if checkOld
		{
			i += NSUserDefaults.standardUserDefaults().integerForKey(identifier.rawValue) ?? 0
			NSUserDefaults.standardUserDefaults().setInteger(i, forKey: identifier.rawValue)
		}
		
		let ach = GKAchievement(identifier: identifier.rawValue)
		ach.percentComplete = 100 * Double(i) / Double(target)
		
		print("Achievement \(identifier.rawValue) raised to \(ach.percentComplete)%")
		
		GKAchievement.reportAchievements([ach])
		{ (error) in
			if let error = error
			{
				print("GameKit achievement error: \(error.userInfo.description)")
			}
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