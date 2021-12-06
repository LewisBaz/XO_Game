//
//  TurnInvoker.swift
//  XO-game
//
//  Created by Lev Bazhkov on 13.09.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

class TurnInvoker {
    
    static let shared = TurnInvoker()
    
    private init() {}
    
    private var gameboard: Gameboard = Gameboard()
    private var gameboardView: GameboardView = GameboardView()
    var commands: [Command] = []
    
    func work() {
        self.commands.forEach({ $0.execute() })
    }
    
    func appendCommand(position: GameboardPosition, player: Player, gameboard: Gameboard, gameboardView: GameboardView) {
        let turn = PlayerTurn(player: player, position: position, gameboard: gameboard, gameboardView: gameboardView)
        commands.append(turn)
    }
}
