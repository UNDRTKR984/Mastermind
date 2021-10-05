//
//  Background.swift
//  MasterMindFinal
//
//  Created by Matt Vogel on 2/20/21.
//

// ----------------- VIEW ------------------------

import SwiftUI
import AVFoundation


// I learned how to do all of this from https://www.youtube.com/watch?v=FQfeJGA7P9w
struct Background: View {
    
    var itemsPerRow = 6 // how many items will be placed in each row
    @State var isAnimating = false  // state is it's own variable that can change and cause elements to "react" to it
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                ForEach(0..<getNumberOfRows()) {_ in //create a bunch of HStacks within the VStack
                    HStack(spacing: 0){
                        ForEach(0..<itemsPerRow){_ in // within each HStack place several images
                            Image(systemName: "timelapse")  // timelapse has a snowflake kind of look
                                .colorInvert()  // turn the color from black to white
                                .frame(width:UIScreen.main.bounds.width/CGFloat(itemsPerRow), height: UIScreen.main.bounds.width/CGFloat(itemsPerRow))  //UIScreen gives the entire screen
                                .opacity(isAnimating ? 1 : 0) //once it loads isAnimating is set to true
                                .animation(
                                    Animation.linear(duration: Double.random(in: 1.0...2.0)) //randomly sets the duration of the animation on each piece
                                        .repeatForever() // will continue to repeat the animation forever
                                        .delay(Double.random(in: 0...1.5)) // randomly sets the delay of the animation
                                )
                        }
                    }
                }
            }.onAppear(){ // when the view appears set isAnimating to true to start the animation and play game music
            isAnimating = true
                do {
                    gameMusic = try AVAudioPlayer(contentsOf: url)
                    gameMusic?.numberOfLoops = -1       //will play the file infinitely
                    gameMusic?.play()
                } catch {
                    print("Wont play")
                }
            }
        }
    }
    
    // this function determines how many rows of animation icons to show
    func getNumberOfRows() -> Int {
        let heightPerItem = UIScreen.main.bounds.width/CGFloat(itemsPerRow)
        return Int(UIScreen.main.bounds.height/heightPerItem)
    }
    
}

// music section
// learned how to get Music added from https://www.hackingwithswift.com/forums/swiftui/playing-sound/4921
var gameMusic: AVAudioPlayer?
let path = Bundle.main.path(forResource: "BigShell.mp3", ofType:nil)!
let url = URL(fileURLWithPath: path)




struct Background_Previews: PreviewProvider {
    static var previews: some View {
        Background()
    }
}
