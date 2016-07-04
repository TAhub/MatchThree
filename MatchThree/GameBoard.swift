//
//  GameBoard.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/4/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import Foundation

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