//
//  ViewController.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/4/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import UIKit

let swapTime = 0.5
let dropTimePerLevel = 0.15
let zapTime = 0.5

class ViewController: UIViewController {

	@IBOutlet weak var gameView: UIView!
	private var board:GameBoard = GameBoard(size: 8, generationMethod: GameBoardGenerationMethod.Random)
	private var tileRepresentations = [Int:UIView]()
	private var deadTileRepresentations = [UIView]()
	
	private var selectX:Int?
	private var selectY:Int!
	private var animating = false
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		let recognizer = UITapGestureRecognizer()
		recognizer.addTarget(self, action: #selector(selectTile))
		gameView.addGestureRecognizer(recognizer)
		
		for y in 0..<board.size
		{
			for x in 0..<board.size
			{
				getViewForTile(x: x, y: y)
			}
		}
	}
	
	func selectTile(sender:UITapGestureRecognizer)
	{
		if animating
		{
			return
		}
		
		let location = sender.locationInView(gameView)
		let senderX = Int(location.x / tileSize)
		let senderY = Int(location.y / tileSize)
		if let selectX = selectX
		{
			if selectX == senderX && selectY == senderY
			{
				self.selectX = nil
			}
			else if (board.canSwap)
			{
				if (board.swap(xFrom: selectX, yFrom: selectY, xTo: senderX, yTo: senderY))
				{
					self.animating = true
					
					//animate the swap
					UIView.animateWithDuration(swapTime, animations:
					{
						self.updateTileRepresentations()
					})
					{ (completed) in
						self.collapseMatches()
					}
				}
			}
		}
		else
		{
			selectX = senderX
			selectY = senderY
		}
	}
	
	private func collapseMatches()
	{
		if let match = self.board.findMatch()
		{
			//collapse the match
			self.board.collapseMatch(match)
			
			//fade away the old tiles
			self.findDeadTileRepresentations()
			UIView.animateWithDuration(zapTime, animations:
			{
				for rep in self.deadTileRepresentations
				{
					rep.alpha = 0
				}
			})
			{ (completed) in
				for rep in self.deadTileRepresentations
				{
					rep.removeFromSuperview()
				}
				self.deadTileRepresentations.removeAll()
				
				let dropHeight = self.generateNewTileRepresentationsInSky()
				UIView.animateWithDuration(dropTimePerLevel * Double(dropHeight / self.tileSize), animations:
				{
					self.updateTileRepresentations()
				})
				{ (completed) in
					self.collapseMatches()
				}
			}
		}
		else
		{
			self.animating = false
			self.selectX = nil
		}
	}
	
	private func findDeadTileRepresentations()
	{
		//find out what old reps are needed now
		var newReps = [Int:UIView]()
		for y in 0..<board.size
		{
			for x in 0..<board.size
			{
				if let tile = board.tileAt(x: x, y: y)
				{
					if let tileView = tileRepresentations[tile.identifier]
					{
						newReps[tile.identifier] = tileView
					}
				}
			}
		}
		
		//remove the views of all non-existant reps
		for key in tileRepresentations.keys
		{
			if newReps[key] == nil
			{
				if let rep = tileRepresentations[key]
				{
					deadTileRepresentations.append(rep)
				}
			}
		}
		
		//and replace the old list
		tileRepresentations = newReps
	}
	
	private func generateNewTileRepresentationsInSky() -> CGFloat
	{
		//get all the new reps
		var newReps = [UIView]()
		for y in 0..<board.size
		{
			for x in 0..<board.size
			{
				if let tile = board.tileAt(x: x, y: y)
				{
					if tileRepresentations[tile.identifier] == nil
					{
						let rep = getViewForTile(x: x, y: y)
						newReps.append(rep)
					}
				}
			}
		}
		
		//find the highest-y new rep
		var highestY:CGFloat = 0
		for rep in newReps
		{
			highestY = max(highestY, rep.frame.origin.y)
		}
		
		highestY += tileSize
		
		//now use that value to move all the reps up
		for rep in newReps
		{
			rep.frame = CGRectMake(rep.frame.origin.x, rep.frame.origin.y - highestY, tileSize, tileSize)
		}
		
		return highestY
	}
	
	private func updateTileRepresentations()
	{
		for y in 0..<board.size
		{
			for x in 0..<board.size
			{
				let rep = getViewForTile(x: x, y: y)
				rep.frame = CGRectMake(CGFloat(x) * tileSize, CGFloat(y) * tileSize, tileSize, tileSize)
			}
		}
	}
	
	private var tileSize:CGFloat
	{
		return gameView.frame.width / CGFloat(board.size)
	}
	
	private func getViewForTile(x x:Int, y: Int) -> UIView
	{
		if let tile = board.tileAt(x: x, y: y)
		{
			if let rep = tileRepresentations[tile.identifier]
			{
				return rep
			}
			
			
			let tileView = UIView(frame: CGRectMake(CGFloat(x) * tileSize, CGFloat(y) * tileSize, tileSize, tileSize))
			switch(tile.color)
			{
			case .Red: tileView.backgroundColor = UIColor.redColor()
			case .Blue: tileView.backgroundColor = UIColor.blueColor()
			case .Yellow: tileView.backgroundColor = UIColor.yellowColor()
			case .Green: tileView.backgroundColor = UIColor.greenColor()
			}
			
			//add the tile representation and register it with the representations dictionary
			gameView.addSubview(tileView)
			tileRepresentations[tile.identifier] = tileView
			
			return tileView
		}
		assertionFailure()
		return UIView()
	}
}

