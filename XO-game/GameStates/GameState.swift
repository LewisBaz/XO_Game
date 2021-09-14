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
        
        switch player {
        case .first: turnInvoker.appendCommandX(position: position)
        case .second: turnInvoker.appendCommandO(position: position)
        }
        
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

class FiveStepsGameRunningStateForXView: GameState {
    
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
                self.checkPositions(steps: steps[0])
                self.checkPositions(steps: steps[1])
                self.checkPositions(steps: steps[2])
                self.checkPositions(steps: steps[3])
                self.checkPositions(steps: steps[4])
            },
            completion: { _ in
                self.gameViewController.showFiveStepsForOView()
            })
        self.isCompleted = true
    }
    
    private func checkPositions(steps: GameboardPosition) {
        guard self.gameboardView.canPlaceMarkView(at: steps) else { return }
        recordEvent(.turnPlayer(player: self.player, position: steps))
        self.gameboard.setPlayer(self.player, at: steps)
        self.gameboardView.placeMarkView(self.markPrototype.copy(), at: steps)
    }
}

class FiveStepsGameRunningStateForOView: GameState {
    
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
                self.checkPositions(steps: steps[5])
                self.checkPositions(steps: steps[6])
                self.checkPositions(steps: steps[7])
                self.checkPositions(steps: steps[8])
                self.checkPositions(steps: steps[9])
            }, completion: {_ in
                if let winner = self.gameViewController.referee.determineWinner() {
                    self.gameViewController.currentState = WinnerGameState(winner: winner, gameViewController: self.gameViewController)
                    return
                }
            })
        self.isCompleted = true
    }
    
    private func checkPositions(steps: GameboardPosition) {
        if self.gameboard.contains(player: self.player.next, at: steps) {
            self.gameboardView.removeMarkView(at: steps)
            self.gameboard.setPlayer(self.player, at: steps)
            self.gameboardView.placeMarkView(self.markPrototype.copy(), at: steps)
        } else {
            guard self.gameboardView.canPlaceMarkView(at: steps) else { return }
            recordEvent(.turnPlayer(player: self.player, position: steps))
            self.gameboard.setPlayer(self.player, at: steps)
            self.gameboardView.placeMarkView(self.markPrototype.copy(), at: steps)
        }
    }
}

