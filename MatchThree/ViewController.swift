//
//  ViewController.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/4/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import UIKit

let swapTime = 0.25
let dropTimePerLevel = 0.1
let zapTime = 0.35
let fadeTime = 1.5
let playTime = 90
let popupTime = 2.85
let popupHeight:CGFloat = 100
let cornerBevelFactor:CGFloat = 0.15
let borderFactor:CGFloat = 0.1

class ViewController: UIViewController {

	@IBOutlet weak var gameView: UIView!
	private var board:GameBoard = GameBoard(size: 6, generationMethod: GameBoardGenerationMethod.Random)
	private var tileRepresentations = [Int:UIImageView]()
	private var deadTileRepresentations = [UIImageView]()
	
	@IBOutlet weak var scoreCounter: UILabel!
	@IBOutlet weak var movesCounter: UILabel!
	@IBOutlet weak var timeCounter: UILabel!
	
	private var clockTimer:NSTimer!
	private var secondsLeft = playTime
	
	
	private var selectX:Int?
	private var selectY:Int!
	private var animating = true
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		//tiles start out faded-out, and fade in when you begin
		
		for y in 0..<board.size
		{
			for x in 0..<board.size
			{
				let rep = getViewForTile(x: x, y: y)
				rep.alpha = 0
			}
		}
		
		SoundHelper.sharedInstance.playSound(.Shine)
		
		secondsLeft += 1
		timerTick()
		
		fadeAllTiles(1)
		{
			self.animating = false
			
			let recognizer = UITapGestureRecognizer()
			recognizer.addTarget(self, action: #selector(self.selectTile))
			self.gameView.addGestureRecognizer(recognizer)
			
			self.clockTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
		}
	}
	
	func timerTick()
	{
		secondsLeft = max(secondsLeft - 1, 0)
		
		timeCounter.text = "\(secondsLeft)"
		
		if secondsLeft == 0
		{
			//stop the timer
			clockTimer?.invalidate()
			
			if !animating
			{
				gameOver()
			}
		}
	}
	
	@IBAction func giveUp()
	{
		if secondsLeft > 0
		{
			secondsLeft = 1
			timerTick()
		}
	}
	
	
	func selectTile(sender:UITapGestureRecognizer)
	{
		if animating || secondsLeft == 0
		{
			return
		}
		
		let location = sender.locationInView(gameView)
		let senderX = Int(location.x / tileSize)
		let senderY = Int(location.y / tileSize)
		if let selectX = selectX
		{
			if (board.canSwap && board.swap(xFrom: selectX, yFrom: selectY, xTo: senderX, yTo: senderY))
			{
				//temporarily move the select pointer to the click location to properly disable the selection box
				self.selectX = senderX
				self.selectY = senderY
				destroySelectionBox()
				
				//mark the animation as started
				self.selectX = nil
				self.animating = true
				
				//update moves
				self.movesCounter.text = "\(self.board.moves)"
				
				//animate the swap
				UIView.animateWithDuration(swapTime, animations:
				{
					self.updateTileRepresentations()
				})
				{ (completed) in
					self.collapseMatches()
				}
			}
			else
			{
				destroySelectionBox()
				self.selectX = nil
			}
		}
		else if let tileAt = board.tileAt(x: senderX, y: senderY)
		{
			if tileAt.canSelect
			{
				selectX = senderX
				selectY = senderY
				makeSelectionBox()
			}
		}
	}
	
	private func makeSelectionBox()
	{
		SoundHelper.sharedInstance.playSound(.Select)
		
		let rep = getViewForTile(x: selectX!, y: selectY)
		
		let selectionBox = UIView(frame: CGRectMake(0, 0, tileSize, tileSize))
		selectionBox.layer.borderColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0.5).CGColor
		selectionBox.layer.borderWidth = tileSize * borderFactor
		selectionBox.layer.cornerRadius = tileSize * cornerBevelFactor
		rep.addSubview(selectionBox)
		
		
	}
	
	private func destroySelectionBox()
	{
		SoundHelper.sharedInstance.playSound(.Select)
		
		let rep = getViewForTile(x: selectX!, y: selectY)
		for subview in rep.subviews
		{
			subview.removeFromSuperview()
		}
	}
	
	private func makeScorePopup(score:Int, onMatch:Match)
	{
		//get the center of the match
		var matchCenterX = CGFloat(onMatch.x) + CGFloat(onMatch.width) / 2
		var matchCenterY = CGFloat(onMatch.y) + CGFloat(onMatch.height) / 2
		matchCenterX *= tileSize
		matchCenterY *= tileSize
		matchCenterX += gameView.frame.origin.x
		matchCenterY += gameView.frame.origin.y
		
		//generate an attributes list to give the string color borders
		let attributes = [NSStrokeColorAttributeName : UIColor.blackColor(),
		                  NSForegroundColorAttributeName : UIColor.whiteColor(),
		                  NSStrokeWidthAttributeName : -1.0,
		                  NSFontAttributeName : UIFont.systemFontOfSize(35)]
		
		let popup = UILabel()
		popup.attributedText = NSAttributedString(string: "+\(score)", attributes: attributes)
		popup.sizeToFit()
		popup.center = CGPoint(x: matchCenterX, y: matchCenterY)
		self.view.addSubview(popup)
		
		UIView.animateWithDuration(popupTime, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations:
		{
			popup.center = CGPoint(x: matchCenterX, y: matchCenterY - popupHeight)
		})
		{ (completed) in
			popup.removeFromSuperview()
		}
	}
	
	private func collapseMatches()
	{
		if let match = self.board.findMatch()
		{
			//save old score, so you can tell what the score gain is
			let oldScore = self.board.score
			
			//collapse the match
			self.board.collapseMatch(match)
			
			//make a score popup
			makeScorePopup(self.board.score - oldScore, onMatch: match)
			
			//update score
			self.scoreCounter.text = "\(self.board.score)"
			
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
					
					SoundHelper.sharedInstance.playSound(.Select)
				}
			}
		}
		else if secondsLeft == 0
		{
			gameOver()
		}
		else if !board.moveExists
		{
			//this happens after game over because there's no point animating the board re-making if it's just going to then end
			
			//fade out then back in
			fadeAllTiles(0)
			{
				for subview in self.gameView.subviews
				{
					subview.removeFromSuperview()
				}
				self.tileRepresentations.removeAll()
				
				SoundHelper.sharedInstance.playSound(.Shine)
				
				//make a new board, and add the tles from it
				let oldBoard = self.board
				self.board = GameBoard(size: self.board.size, generationMethod: .Random)
				
				//save the old board's score
				self.board.score = oldBoard.score
				self.board.moves = oldBoard.moves
				
				for y in 0..<self.board.size
				{
					for x in 0..<self.board.size
					{
						let rep = self.getViewForTile(x: x, y: y)
						rep.alpha = 0
					}
				}
				
				self.fadeAllTiles(1)
				{
					self.animating = false
				}
			}
		}
		else
		{
			self.animating = false
		}
	}
	
	private func fadeAllTiles(toAlpha:CGFloat, completion:()->())
	{
		UIView.animateWithDuration(fadeTime, animations:
		{
			for subview in self.gameView.subviews
			{
				subview.alpha = toAlpha
			}
		})
		{ (completed) in
			completion()
		}
	}
	
	private func gameOver()
	{
		SoundHelper.sharedInstance.playSound(.Shine)
		
		if let _ = selectX
		{
			destroySelectionBox()
		}
		
		fadeAllTiles(0)
		{
			for subview in self.gameView.subviews
			{
				subview.removeFromSuperview()
			}
			
			self.performSegueWithIdentifier("showScore", sender: self)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let ssvc = segue.destinationViewController as? ScoreShowViewController
		{
			ssvc.score = board.score
		}
	}
	
	private func findDeadTileRepresentations()
	{
		//find out what old reps are needed now
		var newReps = [Int:UIImageView]()
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
		var newReps = [UIImageView]()
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
	
	private func updateTileColor(tileView:UIImageView, tile:GameTile)
	{
		switch(tile.color)
		{
		case .Red: tileView.backgroundColor = UIColor.redColor()
		case .Blue: tileView.backgroundColor = UIColor.blueColor()
		case .Yellow: tileView.backgroundColor = UIColor.yellowColor()
		case .Green: tileView.backgroundColor = UIColor.greenColor()
		case .Gray: tileView.backgroundColor = UIColor.darkGrayColor()
		case .Purple: tileView.backgroundColor = UIColor.purpleColor()
		case .Black: tileView.backgroundColor = UIColor.blackColor()
		}
		
		//also give the tile an icon if necessary (IE an image, like a rotate icon or w/e)
		switch(tile.property)
		{
		case .Treasure: tileView.image = UIImage(named: "dollar-symbol.png")
		case .Junky: tileView.image = UIImage(named: "garbage.png")
		case .Clockwise: tileView.image = UIImage(named: "circle-of-two-clockwise-arrows-rotation.png")
		case .Counterclockwise: tileView.image = UIImage(named: "refresh-two-counterclockwise-circular-arrows-interface-symbol.png")
		default: tileView.image = nil
		}
	}
	
	private func getViewForTile(x x:Int, y: Int) -> UIImageView
	{
		if let tile = board.tileAt(x: x, y: y)
		{
			if let rep = tileRepresentations[tile.identifier]
			{
				updateTileColor(rep, tile: tile)
				return rep
			}
			
			
			let tileView = UIImageView(frame: CGRectMake(CGFloat(x) * tileSize, CGFloat(y) * tileSize, tileSize, tileSize))
			updateTileColor(tileView, tile: tile)
			
			tileView.layer.cornerRadius = tileSize * cornerBevelFactor
			
			//add the tile representation and register it with the representations dictionary
			gameView.addSubview(tileView)
			tileRepresentations[tile.identifier] = tileView
			
			return tileView
		}
		assertionFailure()
		return UIImageView()
	}
}

