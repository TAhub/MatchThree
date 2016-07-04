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
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		let recognizer = UITapGestureRecognizer()
//		recognizer.addTarget(self, action: #selector(TESTFUNC))
		gameView.addGestureRecognizer(recognizer)
		
		for y in 0..<board.size
		{
			for x in 0..<board.size
			{
				makeViewForTile(x: x, y: y)
			}
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

