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
		
		gameBoard = GameBoard(size: 3, generationMethod: GameBoardGenerationMethod.AllRed)
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
	
	func testCanSwap()
	{
		//you aren't allowed to swap if there is already a three-in-a-row
		XCTAssertFalse(gameBoard.canSwap)
		
		let comparisonBoard = [red, yellow, red,
		                       yellow, red, yellow,
		                       red, yellow, red]
		gameBoard.setBoard(comparisonBoard)
		XCTAssertTrue(gameBoard.canSwap)
	}
	
	func testSwap()
	{
		let comparisonBoard = [red, yellow, red,
		                       yellow, red, blue,
		                       green, blue, red]
		let comparisonBoardPostSwap = [red, red, red,
		                               yellow, yellow, blue,
		                               green, blue, red]
		
		//you aren't allowed to swap non-adjacent tiles, even if it would be a good move
		gameBoard.setBoard(comparisonBoard)
		XCTAssertFalse(gameBoard.swap(xFrom: 2, yFrom: 2, xTo: 1, yTo: 0))
		
		//you aren't allowed to swap if it wouldn't create a match
		gameBoard.setBoard(comparisonBoard)
		XCTAssertFalse(gameBoard.swap(xFrom: 1, yFrom: 1, xTo: 1, yTo: 2))
		
		//otherwise, the swap works
		gameBoard.setBoard(comparisonBoard)
		XCTAssertTrue(gameBoard.swap(xFrom: 1, yFrom: 1, xTo: 1, yTo: 0))
		XCTAssertTrue(compareAgainst(comparisonBoardPostSwap))
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
	
	func testCollapseMatch()
	{
		let comparisonBoard = [red, yellow, red, yellow, blue, yellow, green, green, green]
		let comparisonBoardCollapsed = [red, red, red, red, yellow, red, yellow, blue, yellow]
		gameBoard.setBoard(comparisonBoard)
		let match = gameBoard.findMatch()
		XCTAssertNotNil(match)
		if let match = match
		{
			gameBoard.collapseMatch(match)
			XCTAssertTrue(compareAgainst(comparisonBoardCollapsed))
		}
	}
	
	func testCollapseVerticalMatch()
	{
		let comparisonBoard = [green, yellow, blue,
		                       green, blue, yellow,
		                       green, yellow, blue]
		let comparisonBoardCollapsed = [red, yellow, blue,
		                                red, blue, yellow,
		                                red, yellow, blue]
		gameBoard.setBoard(comparisonBoard)
		let match = gameBoard.findMatch()
		XCTAssertNotNil(match)
		if let match = match
		{
			gameBoard.collapseMatch(match)
			XCTAssertTrue(compareAgainst(comparisonBoardCollapsed))
		}
	}
	
	func testFindMatchStartsAtTopWhenEqual()
	{
		let comparisonBoard = [red, red, red, blue, blue, blue, green, green, green]
		gameBoard.setBoard(comparisonBoard)
		
		let match = gameBoard.findMatch()
		XCTAssertTrue(gameBoard.matchExists)
		XCTAssertNotNil(match)
		XCTAssertTrue(match ?? Match(x: 0, y: 0, width: 0, height: 0) == Match(x: 0, y: 0, width: 3, height: 1))
	}
	
	func testFindMatchStartsWithLargest()
	{
		gameBoard = GameBoard(size: 4, generationMethod: GameBoardGenerationMethod.AllRed)
		let comparisonBoard = [red, red, red, yellow, blue, blue, blue, blue, green, green, green, yellow, yellow, red, yellow, red]
		gameBoard.setBoard(comparisonBoard)
		
		let match = gameBoard.findMatch()
		XCTAssertTrue(gameBoard.matchExists)
		XCTAssertNotNil(match)
		XCTAssertTrue(match ?? Match(x: 0, y: 0, width: 0, height: 0) == Match(x: 0, y: 1, width: 4, height: 1))
	}
	
	func testNotFindMatchIfThereIsNone()
	{
		let comparisonBoard = [red, yellow, red,
		                       yellow, red, yellow,
		                       red, yellow, red]
		gameBoard.setBoard(comparisonBoard)
		
		let match = gameBoard.findMatch()
		XCTAssertFalse(gameBoard.matchExists)
		XCTAssertNil(match)
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