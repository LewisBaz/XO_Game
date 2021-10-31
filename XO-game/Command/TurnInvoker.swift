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
    private let xViewPlayerTurn = XViewPlayerTurn()
    private let oViewPlayerTurn = OViewPlayerTurn()
    
    func work() {
//        self.gameboard.clear()
//        self.gameboardView.clear()
        self.commands.forEach({ $0.execute() })
    }
    
    func appendCommandX(position: GameboardPosition) {
        let turn = XViewPlayerTurn()
        turn.gameboard = self.gameboard
        turn.gameboardView = self.gameboardView
        turn.position = position
        commands.append(turn)
    }
    func appendCommandO(position: GameboardPosition) {
        let turn = OViewPlayerTurn()
        turn.gameboard = self.gameboard
        turn.gameboardView = self.gameboardView
        turn.position = position
        commands.append(turn)
    }
}
