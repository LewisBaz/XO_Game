//
//  TurnCommands.swift
//  XO-game
//
//  Created by Lev Bazhkov on 13.09.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

protocol Command {
    func execute()
}

class XViewPlayerTurn: Command {
    
    weak var gameboard: Gameboard?
    weak var gameboardView: GameboardView?
    var player = Player.first
    var position: GameboardPosition?
    var markView = XView()
    
    func execute() {
        recordEvent(.turnPlayer(player: player, position: position ?? GameboardPosition(column: 3, row: 3)))
        self.gameboard?.setPlayer(player, at: position ?? GameboardPosition(column: 3, row: 3))
        self.gameboardView?.placeMarkView(markView, at: position ?? GameboardPosition(column: 3, row: 3))
        print("x trun")
    }
}

class OViewPlayerTurn: Command {
    
    weak var gameboard: Gameboard?
    weak var gameboardView: GameboardView?
    var player = Player.second
    var position: GameboardPosition?
    var markView = OView()
    
    func execute() {
        recordEvent(.turnPlayer(player: player, position: position ?? GameboardPosition(column: 3, row: 3)))
        self.gameboard?.setPlayer(player, at: position ?? GameboardPosition(column: 3, row: 3))
        self.gameboardView?.placeMarkView(markView, at: position ?? GameboardPosition(column: 3, row: 3))
        print("o trun")
    }
}
