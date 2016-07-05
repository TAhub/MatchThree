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
				}
				else
				{
					self.enableGameCenter = false
				}
			}
			
			completion()
		}
	}
}