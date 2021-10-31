//
//  GameViewController.swift
//  XO-game
//
//  Created by Evgeny Kireev on 25/02/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet var gameboardView: GameboardView!
    @IBOutlet var firstPlayerTurnLabel: UILabel!
    @IBOutlet var secondPlayerTurnLabel: UILabel!
    @IBOutlet var winnerLabel: UILabel!
    @IBOutlet var restartButton: UIButton!
    
    lazy var referee = Referee(gameboard: self.gameboard)
    private var gameboard = Gameboard()
    var currentState: GameState! {
        didSet {
            self.currentState.begin()
        }
    }
    
    private let turnInvoker = TurnInvoker.shared
    private var gameState = Game.shared.gameState
    private var gameSteps = Game.shared.gameSteps
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch gameState {
        case .versusHuman:
            switch gameSteps {
            case .oneByOne: self.goToFirstState()
            case .fiveByOne: self.goToFiveCountStepState()
            }
        case .versusComputer:
            self.goToComputerState()
            self.secondPlayerTurnLabel.text = "Computer"
        }
        
        gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            self.currentState.addMark(at: position)
            
            if self.currentState.isCompleted {
                self.goToNextState()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        self.gameboardView.clear()
        self.gameboard.clear()
        switch gameState {
        case .versusHuman:
            switch gameSteps {
            case .oneByOne: self.goToFirstState()
            case .fiveByOne: self.goToFiveCountStepState()
            }
        case .versusComputer: self.goToComputerState()
        }
        self.counter = 0
        Game.positions = [GameboardPosition(column: 0, row: 0), GameboardPosition(column: 0, row: 1), GameboardPosition(column: 0, row: 2), GameboardPosition(column: 1, row: 0), GameboardPosition(column: 1, row: 1), GameboardPosition(column: 1, row: 2), GameboardPosition(column: 2, row: 0), GameboardPosition(column: 2, row: 1), GameboardPosition(column: 2, row: 2)].shuffled()
        Game.steps.removeAll()
        recordEvent(.restartGame)
    }
    
    // MARK: - Game state
    
    private func goToFirstState() {
        let player = Player.first
        
        self.currentState = PlayerInputGameState(
            player: player,
            markPrototype: player.markViewPrototype,
            gameViewController: self,
            gameboard: self.gameboard,
            gameboardView: self.gameboardView
        )
    }
    
    private func goToComputerState() {
        let player = Player.first
        
        self.currentState = ComputerGameState(
            player: player,
            markPrototype: player.markViewPrototype,
            gameViewController: self,
            gameboard: self.gameboard,
            gameboardView: self.gameboardView
        )
    }
    
    private func goToFiveCountStepState() {
        let player = Player.first
        
        self.currentState = FiveStepsCountGameState(
            player: player,
            gameViewController: self,
            gameboard: self.gameboard,
            gameboardView: self.gameboardView,
            markPrototype: player.markViewPrototype
        )
    }
    
    private func goToNextState() {
        switch gameState {
        case .versusHuman:
            switch gameSteps {
            case .oneByOne:
                if let winner = self.referee.determineWinner() {
                    self.gameboard.clear()
                    self.gameboardView.clear()
                    self.turnInvoker.work()
                    self.currentState = WinnerGameState(winner: winner, gameViewController: self)
                    return
                }
                
                if let playerInputState = self.currentState as? PlayerInputGameState {
                    let nextPlayer = playerInputState.player.next
                    self.currentState = PlayerInputGameState(
                        player: nextPlayer,
                        markPrototype: nextPlayer.markViewPrototype,
                        gameViewController: self,
                        gameboard: self.gameboard,
                        gameboardView: self.gameboardView
                    )
                }
            case .fiveByOne:
                if counter <= 3 {
                    if (self.currentState as? FiveStepsCountGameState) != nil {
                        let nextPlayer = Player.first
                        self.currentState = FiveStepsCountGameState(
                            player: nextPlayer,
                            gameViewController: self,
                            gameboard: self.gameboard,
                            gameboardView: self.gameboardView,
                            markPrototype: nextPlayer.markViewPrototype
                        )
                        counter += 1
                    }
                } else if counter >= 3 {
                    if counter == 4 {
                        self.gameboard.clear()
                        self.gameboardView.clear()
                    }
                    if (self.currentState as? FiveStepsCountGameState) != nil {
                        let nextPlayer = Player.second
                        self.currentState = FiveStepsCountGameState(
                            player: nextPlayer,
                            gameViewController: self,
                            gameboard: self.gameboard,
                            gameboardView: self.gameboardView,
                            markPrototype: nextPlayer.markViewPrototype
                        )
                        counter += 1
                        if counter == 10 {
                            self.gameboard.clear()
                            self.gameboardView.clear()
                            self.showFiveStepsForXView()
                        }
                    }
                }
            }
        case .versusComputer:
            if let winner = self.referee.determineWinner() {
                self.currentState = WinnerGameState(winner: winner, gameViewController: self)
                return
            }
            
            if let computerGameState = self.currentState as? ComputerGameState {
                let nextPlayer = computerGameState.player.next
                self.currentState = ComputerGameState(
                    player: nextPlayer,
                    markPrototype: nextPlayer.markViewPrototype,
                    gameViewController: self,
                    gameboard: self.gameboard,
                    gameboardView: self.gameboardView
                )
            }
        }
    }
    
    func showFiveStepsForXView() {
            self.currentState = FiveStepsGameRunningStateForXView(
                player: Player.first,
                gameViewController: self,
                gameboard: self.gameboard,
                gameboardView: self.gameboardView,
                markPrototype: Player.first.markViewPrototype
            )
    }
    
    func showFiveStepsForOView() {
            self.currentState = FiveStepsGameRunningStateForOView(
                player: Player.second,
                gameViewController: self,
                gameboard: self.gameboard,
                gameboardView: self.gameboardView,
                markPrototype: Player.second.markViewPrototype
            )
    }
}

