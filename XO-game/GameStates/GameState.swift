//
//  GameState.swift
//  XO-game
//
//  Created by v.prusakov on 9/7/21.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation
import UIKit

protocol GameState {
    var isCompleted: Bool { get }
    func begin()
    func addMark(at position: GameboardPosition)
}

class PlayerInputGameState: GameState {
    
    var isCompleted: Bool = false
    
    let player: Player
    private unowned let gameViewController: GameViewController
    private let gameboard: Gameboard
    private let gameboardView: GameboardView
    private let markPrototype: MarkView
    private let turnInvoker = TurnInvoker.shared
    
    init(player: Player, markPrototype: MarkView, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView) {
        self.player = player
        self.markPrototype = markPrototype
        self.gameboardView = gameboardView
        self.gameboard = gameboard
        self.gameViewController = gameViewController
    }
    
    func begin() {
        let isFirstPlayer = self.player == .first
        self.gameViewController.firstPlayerTurnLabel.isHidden = !isFirstPlayer
        self.gameViewController.secondPlayerTurnLabel.isHidden = isFirstPlayer
        
        self.gameViewController.winnerLabel.isHidden = true
    }
    
    func addMark(at position: GameboardPosition) {
        guard self.gameboardView.canPlaceMarkView(at: position) else { return }
        
        recordEvent(.turnPlayer(player: self.player, position: position))

        self.gameboard.setPlayer(self.player, at: position)
        self.gameboardView.placeMarkView(markPrototype.copy(), at: position)
        
        turnInvoker.appendCommand(position: position, player: player, gameboard: gameboard, gameboardView: gameboardView)
        
        self.isCompleted = true
    }
}

class ComputerGameState: GameState {
    
    var isCompleted: Bool = false
    
    let player: Player
    private unowned let gameViewController: GameViewController
    private let gameboard: Gameboard
    private let gameboardView: GameboardView
    private let markPrototype: MarkView
    
    init(player: Player, markPrototype: MarkView, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView) {
        self.player = player
        self.markPrototype = markPrototype
        self.gameboardView = gameboardView
        self.gameboard = gameboard
        self.gameViewController = gameViewController
    }
    
    func begin() {
        let isFirstPlayer = self.player == .first
        self.gameViewController.firstPlayerTurnLabel.isHidden = !isFirstPlayer
        self.gameViewController.secondPlayerTurnLabel.isHidden = isFirstPlayer
        
        self.gameViewController.winnerLabel.isHidden = true
    }
    
    func addMark(at position: GameboardPosition) {

        if self.player == .second {
            
            let positionForComputer = Game.positions.first ?? GameboardPosition(column: 3, row: 3)
            
            guard self.gameboardView.canPlaceMarkView(at: positionForComputer) else { return }

            recordEvent(.turnPlayer(player: self.player, position: positionForComputer))

            self.gameboard.setPlayer(self.player, at: positionForComputer)
            self.gameboardView.placeMarkView(markPrototype.copy(), at: positionForComputer)
            
            Game.positions.removeAll(where: { $0 == positionForComputer })
        } else {
            guard self.gameboardView.canPlaceMarkView(at: position) else { return }
            
            recordEvent(.turnPlayer(player: self.player, position: position))
            
            self.gameboard.setPlayer(self.player, at: position)
            self.gameboardView.placeMarkView(markPrototype.copy(), at: position)
            
            Game.positions.removeAll(where: { $0 == position })
        }
        self.isCompleted = true
    }
}

class WinnerGameState: GameState {
    
    var isCompleted: Bool = false
    
    private let winner: Player?
    private unowned let gameViewController: GameViewController?
    
    init(winner: Player?, gameViewController: GameViewController?) {
        self.winner = winner
        self.gameViewController = gameViewController
    }
    
    func begin() {
        self.gameViewController?.winnerLabel.isHidden = false
        
        self.gameViewController?.firstPlayerTurnLabel.isHidden = true
        self.gameViewController?.secondPlayerTurnLabel.isHidden = true
        
        recordEvent(.gameFinished(winner: self.winner))
        
        if let winner = self.winner {
            self.gameViewController?.winnerLabel.text = self.winnerPlayerName(for: winner) + " win"
        } else {
            self.gameViewController?.winnerLabel.text = "No winner"
        }
    }
    
    func addMark(at position: GameboardPosition) { }
    
    private func winnerPlayerName(for winner: Player) -> String {
        switch winner {
        case .first: return "1st player"
        case .second:
            switch Game.shared.gameState {
                case .versusHuman: return "2nd player"
                case .versusComputer: return "Computer"
            }
        }
    }
}

class FiveStepsCountGameState: GameState {
    
    var isCompleted: Bool = false
    
    let player: Player
    private unowned let gameViewController: GameViewController
    private let gameboard: Gameboard
    private let gameboardView: GameboardView
    private let markPrototype: MarkView
    
    init(player: Player, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView, markPrototype: MarkView) {
        self.player = player
        self.gameViewController = gameViewController
        self.gameboard = gameboard
        self.gameboardView = gameboardView
        self.markPrototype = markPrototype
    }
    
    func begin() {
        let isFirstPlayer = self.player == .first
        self.gameViewController.firstPlayerTurnLabel.isHidden = !isFirstPlayer
        self.gameViewController.secondPlayerTurnLabel.isHidden = isFirstPlayer
        
        self.gameViewController.winnerLabel.isHidden = true
    }
    
    func addMark(at position: GameboardPosition) {
        
        guard self.gameboardView.canPlaceMarkView(at: position) else { return }
            
        recordEvent(.turnPlayer(player: self.player, position: position))
            
        self.gameboard.setPlayer(self.player, at: position)
        self.gameboardView.placeMarkView(self.markPrototype.copy(), at: position)

        Game.steps.append(position)
        print(Game.steps)
        self.isCompleted = true
    }
}

class FiveStepsGameRunningState: GameState {
    
    var isCompleted: Bool = false
    
    let player: Player
    private unowned let gameViewController: GameViewController
    private let gameboard: Gameboard
    private let gameboardView: GameboardView
    private let markPrototype: MarkView
    
    init(player: Player, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView, markPrototype: MarkView) {
        self.player = player
        self.gameViewController = gameViewController
        self.gameboard = gameboard
        self.gameboardView = gameboardView
        self.markPrototype = markPrototype
    }
    
    func begin() {
        let isFirstPlayer = self.player == .first
        self.gameViewController.firstPlayerTurnLabel.isHidden = !isFirstPlayer
        self.gameViewController.secondPlayerTurnLabel.isHidden = isFirstPlayer
        
        self.gameViewController.winnerLabel.isHidden = true
    }
    
    func addMark(at position: GameboardPosition) {
        let steps = Game.steps
    
        UIView.animateKeyframes(
            withDuration: 1,
            delay: 0,
            options: .calculationModeLinear,
            animations: {
                switch self.player {
                case .first:
                    self.placeMarkIfNeeded(at: steps[0])
                    self.placeMarkIfNeeded(at: steps[1])
                    self.placeMarkIfNeeded(at: steps[2])
                    self.placeMarkIfNeeded(at: steps[3])
                    self.placeMarkIfNeeded(at: steps[4])
                case .second:
                    self.placeMarkIfNeeded(at: steps[5])
                    self.placeMarkIfNeeded(at: steps[6])
                    self.placeMarkIfNeeded(at: steps[7])
                    self.placeMarkIfNeeded(at: steps[8])
                    self.placeMarkIfNeeded(at: steps[9])
                }
            },
            completion: { _ in
                self.gameViewController.showFiveSteps(player: Player.second, markPrototype: Player.second.markViewPrototype)
                self.gameViewController.indexToDetermineWinner += 1
                if self.gameViewController.indexToDetermineWinner == 2 {
                    if let winner = self.gameViewController.referee.determineWinner() {
                        self.gameViewController.currentState = WinnerGameState(winner: winner, gameViewController: self.gameViewController)
                        return
                    }
                }
            })
        self.isCompleted = true
    }
    
    private func placeMarkIfNeeded(at position: GameboardPosition) {
        if self.gameboard.contains(player: self.player.next, at: position) {
            self.gameboardView.removeMarkView(at: position)
            self.gameboard.setPlayer(self.player, at: position)
            self.gameboardView.placeMarkView(self.markPrototype.copy(), at: position)
        } else {
            guard self.gameboardView.canPlaceMarkView(at: position) else { return }
            recordEvent(.turnPlayer(player: self.player, position: position))
            self.gameboard.setPlayer(self.player, at: position)
            self.gameboardView.placeMarkView(self.markPrototype.copy(), at: position)
        }
    }
}
