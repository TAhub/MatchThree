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
let junkyChance:UInt32 = 8
let rotationChance:UInt32 = 6
let treasureChance:UInt32 = 8
let treasureScoreBonus = 5

//MARK: match definition
struct Match
{
	let x:Int
	let y:Int
	let width:Int
	let height:Int
	
	var points:Int
	{
		//match points raise by 2 for every tile over 3
		let size = width + height - 1
		return (size <= 3 ? size : 3 + (size - 3) * 2)
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
	var score:Int = 0
	var moves:Int = 0
	let size:Int
	private var board:[GameTile]!
	private let generationMethod:GameBoardGenerationMethod
	private var identifierOn = 0
	
	init(size:Int, generationMethod:GameBoardGenerationMethod)
	{
		self.size = size
		self.generationMethod = generationMethod
		
		while (!genBoard()) {}
		markTiles()
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
//			print("LOOKING FOR MATCHES")
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
		markTiles()
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
		
		let fromTile = board[toI(x: xFrom, y: yFrom)]
		let toTile = board[toI(x: xTo, y: yTo)]
		
		//can't swap black tiles
		if (!fromTile.canSelect || !toTile.canSelect)
		{
			return false
		}
		
		//experimentally swap the two tiles
		board[toI(x: xFrom, y: yFrom)] = toTile
		board[toI(x: xTo, y: yTo)] = fromTile
		
		if matchExists
		{
			//the swap was a good one, so it can happen
			self.moves += 1
			return true
		}
		
		//otherwise, the swap didn't do anything, so undo it
		board[toI(x: xFrom, y: yFrom)] = fromTile
		board[toI(x: xTo, y: yTo)] = toTile
		return false
	}
	
	func collapseMatch(match:Match)
	{
		//raise score based on the match size
		score += match.points
		
		var soundEffect:SoundIDs = .Match
		
		//convert all of the tiles in the match into empty, tallying special bonuses as you go
		var rotate = 0
		for x in match.x..<match.x+match.width
		{
			for y in match.y..<match.y+match.height
			{
				let tile = board[toI(x: x, y: y)]
				if tile.property == .Junky
				{
					GameKitHelper.sharedInstance.reportAchievement(.Junk, newI: 1, target: 40, checkOld: true)
					
					if soundEffect == .Match
					{
						soundEffect = .Junk
					}
					
					//junky tiles are turned into black tiles, instead of going away and leaving air
					board[toI(x: x, y: y)] = GameTile(color: .Black, property: .None, identifier: tile.identifier)
				}
				else
				{
					board[toI(x: x, y: y)] = GameTile(color: .Black, property: .Empty)
				}
				
				switch tile.property
				{
				case .Clockwise: rotate += 1; GameKitHelper.sharedInstance.reportAchievement(.Rotate, newI: 1, target: 40, checkOld: true)
				case .Counterclockwise: rotate -= 1; GameKitHelper.sharedInstance.reportAchievement(.Rotate, newI: 1, target: 40, checkOld: true)
				case .Treasure: score += treasureScoreBonus; GameKitHelper.sharedInstance.reportAchievement(.Treasure, newI: 1, target: 40, checkOld: true); soundEffect = .Treasure
				default: break
				}
			}
		}
		
		if rotate > 0
		{
			for _ in 0..<rotate
			{
				rotateClockwise()
			}
		}
		else if rotate < 0
		{
			for _ in 0..<(-rotate)
			{
				rotateCounterclockwise()
			}
		}

		if rotate != 0
		{
			soundEffect = .Rotate
		}
		
		SoundHelper.sharedInstance.playSound(soundEffect)
	
		//make all existing tiles fall down
		for x in match.x..<match.x+match.width
		{
			for y in (0..<match.y + match.height).reverse()
			{
				let tile = board[toI(x: x, y: y)]
				var yOn = y + 1
				if tile.property != .Empty
				{
					//move this one down until it hits something
					while yOn < size && board[toI(x: x, y: yOn)].property == GameTileProperty.Empty
					{
						board[toI(x: x, y: yOn - 1)] = GameTile(color: .Black, property: .Empty)
						board[toI(x: x, y: yOn)] = tile
						yOn += 1
					}
				}
			}
		}
		
		//fill in all empty tiles with new tiles
		for y in 0..<size
		{
			for x in 0..<size
			{
				if board[toI(x: x, y: y)].property == GameTileProperty.Empty
				{
					board[toI(x: x, y: y)] = generateTile()
				}
			}
		}
		
		markTiles()
	}
	
	func findMatch() -> Match?
	{
		return findMatch(false)
	}
	
	var matchExists:Bool
	{
		return findMatch(true) != nil
	}
	
	var moveExists:Bool
	{
		for y in 0..<size
		{
			for x in 0..<size
			{
				//for every tile, check for a horizontal and a vertical match
				
				for j in 0..<2
				{
					let oX = x + (j == 0 ? 1 : 0)
					let oY = y + (j == 0 ? 0 : 1)
					
					if oX < size && oY < size
					{
						let tile = board[toI(x: x, y: y)]
						let oTile = board[toI(x: oX, y: oY)]
						
						//check to see if you can discard this move for any trivial reason
						if tile.color != oTile.color || !tile.canSelect || !oTile.canSelect || !tile.canMatch
						{
							//experimentally try the move
							board[toI(x: x, y: y)] = oTile
							board[toI(x: oX, y: oY)] = tile
							
							//see if there are now any matches
							let exists = matchExistsLocal(x: x, y: y)
							
							//and undo the move
							board[toI(x: x, y: y)] = tile
							board[toI(x: oX, y: oY)] = oTile
							
							//if there was a match, return yes, there was a move
							if exists
							{
								return true
							}
						}
					}
				}
			}
		}
		
		return false
	}
	
	//MARK: helper methods
	
	private func markTiles()
	{
		//provide an identifier to everything with an identifier of -1
		for i in 0..<board.count
		{
			let tile = board[i]
			if tile.identifier == -1
			{
				//give the tile a property, if it didn't have one before
				var property = tile.property
				if property == .None && generationMethod == .Random
				{
					if arc4random_uniform(100) < junkyChance
					{
						property = .Junky
					}
					else if arc4random_uniform(100) < rotationChance
					{
						property = (arc4random_uniform(2) == 1 ? .Clockwise : .Counterclockwise)
					}
					else if arc4random_uniform(100) < treasureChance
					{
						property = .Treasure
					}
				}
				
				board[i] = GameTile(color: tile.color, property: property, identifier: identifierOn)
				identifierOn += 1
			}
		}
	}
	
	private func breakMatch(match:Match)
	{
		if generationMethod != .Random
		{
//			print("  ERROR: tried to break matches while in non-random mode")
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
//				print("  Found match with x=\(match.x), y=\(match.y), w=\(match.width), h=\(match.height) of color \(tile.color) with \(match.points) points; fixing at (\(pick.0),\(pick.1)) with color \(newTile.color)")
				
				board[toI(x: pick.0, y: pick.1)] = newTile
				break
			}
		}
	}
	
	private func generateTile() -> GameTile
	{
		let color:GameTileColor
		switch(generationMethod)
		{
		case .AllRed: color = .Red
		case .AllBlue: color = .Blue
		default:
			switch(arc4random_uniform(6))
			{
			case 0: color = .Red
			case 1: color = .Blue
			case 2: color = .Green
			case 3: color = .Gray
			case 4: color = .Purple
			default: color = .Yellow
			}
		}
		markTiles()
		return GameTile(color: color)
	}
	
	private func matchExistsLocal(x aroundX:Int, y aroundY:Int) -> Bool
	{
		for y in max(aroundY - 1, 0)...min(aroundY + 1, size - 1)
		{
			for x in max(aroundX - 1, 0)...min(aroundX + 1, size - 1)
			{
				let tile = board[toI(x: x, y: y)]
				
				if tile.canMatch
				{
					func exploreDirection(dX dX:Int, dY:Int) -> Bool
					{
						var atX = x
						var atY = y
						for _ in 1..<minMatchSize
						{
							atX += dX
							atY += dY
							if atX < 0 || atY < 0 || atX >= size || atY >= size
							{
								return false
							}
							if board[toI(x: atX, y: atY)].color != tile.color
							{
								return false
							}
						}
						return true
					}
					
					if exploreDirection(dX: 1, dY: 0) || exploreDirection(dX: -1, dY: 0) || exploreDirection(dX: 0, dY: 1) || exploreDirection(dX: 0, dY: -1)
					{
						return true
					}
				}
			}
		}
		return false
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
				if tile.canMatch
				{
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