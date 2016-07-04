//
//  ViewController.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/4/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var gameView: UIView!
	private var board:GameBoard = GameBoard(size: 8, generationMethod: GameBoardGenerationMethod.Random)
	
	private var selectX:Int?
	private var selectY:Int!
	
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
				makeViewForTile(x: x, y: y)
			}
		}
	}
	
	func selectTile(sender:UITapGestureRecognizer)
	{
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
					//cascade matches
					while let match = board.findMatch()
					{
						board.collapseMatch(match)
					}
					
					//remake view
					for subview in gameView.subviews
					{
						subview.removeFromSuperview()
					}
					for y in 0..<board.size
					{
						for x in 0..<board.size
						{
							makeViewForTile(x: x, y: y)
						}
					}
					
					self.selectX = nil
				}
			}
		}
		else
		{
			selectX = senderX
			selectY = senderY
		}
	}
	
	private var tileSize:CGFloat
	{
		return gameView.frame.width / CGFloat(board.size)
	}
	
	private func makeViewForTile(x x:Int, y: Int) -> UIView
	{
		if let tile = board.tileAt(x: x, y: y)
		{
			let tileView = UIView(frame: CGRectMake(CGFloat(x) * tileSize, CGFloat(y) * tileSize, tileSize, tileSize))
			switch(tile.color)
			{
			case .Red: tileView.backgroundColor = UIColor.redColor()
			case .Blue: tileView.backgroundColor = UIColor.blueColor()
			case .Yellow: tileView.backgroundColor = UIColor.yellowColor()
			case .Green: tileView.backgroundColor = UIColor.greenColor()
			}
			gameView.addSubview(tileView)
			return tileView
		}
		assertionFailure()
		return UIView()
	}
}

