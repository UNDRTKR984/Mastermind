//
//  MasterMindModel.swift
//  MasterMind
//
//  Created by Matt Vogel on 1/11/21.
//  CS3164

import Foundation

///______________________________Play with iPhone 11---------------------
///---------------------------MODEL-----------------------------------------------------------------------

// this is a structure that has all the information/logic related to the MemoryGame
struct MasterMind<PegContent:Equatable> {
    //the variable pegs will be (or behave as) an array of Pegs
    //  these are the answer slots, with 4 in each row
    var pegs: Array<Peg>
    
    //the indicators for helping the user to determine how correct their guess is
    var indicators: Array<Indicator>
    
    //the possible selections in the game
    var selections: Array<PossibleAnswer>
    
    //the possible content that each Peg could hold
    var possibilities: Array<PegContent>
    
    //this will hold the answer or the code to be solved!
    var answer: Array<PegContent>
    
    //Set the index of the emoji to change each Peg to it when tapped
    var choosingIndex: Int
    
    //Identify the active row
    var activeRow: Int
    
    //Determine if game is won
    var wonGame: Bool
    
    //Determine if game is lost
    var lostGame: Bool
    
    // the init function
    //      works as a constructor for the MasterMind Game
    init(numberOfRows: Int, choices: Array<PegContent>, cardContentFactory: (Int) -> PegContent){
        // initialize the cards array to be an empty array of Peg structures
        pegs = Array<Peg>()
        // initialize the indicators array to be an empty array of Indicator structure
        indicators = Array<Indicator>()
        // initialize the selections array to be an empty array of Possible Answers
        selections = Array<PossibleAnswer>()
        // initializie the possibilities array to be an empty array of whatever PegContent is
        possibilities = Array<PegContent>()
        // initialize the answer array to be an empty array of whatever PegCondent is
        answer = Array<PegContent>()
        // for each number of item that are given, append four pegs and four indicators to their arrays (which will be a row)
        for item in 0..<numberOfRows {
            let content = cardContentFactory(0)
            //append the Cards by calling the append function on the array
            pegs.append(Peg(content: content, id: item*4))
            pegs.append(Peg(content: content, id: item*4+1))
            pegs.append(Peg(content: content, id: item*4+2))
            pegs.append(Peg(content: content, id: item*4+3))
            
            //load the indicators
            indicators.append(Indicator(id: item*4))
            indicators.append(Indicator(id: item*4+1))
            indicators.append(Indicator(id: item*4+2))
            indicators.append(Indicator(id: item*4+3))
        }
        // append all the possible answers and selections
        // set the first PossibleAnswer to be active
        for index in 0..<6 {
            possibilities.append(choices[index])
            if (index == 0){
                selections.append(PossibleAnswer(id: index, content: choices[index], active: true))
            }
            else{
                selections.append(PossibleAnswer(id: index, content: choices[index]))
            }
        }
        
        // initialize secret answer
        //      it uses the Int.random function to randomly select an item in each slot
        for _ in 0..<4 {
            answer.append(choices[Int.random(in: 0..<6)])
        }
        
        // set the choosingIndex to zero
        choosingIndex = 0
        
        // set the active row (bottom row on the view)
        activeRow = 9
        
        // set the wonGame to false
        wonGame = false
        
        // set the lostGame to false
        lostGame = false
        
    }
    
    
    //Set the index of the emoji array so that it will change a peg's content when it is clicked to the item in that index
    //      set the selection that is active to true
    mutating func setIndex(index: Int){
        choosingIndex = index
        for index in 0..<selections.count {
            if selections[index].id == choosingIndex {
                selections[index].active = true
            }
            else {
                selections[index].active = false
            }
        }
    }
    
    //this executes when a user clicks on a peg -- each peg has an "event" listener on it in the view where it triggers the viewModel to execute this in this model
    //  when the user clicks on a peg it calls a function in the viewModel, which then calls this function.  It passes in the particular peg structure that was chosen and sets the contentIndex on the peg to have its content match a particular
    //  element of possible choices
    mutating func choose(peg: Peg) {
        
        if !pegs[peg.id].filled {
            pegs[peg.id].filled = true
        }
        
        // if the game is already won or lost, dont allow any more changes
        if !wonGame && !lostGame {
            pegs[peg.id].contentIndex = choosingIndex
            pegs[peg.id].content = possibilities[pegs[peg.id].contentIndex]
            pegs[peg.id].toggle = !pegs[peg.id].toggle
        }
        
        //uncomment for debugging
        //print("peg chosen: \(peg)")
    }
    
    // check
    //      this function helps debugging to figure out which indicator is which
    mutating func check(indicator: Indicator) {
        //uncommment for debugging
        //print("indicator: \(indicator)")
    }
    
    
    // submit
    //      this executes when the user submits a guess
    //      this compares the guess with the answer (code to be solved) and sets the correspending indicator pegs for feedback
    //      it also shuffles the order of the pegs so that the user cannot detect a pattern
    mutating func submit(){
        
        // set the submitted answer
        let answerSubmitted : Array<PegContent> = [pegs[activeRow*4].content, pegs[activeRow*4+1].content, pegs[activeRow*4+2].content, pegs[activeRow*4+3].content]
        
        // this is to let us know which items in the guess and in the answer get matched up as we color the indicator pegs
        var guessMatches: Array<Bool> = [false, false, false, false]
        var answerMatches: Array<Bool> = [false, false, false, false]
        
        // set the red pegs
        for index in 0..<4 {
            if answerSubmitted[index] == answer[index]{
                indicators[activeRow*4+index].feedback = 2
                indicators[activeRow*4+index].matched = true
                guessMatches[index] = true
                answerMatches[index] = true
            }
        }
           
        // set the white pegs
        for index in 0..<4 {
            // if the guess is already matched at the index skip and continue with the loop
            if guessMatches[index]{
                continue
            }
            // if the guess is not already matched, see if you can find a match elsewhere in the answer
            else {
                // loop through the answers and see if it matches
                for item in 0..<4 {
                    // if the answers match check to see if the current item in the answer has already been matched
                    if answerSubmitted[index]  == answer[item]{
                        // if so, continue the loop to look at the next item in the answer
                        if answerMatches[item]{
                            continue
                        }
                        // if it hasn't been matched, then set a white peg and set the index of the guess and answer to true, break the loop since a match has been found (we don't want duplicates)
                        else {
                            indicators[activeRow*4+item].feedback = 1
                            indicators[activeRow*4+item].matched = true
                            guessMatches[index] = true
                            answerMatches[item] = true
                            break
                        }
                    }
                }
            }
        }
        
        // shuffle the indicator pegs so it's not always predictable to the user
        // get the pegs into a temporary array
        var tempArray : Array<Indicator> = Array<Indicator>()
        for index in 0..<4 {
            tempArray.append(indicators[activeRow*4+index])
        }
        
        // shuffle the temporary array
        tempArray.shuffle()
        
        // load the shuffled pegs back into the indicator array
        for index in 0..<4 {
            indicators[activeRow*4+index] = tempArray[index]
        }
        
        // check if user won the game
        if !wonGame {
            //uncomment for debugging
            //print(answerSubmitted)
            print("Correct Answer \(answer)")
            if answerSubmitted == answer {
                print("You Win!")
                wonGame = true
                return
            }
          
        
        // set the next playing row if still here
        activeRow -= 1
          
        // if all the choices have been used the game is lost
        if activeRow < 0 {
            lostGame = true
        }
        //uncomment for debugging to determine which row is active
        //print("Active Row: \(activeRow)")
        }
    }
    
    
    //Peg Structure
    //      provides the logic and variables for each peg
    //      Identifiable allows each ped structure to be unique from the others.  Each peg can be "identified"
    struct Peg: Identifiable {
        // variable to determine if the peg is face up or not
        var filled: Bool = false
        // variable to be toggled on and off
        var toggle: Bool = false
        // variable to determine if the peg has been matched with another peg
        var isMatched: Bool = false
        // variable to hold content of the peg
        var content: PegContent
        // the id is needed so that each peg is identifiable or unique
        var id: Int
        // used to determine which content to show
        var contentIndex: Int = 0
    }
    
    //Indicator Structure
    //      provides the user how close their answer is
    //      indentifiable
    struct Indicator: Identifiable {
        var feedback: Int = 0
        var matched: Bool = false
        var id: Int
    }
    
    //Possible Answers
    //      this holds the content of all the possible answers in the game
    struct PossibleAnswer: Identifiable {
        var id: Int
        var content: PegContent
        var active: Bool = false
    }
    
    
}
