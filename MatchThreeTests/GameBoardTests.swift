//
//  GameBoardTests.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/4/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import XCTest
@testable import MatchThree

class GameBoardTests: XCTestCase {
	
	var gameBoard:GameBoard!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		gameBoard = GameBoard(size: 3)
    }
	
	//MARK: constants for quick array building
	let red = GameTile(color: GameTileColor.Red, property: GameTileProperty.None)
	let blue = GameTile(color: GameTileColor.Blue, property: GameTileProperty.None)
	let green = GameTile(color: GameTileColor.Green, property: GameTileProperty.None)
	let yellow = GameTile(color: GameTileColor.Yellow, property: GameTileProperty.None)
	
	//MARK: tests
	
	func testTileAt()
	{
		XCTAssertNotNil(gameBoard.tileAt(x: 0, y: 0))
		XCTAssertNotNil(gameBoard.tileAt(x: 2, y: 2))
		XCTAssertNil(gameBoard.tileAt(x: 3, y: 0))
		XCTAssertNil(gameBoard.tileAt(x: 0, y: -1))
	}
	
	func testSetBoard()
	{
		let comparisonBoard = [red, red, red, blue, blue, blue, green, green, green]
		gameBoard.setBoard(comparisonBoard)
		XCTAssertTrue(compareAgainst(comparisonBoard))
	}

	func testRotate()
	{
		let comparisonBoard = [red, red, red,
		                       blue, blue, blue,
		                       green, green, yellow]
		let comparisonBoardClockwise = [green, blue, red,
		                                green, blue, red,
		                                yellow, blue, red]
		let comparisonBoardCounterclockwise = [red, blue, yellow,
		                                       red, blue, green,
		                                       red, blue, green]
		
		gameBoard.setBoard(comparisonBoard)
		
		gameBoard.rotateClockwise()
		XCTAssertTrue(compareAgainst(comparisonBoardClockwise))
		
		gameBoard.rotateCounterclockwise()
		XCTAssertTrue(compareAgainst(comparisonBoard))
		
		gameBoard.rotateCounterclockwise()
		XCTAssertTrue(compareAgainst(comparisonBoardCounterclockwise))
		
		gameBoard.setBoard(comparisonBoard)
		gameBoard.rotateCounterclockwise()
		gameBoard.rotateCounterclockwise()
		gameBoard.rotateCounterclockwise()
		gameBoard.rotateCounterclockwise()
		XCTAssertTrue(compareAgainst(comparisonBoard))
		
		gameBoard.setBoard(comparisonBoard)
		gameBoard.rotateClockwise()
		gameBoard.rotateClockwise()
		gameBoard.rotateClockwise()
		gameBoard.rotateClockwise()
		XCTAssertTrue(compareAgainst(comparisonBoard))
	}
	
	func testFindMatchStartsAtTopWhenEqual()
	{
		let comparisonBoard = [red, red, red, blue, blue, blue, green, green, green]
		gameBoard.setBoard(comparisonBoard)
		
		let match = gameBoard.findMatch()
		XCTAssertNotNil(match)
		XCTAssertTrue(match ?? Match(x: 0, y: 0, width: 0, height: 0) == Match(x: 0, y: 0, width: 3, height: 1))
	}
	
	func testFindMatchStartsWithLargest()
	{
		gameBoard = GameBoard(size: 4)
		let comparisonBoard = [red, red, red, yellow, blue, blue, blue, blue, green, green, green, yellow, yellow, red, yellow, red]
		gameBoard.setBoard(comparisonBoard)
		
		let match = gameBoard.findMatch()
		XCTAssertNotNil(match)
		XCTAssertTrue(match ?? Match(x: 0, y: 0, width: 0, height: 0) == Match(x: 0, y: 1, width: 4, height: 1))
	}
	
	//MARK: helper functions
	func compareAgainst(compareArray:[GameTile]) -> Bool
	{
		for y in 0..<gameBoard.size
		{
			for x in 0..<gameBoard.size
			{
				let tileAt = gameBoard.tileAt(x: x, y: y)
				if let tileAt = tileAt
				{
					if (tileAt != compareArray[x + y * gameBoard.size])
					{
						return false
					}
				}
				else
				{
					return false
				}
			}
		}
		
		return true
	}
}