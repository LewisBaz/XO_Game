//
//  Game.swift
//  XO-game
//
//  Created by Lev Bazhkov on 10.09.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

final class Game {
    
    private init() {}
    
    static let shared = Game()

    var gameState = GameType.versusHuman
    var gameSteps = StepsCount.oneByOne
    
    static var positions: [GameboardPosition] = [GameboardPosition(column: 0, row: 0), GameboardPosition(column: 0, row: 1), GameboardPosition(column: 0, row: 2), GameboardPosition(column: 1, row: 0), GameboardPosition(column: 1, row: 1), GameboardPosition(column: 1, row: 2), GameboardPosition(column: 2, row: 0), GameboardPosition(column: 2, row: 1), GameboardPosition(column: 2, row: 2)].shuffled()
    
    static var steps: [GameboardPosition] = []
}

enum GameType: Int {
    case versusHuman, versusComputer
}

enum StepsCount: Int {
    case oneByOne, fiveByOne
}
