//
//  GameTileTests.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/4/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import XCTest
@testable import MatchThree

class GameTileTests: XCTestCase {
	func testEquatable()
	{
		XCTAssertTrue(GameTile(color: GameTileColor.Red) == GameTile(color: GameTileColor.Red))
		XCTAssertFalse(GameTile(color: GameTileColor.Blue) == GameTile(color: GameTileColor.Red))
		XCTAssertFalse(GameTile(color: GameTileColor.Red, property: GameTileProperty.Clockwise) == GameTile(color: GameTileColor.Red))
	}
	
	func testCanSelect()
	{
		let red = GameTile(color: .Red)
		XCTAssertTrue(red.canSelect)
		let black = GameTile(color: .Black)
		XCTAssertFalse(black.canSelect)
	}
}