//
//  StartViewController.swift
//  XO-game
//
//  Created by Lev Bazhkov on 09.09.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var switchGameTypeLabel: UILabel!
    @IBOutlet weak var switchStepsCountLabel: UILabel!
    @IBOutlet weak var switchGameTypeControlLabel: UISegmentedControl!
    @IBAction func switchGameTypeControl(_ sender: UISegmentedControl) {
        guard let selectedGameType = GameType(rawValue: sender.selectedSegmentIndex) else { return }
        Game.shared.gameState = selectedGameType
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "chosenGameTypeStateIndex")
    }
    
    @IBOutlet weak var switchStepsCountControlLabel: UISegmentedControl!
    @IBAction func switchStepsCountControl(_ sender: UISegmentedControl) {
        guard let selectedStepsCount = StepsCount(rawValue: sender.selectedSegmentIndex) else { return }
        Game.shared.gameSteps = selectedStepsCount
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "chosenGameStepsStateIndex")
    }
    
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let value = UserDefaults.standard.value(forKey: "chosenGameTypeStateIndex") {
            let selectedIndex = value as! Int
            switchGameTypeControlLabel.selectedSegmentIndex = selectedIndex
        }
        if let value = UserDefaults.standard.value(forKey: "chosenGameStepsStateIndex") {
            let selectedIndex = value as! Int
            switchStepsCountControlLabel.selectedSegmentIndex = selectedIndex
        }
    }
}
