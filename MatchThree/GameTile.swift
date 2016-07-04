//
//  GameTile.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/4/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import Foundation

enum GameTileColor
{
	case Red
	case Blue
	case Green
	case Yellow
	case Gray
	case Purple
	case Black
}

enum GameTileProperty
{
	case None
	case Clockwise
	case Counterclockwise
}

struct GameTile
{
	let color:GameTileColor
	let property:GameTileProperty
	let identifier:Int
	
	init(color:GameTileColor)
	{
		self.color = color
		self.property = .None
		self.identifier = -1
	}
	
	init(color:GameTileColor, property:GameTileProperty)
	{
		self.color = color
		self.property = property
		self.identifier = -1
	}
	
	init(color:GameTileColor, property:GameTileProperty, identifier:Int)
	{
		self.color = color
		self.property = property
		self.identifier = identifier
	}
	
	var canSelect:Bool
	{
		return self.color != .Black
	}
}

extension GameTile:Equatable {}

func ==(lhs:GameTile, rhs:GameTile) -> Bool
{
	return lhs.color == rhs.color && lhs.property == rhs.property
}