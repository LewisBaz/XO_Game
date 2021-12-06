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

class PlayerTurn: Command {
    
    weak var gameboard: Gameboard?
    weak var gameboardView: GameboardView?
    var position: GameboardPosition?
    var player: Player?
    var markView: MarkView = XView()
    
    init(player: Player, position: GameboardPosition, gameboard: Gameboard, gameboardView: GameboardView) {
        self.player = player
        self.position = position
        self.gameboard = gameboard
        self.gameboardView = gameboardView
    }
    
    func execute() {
        switch player {
        case .first: markView = XView()
        case .second: markView = OView()
        case .none:
            return
        }
        
        guard (((self.gameboardView?.canPlaceMarkView(at: position!))) != nil) else { return }
        recordEvent(.turnPlayer(player: player ?? Player.first, position: position ?? GameboardPosition(column: 3, row: 3)))
        self.gameboard?.setPlayer(player ?? Player.first, at: position ?? GameboardPosition(column: 3, row: 3))
        self.gameboardView?.placeMarkView(markView, at: position ?? GameboardPosition(column: 3, row: 3))
    }
}
