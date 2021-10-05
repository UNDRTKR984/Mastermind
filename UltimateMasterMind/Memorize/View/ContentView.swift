//
//  ContentView.swift
//  MasterMind
//
//  Created by Matt Vogel on 1/11/21.
//  CS3164

import SwiftUI

/// -----------------------------------------------------------Play with iPhone 11----------------
///-------------------------------------------- VIEW-------------------------------------------------------

// the main view that the user sees ("the screen as a whole")
struct ContentView: View {
    
    // the viewModel (name) is going to behave like a MasterMindGame
    // OberservedObject is used so that the view will react whenever there is a change detected in the viewModel
    @ObservedObject var viewModel: MasterMindGame
    
    // required for the View -- it needs a body which can be a combination of a bunch of views
    
    var body: some View {
        GeometryReader { geometry in
        //  VStack allows things to stack up vertically as they are added to the this Combiner View
        VStack{
            Spacer().frame(height: geometry.size.height * spacerSize)
            // Game Instructions and Title
            //TitleSect
            //      Takes the viewModel as a parameter
            //      Displays the title and instructional information for the game
            TitleSect(viewModel: viewModel)
            // ForEach set of 4 peg, place a row
            // ForEach -- takes an iterable and allows things to be done to each item in the iterable thing
            ForEach(viewModel.pegs) { peg in
                if(peg.id % numPegsInRow == 0){
                    //Row
                    //  Row contains the 4 pegs and also contains the Indicators
                    Row(viewModel: viewModel, peg: peg, id: peg.id/numPegsInRow, numPegsInRow: numPegsInRow)
                }
            }
            // spacer adds some space between items in a view.  In this case, it spaces the answer pegs from indicator pegs and submit button
            Spacer().frame(height: geometry.size.height * spacerSize)
            //HStack
            //  Allows you to place things side by side in this Combiner View
            HStack{
                // ForEach possible answer create a Possibility
                //      these are used for the user to click on and set their pegs for a guess
                // Also contains submission button for the answer.  If all 4 guesses are not filled out it executes a do nothing function
                ForEach(viewModel.selections) { possibility in
                    Possibility(viewModel: viewModel, possible: possibility)
                        .scaleEffect(possibility.active ? scalingFactor : 1)   // learned how to do scaleEffect through Apple documentation
                        .rotation3DEffect(Angle.degrees(possibility.active ? degreeOfRotation : 0), axis: (x: 0, y: 1, z: 0))
                        .animation(Animation.linear(duration: possibility.active ? animationDuration : 0))     // learned how to time the animation through Apple documentation
                }
            }
            Spacer().frame(height: geometry.size.height * spacerSize)  // learned geometry reader from Stanford Professor
        
        }
        
    }
        // the image I got from an open source file from the App Brewery
        // figured out how to insert an image here: https://www.simpleswiftguide.com/how-to-add-image-to-xcode-project-in-swiftui/
        .background(
            ZStack{
                Image("background_2").colorMultiply(.init(red: 0.8, green: 0.8, blue: 0.8))
                Background()  // implemented by watching https://www.youtube.com/watch?v=FQfeJGA7P9w
            }
        ).ignoresSafeArea() // extends to the entire screen
        
            
    }
    
    // Formatting Constants
    let spacerSize: CGFloat = 0.05
    let numPegsInRow: Int = 4
    
    // Animation Constants
    let scalingFactor: CGFloat = 1.1
    let degreeOfRotation: Double = 360
    let animationDuration: Double = 0.1
            
}



// TitleSect
//      this displays all of the information to user on the screen including:
//      Game directions, number of guesses left, whether the game is won or lost, and displays the correct code at the end of the       game
//      also gives the user the option to start a new game at any time
struct TitleSect: View {
    @ObservedObject var viewModel:MasterMindGame // the viewModel
    
    var body: some View {
        HStack{
            Text("Guesses Left: \(viewModel.activeRow+1)")  // Keeps track of how many guesses are left
            Spacer().frame(width: spacerWidth)  // spacing
            Button(action: viewModel.createNew) {           // Button to create a new game
                Text("New Game")
            }
        }
        VStack{
        // if came is not lost or won, it displays "MasterMind", otherwise shows the user if they won or lost
            Text(viewModel.lostGame ? "You Lost!" : viewModel.wonGame ? "You Won!!" : "MasterMind").font(!viewModel.lostGame && !viewModel.wonGame ? .system(size: titleSize) : .system(size: wonLostSize)).italic().underline().bold()
            
        // uncomment code for game directions
         //Text(viewModel.activeRow == 9 ? "Tap to select your choice at the bottom and then tap the black circles until you have your guess.  Then click the check box when ready" : !viewModel.wonGame && !viewModel.lostGame ? "Continue with another guess" : "")
            
        // displays correct code after game is over, it shows up (animation) 1 second after game ends
        // learned animation settings from Apple Developer Documentation
            Text(viewModel.wonGame || viewModel.lostGame ? "Correct code: \(viewModel.answer[0])\(viewModel.answer[1])\(viewModel.answer[2])\(viewModel.answer[3])" : "").font(.system(size: codeSize))
            .animation(Animation.linear(duration: animationDuration).delay(animationDelay))  // displays the answer shortly after (delay)
        }
    }
    //Animation Constants
    let animationDuration:Double = 0.01
    let animationDelay:Double = 1
    
    //Display Constants
    let spacerWidth:CGFloat = 150
    let titleSize:CGFloat = 40
    let wonLostSize:CGFloat = 30
    let codeSize:CGFloat = 25
}

// view for a row of possible guesses
//  this holds the 4 pegs(peg holes) and the scoreView section that contains the check box or the indicator pegs
//  once a guess fills up all 4 cards, then a border of green is placed around the row to indicate it is safe to submit
//  if the row is not active or has not already been played, it will not display on the screen
struct Row: View {
    @ObservedObject var viewModel: MasterMindGame
    var peg: MasterMind<String>.Peg  // peg structure
    var id: Int                     // peg id
    var numPegsInRow: Int
    
    var body: some View {
            HStack{
                ForEach(0..<numPegsInRow){ number in
                    PegView(peg: viewModel.pegs[peg.id+number], viewModel: viewModel).onTapGesture {
                        if viewModel.activeRow == id {
                            viewModel.choose(peg: viewModel.pegs[peg.id+number])
                            //uncomment for debugging
                            //print("Row id: \(id)")
                        }
                    }
                }
                Divider() // creates a vertical line between the pegs and the submit / score section
                ScoreView(viewModel: viewModel, number: peg.id) // holds the guess button and the indicators after guess is selected
            }
            //add border and change to green if all 4 are selected // also adds more width if all 4 are selected
            .border(viewModel.activeRow == id && viewModel.pegs[peg.id].filled && viewModel.pegs[peg.id+1].filled && viewModel.pegs[peg.id+2].filled && viewModel.pegs[peg.id+3].filled ? Color.green : Color.black, width: (viewModel.activeRow == id && viewModel.pegs[peg.id].filled && viewModel.pegs[peg.id+1].filled && viewModel.pegs[peg.id+2].filled && viewModel.pegs[peg.id+3].filled) ? activeBorderWidth : 1)
            //hide the row if it isn't active yet
            .opacity(viewModel.activeRow <= id ? 1 : 0)
            
    }
    
    //Drawing Constants
    var activeBorderWidth: CGFloat = 2.5
}

// Possibility
//      a possible answer that can be selected and used as a guess
//      it gets its info from the selections array in the viewModel that holds a bunch of possibleAnswers
struct Possibility: View {
    @ObservedObject var viewModel: MasterMindGame
    var possible: MasterMind<String>.PossibleAnswer
    
    var body: some View {
        ZStack{
            
            // this fills the entire possibility with a white
            Circle().fill(Color.white)
            // if this possibility is active, set it's outline color to orange with linewidth 6
            if possible.active{
                Circle().stroke(lineWidth: activeOutlineSize).foregroundColor(Color.orange)
            }
            // otherwise just keep it at it's default color with linewidth 2
            else {
            Circle().stroke(lineWidth: inActiveOutlineSize)
            }
            //set the text or content of the possibility to what is contained in this structure's content
            Text(possible.content).font(.largeTitle)
        }.onTapGesture{
            viewModel.setIndex(index: possible.id)
        }
    }
    
    //Drawing Constants
    let activeOutlineSize: CGFloat = 6.0
    let inActiveOutlineSize: CGFloat = 2.0
}

//  PegView
//      This shows a single Peg in a row of Pegs, the user will set this peg to a particular piece of content before
//       submitting their answer
struct PegView: View {
    // a variable named card will take on the characteristics of, or behave like a card in the MemoryGame
    var peg: MasterMind<String>.Peg
    @ObservedObject var viewModel: MasterMindGame
    
    // the body which is needed for any View
    var body: some View {
        // A Zstack is a bunch of views "stacked" on top of each other.  Things listed first get put on the "bottom" while things listed last get put on "top"
        // found the opacity settings through Apple Documentation
        ZStack{
            // if the peg is filled up it will show with the emoji inside of it
            if peg.filled {
                // this fills the entire peg with a white
                Circle().fill(Color.white).opacity(filledOpacity)
                // creates a visible border around each peg with a lineWidth of 3
                Circle().stroke(lineWidth: outlineSize)
                //set the text or content of the peg to what is contained in this structure's content
                Text(peg.content)
                    .font(.largeTitle)
            }
            // if the peg is not filled we show the circle as black peg to signify that there is no guess there yet
            else {
                Circle().fill(Color.black).opacity(notFilledOpacity)    // black with some opacity
                Circle().stroke(lineWidth: outlineSize).opacity(notFilledOutlineOpacity)     // outline with some opacity
                Circle().fill(Color.white).frame(height: miniCircleHeight).opacity(miniCircleOpacity)  // middle circle on the inside with some opacity
            }
        }.rotation3DEffect(Angle.degrees(peg.toggle ? degreesOfRotation : 0), axis: (x: 0, y: 1, z: 0))  // if the peg is toggled "aka clicked" it rotates 360 degrees
        .animation(Animation.linear(duration: (viewModel.wonGame || viewModel.lostGame ? 0 : animationDuration)))  // if the game is won it animates instantly to make more responsive
        .padding(paddingSize)  // adds padding around it
        
    }
    
    //Drawing Constants
    let filledOpacity:Double = 0.6
    let notFilledOpacity:Double = 0.5
    let notFilledOutlineOpacity:Double = 0.8
    let miniCircleHeight:CGFloat = 10
    let miniCircleOpacity:Double = 0.2
    let outlineSize:CGFloat = 2
    let paddingSize:CGFloat = 1
    
    //Animation Constants
    let animationDuration: Double = 0.15
    let degreesOfRotation: Double = 360
}

// the view for each indicator section
//  this is the view for the entire indicator section
//      if the user is on this row the ScoreView will display a check box until the user submits an answer
//      once the answer is submitted, the ScoreView shows the indicator pegs
struct ScoreView : View {
    @ObservedObject var viewModel: MasterMindGame
    var number: Int
    var body: some View {
        // checkbox
        //      got the checkbox from open source file in the App Brewery -- I then modified it myself to make it green
        //      this shows before the answer is submitted
        //      learned how to size the image from StackOverflow
        //      https://stackoverflow.com/questions/56505692/how-to-resize-image-with-swiftui        //
        if (viewModel.activeRow == number/4 && !viewModel.wonGame && !viewModel.lostGame){
            Button(action: allActiveInRow(viewModel: viewModel) ? viewModel.submit : viewModel.doNothing ) {
                Image(allActiveInRow(viewModel: viewModel) ? "CheckFlipped" : "GrayCheck")
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonWidth)
                    .rotation3DEffect(Angle.degrees(allActiveInRow(viewModel: viewModel) ? degreesOfRotation : 0), axis: (x: 1, y: 0, z: 0))
                    .animation((Animation.linear(duration: animationDuration)))
            }
        }
        // indicator pegs
        //      shows after an answer is submitted and the row is no longer active
        else{
            Group{    // group together 2 VStacks that each have a 2 indicators in each one
                VStack {
                    IndicatorView(indicator: viewModel.indicators[number]).onTapGesture {
                        viewModel.check(indicator: viewModel.indicators[number])
                    }
                    IndicatorView(indicator: viewModel.indicators[number+1]).onTapGesture {
                        viewModel.check(indicator: viewModel.indicators[number+1])
                    }
                        
                }
                Spacer().frame(width:spacerWidth)  // adds some lateral space between the VStacks
                VStack {
                    IndicatorView(indicator: viewModel.indicators[number+2]).onTapGesture {
                        viewModel.check(indicator: viewModel.indicators[number+2])
                    }
                    IndicatorView(indicator: viewModel.indicators[number+3]).onTapGesture {
                        viewModel.check(indicator: viewModel.indicators[number+3])
                    }
                }
            }
        }
        Spacer()
    }
        
    // Sizing Constants
    let buttonWidth:CGFloat = 47
    let spacerWidth:CGFloat = 15
    
    // Animation Constants
    let degreesOfRotation: Double = 180
    let animationDuration: Double = 0.2
}

// the view for each peg indicator in a score section
//  it's var contains a particular indicator information from the viewModel that gets the info from the model
//  if the indicator feedback is 0 it remains black, if 1 it turns white, and if 2 it turns red
struct IndicatorView: View {
    var indicator: MasterMind<String>.Indicator
        
    var body: some View {
        ZStack{
            if indicator.feedback == black {
                Circle().fill(Color.black).aspectRatio(circleAspectRatio, contentMode: .fit)  // if indicator is 0 it's set to black
                    
            }
            else if indicator.feedback == white {
                Circle().fill(Color.white).aspectRatio(circleAspectRatio, contentMode: .fit)  // if 1 set as white
            }
            else if indicator.feedback == red {
                Circle().fill(Color.red).aspectRatio(circleAspectRatio, contentMode: .fit)  // if 2 set as red
            }
        }
    }
        
    //Drawing Constants
    let circleAspectRatio:CGFloat = 2/3
    let black:Int = 0
    let white:Int = 1
    let red:Int = 2
}


// allActiveInRow
//      a helper function that returns a boolean value.  If all the answer pegs are faceUP (active) it returns true
//      if not, returns false
func allActiveInRow (viewModel: MasterMindGame) -> Bool {
    if(
        viewModel.pegs[viewModel.activeRow*4].filled && viewModel.pegs[viewModel.activeRow*4+1].filled && viewModel.pegs[viewModel.activeRow*4+2].filled && viewModel.pegs[viewModel.activeRow*4+3].filled){
        return true
    }  // checks if all 4 pegs are filled in, if so return true
    return false
}



// this is an included view that allows the developer to preview the App while it's being worked on
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: MasterMindGame())
    }
}
