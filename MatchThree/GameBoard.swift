//
//  GameBoard.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/4/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import Foundation

let minMatchSize = 3

//MARK: match definition
struct Match
{
	let x:Int
	let y:Int
	let width:Int
	let height:Int
	
	var points:Int
	{
		return width + height - 1
	}
}

extension Match:Equatable {}

func ==(lhs:Match, rhs:Match) -> Bool
{
	return lhs.x == rhs.x && lhs.y == rhs.y && lhs.width == rhs.width && lhs.height == rhs.height
}

//MARK: gameboard definition
class GameBoard
{
	let size:Int
	private var board:[GameTile]
	
	init(size:Int)
	{
		self.size = size
		
		//initialize the board
		board = [GameTile]()
		for _ in 0..<size
		{
			for _ in 0..<size
			{
				board.append(GameTile(color: GameTileColor.Red, property: GameTileProperty.None))
			}
		}
	}
	
	func tileAt(x x:Int, y:Int) -> GameTile?
	{
		if x < 0 || y < 0 || x >= size || y >= size
		{
			return nil
		}
		return board[toI(x: x, y: y)]
	}
	
	func setBoard(setTo:[GameTile])
	{
		board = setTo
	}
	
	func rotateClockwise()
	{
		rotateInner()
		{ (nw, ne, se, sw) in
			return (sw, nw, ne, se)
		}
	}
	
	func rotateCounterclockwise()
	{
		rotateInner()
		{ (nw, ne, se, sw) in
			return (ne, se, sw, nw)
		}
	}
	
	func findMatch() -> Match?
	{
		var matches = [Match]()
		for y in 0..<size
		{
			for x in 0..<size
			{
				let tile = board[toI(x: x, y: y)]
				var matchWidth = 0
				var matchHeight = 0
				for x2 in x..<size
				{
					let oTile = board[toI(x: x2, y: y)]
					if oTile.color == tile.color
					{
						matchWidth += 1
					}
				}
				for y2 in y..<size
				{
					let oTile = board[toI(x: x, y: y2)]
					if oTile.color == tile.color
					{
						matchHeight += 1
					}
				}
				
				if matchWidth > matchHeight && matchWidth >= minMatchSize
				{
					matches.append(Match(x: x, y: y, width: matchWidth, height: 1))
				}
				else if matchHeight >= minMatchSize
				{
					matches.append(Match(x: x, y: y, width: 1, height: matchHeight))
				}
			}
		}
		
		//look over the matches to find the largest one, by points
		var largestMatch:Match? = nil
		for match in matches
		{
			if largestMatch?.points ?? 0 < match.points
			{
				largestMatch = match
			}
		}
		
		return largestMatch
	}
	
	private func rotateInner(cornerClosure:(GameTile, GameTile, GameTile, GameTile)->(GameTile, GameTile, GameTile, GameTile))
	{
		let numLayers = size / 2 + size % 2
		for layer in 0..<numLayers
		{
			for position in 0..<size-layer*2-1
			{
				let nwPosition = toI(x: layer + position, y: layer)
				let nePosition = toI(x: size - layer - 1, y: layer + position)
				let swPosition = toI(x: layer, y: size - layer - 1 - position)
				let sePosition = toI(x: size - layer - 1 - position, y: size - layer - 1)
				
				let result = cornerClosure(board[nwPosition], board[nePosition], board[sePosition], board[swPosition])
				board[nwPosition] = result.0
				board[nePosition] = result.1
				board[sePosition] = result.2
				board[swPosition] = result.3
			}
		}
	}
	
	private func toI(x x:Int, y:Int) -> Int
	{
		return x + y * size
	}
}