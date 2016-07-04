//
//  GameBoard.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/4/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import Foundation

//MARK: constants
let minMatchSize = 3
let startGenMatchFixes = 30

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

enum GameBoardGenerationMethod
{
	case AllRed
	case AllBlue
	case Random
}

class GameBoard
{
	let size:Int
	private var board:[GameTile]!
	private let generationMethod:GameBoardGenerationMethod
	
	init(size:Int, generationMethod:GameBoardGenerationMethod)
	{
		self.size = size
		self.generationMethod = generationMethod
		
		while (!genBoard()) {}
	}
	
	private func genBoard() -> Bool
	{
		//initialize the board
		board = [GameTile]()
		for _ in 0..<size
		{
			for _ in 0..<size
			{
				board.append(generateTile())
			}
		}
		
		//make sure the board doesn't start with any matches
		if generationMethod == .Random
		{
			print("LOOKING FOR MATCHES")
			for _ in 0..<startGenMatchFixes
			{
				let match = findMatch(true)
				if let match = match
				{
					breakMatch(match)
				}
				else
				{
					return true
				}
			}
			return false
		}
		return true
	}
	
	//MARK: interface
	
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
	
	var canSwap:Bool
	{
		return !matchExists
	}
	
	func swap(xFrom xFrom:Int, yFrom:Int, xTo:Int, yTo:Int) -> Bool
	{
		//don't bother swapping if you can't
		if !canSwap
		{
			return false
		}
		
		//make sure the tiles are adjacent, and are actual tiles and such
		if abs(xFrom - xTo) + abs(yFrom - yTo) != 1 && tileAt(x: xFrom, y: yFrom) != nil && tileAt(x: xTo, y: yTo) != nil
		{
			return false
		}
		
		//experimentally swap the two tiles
		let fromTile = board[toI(x: xFrom, y: yFrom)]
		let toTile = board[toI(x: xTo, y: yTo)]
		board[toI(x: xFrom, y: yFrom)] = toTile
		board[toI(x: xTo, y: yTo)] = fromTile
		
		if matchExists
		{
			//the swap was a good one, so it can happen
			return true
		}
		
		//otherwise, the swap didn't do anything, so undo it
		board[toI(x: xFrom, y: yFrom)] = fromTile
		board[toI(x: xTo, y: yTo)] = toTile
		return false
	}
	
	func collapseMatch(match:Match)
	{
		//move everything above the bottom of the match tiles down (match.height) tiles
		for x in match.x..<match.x+match.width
		{
			//look at the y values in reverse order so that the operation can be done in place
			for y in (0..<match.y+match.height).reverse()
			{
				let comparisonY = y - match.height
				let tileFrom:GameTile
				if comparisonY < 0
				{
					tileFrom = generateTile()
				}
				else
				{
					tileFrom = board[toI(x: x, y: comparisonY)]
				}
				
				board[toI(x: x, y: y)] = tileFrom
			}
		}
	}
	
	func findMatch() -> Match?
	{
		return findMatch(false)
	}
	
	var matchExists:Bool
	{
		return findMatch(true) != nil
	}
	
	func breakMatch(match:Match)
	{
		if generationMethod != .Random
		{
			print("  ERROR: tried to break matches while in non-random mode")
			return
		}
		
		//pick a random tile inside the match
		var matchTiles = [(Int, Int)]()
		for y in match.y..<match.height+match.y
		{
			for x in match.x..<match.width+match.x
			{
				matchTiles.append((x, y))
			}
		}
		
		let pick = matchTiles[Int(arc4random_uniform(UInt32(matchTiles.count)))]
		
		//now change the color of the tile to a different color
		let tile = board[toI(x: pick.0, y: pick.1)]
		while(true)
		{
			let newTile = generateTile()
			if newTile.color != tile.color
			{
				print("  Found match with x=\(match.x), y=\(match.y), w=\(match.width), h=\(match.height) of color \(tile.color) with \(match.points) points; fixing at (\(pick.0),\(pick.1)) with color \(newTile.color)")
				
				board[toI(x: pick.0, y: pick.1)] = newTile
				break
			}
		}
	}
	
	//MARK: helper methods
	
	private func generateTile() -> GameTile
	{
		let color:GameTileColor
		switch(generationMethod)
		{
		case .AllRed: color = .Red
		case .AllBlue: color = .Blue
		default:
			switch(arc4random_uniform(4))
			{
			case 0: color = .Red
			case 1: color = .Blue
			case 2: color = .Green
			default: color = .Yellow
			}
		}
		return GameTile(color: color, property: GameTileProperty.None)
	}
	
	private func findMatch(firstMatch:Bool) -> Match?
	{
		//the "firstMatch" variable returns the first match, whether or not it is the best one
		//this is mostly useful for finding if there IS a match
		
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
					else
					{
						break
					}
				}
				for y2 in y..<size
				{
					let oTile = board[toI(x: x, y: y2)]
					if oTile.color == tile.color
					{
						matchHeight += 1
					}
					else
					{
						break
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
				if firstMatch && matches.count > 0
				{
					return matches.first
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