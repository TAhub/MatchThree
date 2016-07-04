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
		XCTAssertTrue(GameTile(color: GameTileColor.Red, property: GameTileProperty.None) == GameTile(color: GameTileColor.Red, property: GameTileProperty.None))
		XCTAssertFalse(GameTile(color: GameTileColor.Blue, property: GameTileProperty.None) == GameTile(color: GameTileColor.Red, property: GameTileProperty.None))
		XCTAssertFalse(GameTile(color: GameTileColor.Red, property: GameTileProperty.Clockwise) == GameTile(color: GameTileColor.Red, property: GameTileProperty.None))
	}
}