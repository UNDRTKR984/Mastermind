//
//  MasterMindGame.swift
//  MasterMind
//
//  Created by Matt Vogel on 1/11/21.
//  CS3164

import SwiftUI


/// ------------------------------------------------------------------------play with iPhone 11-----------------

/// -----------------------------------------------------VIEWMODEL-----------------------------------------

// MasterMindGame
//   using a class allows multiple tings to access it / communicate through it.  It is used as a communication "liason" between to the view and the model
//      it almost acts like an "interface" for the model and view to interact
class MasterMindGame: ObservableObject {
    //sets up MasterMind Game in the model by using the static function which is currently setting the type as a string
    @Published private var model: MasterMind<String> = MasterMindGame.createMasterMind()
    
    //static function specific to the MasterMindGame it is a function on the type to create the game
    // it serves as a "utility" function to create the game
    static func createMasterMind() -> MasterMind<String> {
        // a bunch of emojis that can be used for the game
        let emojis: Array<String> = ["🏀", "🎱", "⚾️","🏈", "⚽️", "🎾"]
        //returns a MasterMind of type String with 10 rows of Pegs
        return  MasterMind<String>(numberOfRows: 10, choices: emojis) {
            // for each row that is given, set 4 Pegs (initially as peg holes) for possible answers
            item in emojis[item]
        }
    
    }
    
    // MARK: - Access to the Model
    
    // almost serves as a "getter" function to allow the view to see what the pegs are in the model
    // the view accesses this through viewModel.pegs
    var pegs: Array<MasterMind<String>.Peg>{
        model.pegs
    }
    
    // this contains the array of indicators in the model
    var indicators: Array<MasterMind<String>.Indicator>{
        model.indicators
    }
    
    // this contains the array of all the possible selections the user can make in the model
    var selections: Array<MasterMind<String>.PossibleAnswer>{
        model.selections
    }
    
    // this contains the information about which row is active in the model
    var activeRow: Int {
        model.activeRow
    }
    
    // this holds information about if the game has been won in the model
    var wonGame: Bool {
        model.wonGame
    }
    
    // this holds information about if the game has been lost in the model
    var lostGame: Bool {
        model.lostGame
    }
    
    // this holds the answer code that is to be solved
    var answer: Array<String> {
        model.answer
    }
    
    
    // Things the user can do to change the model THROUGH this viewModel
    
    
    // MARK: - Intent(s)
    
    // executes the choose function in the model
    // the view acceses this through viewModel.choose()
    func choose(peg: MasterMind<String>.Peg){
        model.choose(peg: peg)
    }
    
    // set the index in the model
    //  this allows the user to click on each circle to select a guess for a specific emoji they want to use
    func setIndex(index: Int){
        model.setIndex(index: index)
    }
    
    // check
    // a function that helped me check the id of each indicator to help me in my design
    func check(indicator: MasterMind<String>.Indicator){
        model.check(indicator: indicator)
    }
    
    // submit
    // when the user submits an answer
    func submit(){
        model.submit()
    }
    
    // doNothing
    // when the user submits an answer before all 4 guesses are filled
    func doNothing(){
        
    }
    
    // createNew
    // creates a new game no matter where the user is in the game, a new game can be created at any time
    func createNew(){
        model = MasterMindGame.createMasterMind()
    }
    
}
