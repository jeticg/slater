//
//  ContentView.swift
//  Slater
//
//  Created by Jetic Gū on 01.05.23.
//

import SwiftUI
import UIKit
import AVFoundation

// Keyboard detection: see if keyboard is visible
class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        isKeyboardVisible = true
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        isKeyboardVisible = false
    }
}


// Function to create pickers for audio, day/night, angle and INT/EXT
func CreatePickerBlockS(tgt: Binding<String>, slating: Binding<Bool>, Type: [String]) -> some View{
    return ZStack {
        // Custom picker label
        Text("\(tgt.wrappedValue)")
           .font(.title)
           .foregroundColor(slating.wrappedValue ? ColourBG: ColourFG)
        Text("NIGHTT")
            .font(.title)
            .foregroundColor(ColourBG)
            .opacity(0)
       // Invisible picker
        Picker("Picker",
               selection: tgt) {
            ForEach(Type, id: \.self) {
                loc in
                Text(loc).font(.title2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(slating.wrappedValue ? ColourBG: ColourFG)
            }
        }
               .pickerStyle(.menu)
               .opacity(0.025)
    }
        .frame(maxHeight: .infinity)
        .border(slating.wrappedValue ? ColourBG: ColourFG)

}

struct SlateViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public extension UIFont {
    static func textStyleSize(_ style: UIFont.TextStyle) -> CGFloat {
        UIFont.preferredFont(forTextStyle: style).pointSize
    }
}
    
struct SlateView: View {
    @State private var slating = false
    
    @State private var metaProd: String = "One Shot Heist"
    @State private var metaRoll: String = "1"
    @State private var metaScene: String = "1"
    @State private var metaTake: Int = 1
    @State private var metaDir: String = "Justin Mao"
    @State private var metaDoP: String = "Thomas Mai"
    @State private var metaLoc: String = "INT"
    @State private var metaDay: String = "DAY"
    @State private var metaAng: String = "MCU"
    @State private var metaAud: String = "CAM"

    var beepPlayer: AVAudioPlayer?
    init() {
        guard let path = Bundle.main.path(forResource: "beep", ofType: "mp3") else { return }
        
        do {
            beepPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            beepPlayer?.prepareToPlay()
        } catch {
            print("Error loading beep sound: \(error)")
        }
    }

    var body: some View {
        let Layout = UIDevice.current.orientation.isLandscape ? AnyLayout(HStackLayout()) : AnyLayout(HStackLayout())
        
        VStack(spacing: 0) {
            Layout {
                Text("Prod.").font(.title2)
                TextField("Default Production", text: $metaProd)
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity)
            }.border(slating ? ColourBG: ColourFG, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)

            HStack(alignment: .bottom) {
                VStack(alignment: .center) {
                    Text("Roll").font(.title2)
                    TextField("Roll",
                              text: $metaRoll)
                        .font(.system(size: UIFont.textStyleSize(.largeTitle) * 2, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: .infinity)
                }
                
                VStack(alignment: .center) {
                    Text("Scene").font(.title2)
                    TextField("Scene",
                              text: $metaScene)
                    .font(.system(size: UIFont.textStyleSize(.largeTitle) * 2, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: .infinity)
                }.border(slating ? ColourBG: ColourFG, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                
                VStack(alignment: .center) {
                    Text("Take").font(.title2)
                    TextField("Take",
                              value: $metaTake,
                              formatter: NumberFormatter())
                        .font(.system(size: UIFont.textStyleSize(.largeTitle) * 2, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: .infinity)
                }
            }.border(slating ? ColourBG: ColourFG)

            VStack {
                Layout {
                    Text("Dir.").font(.title2)
                    TextField("Director", text: $metaDir)
                        .font(.largeTitle.bold())
                        .frame(maxHeight: .infinity)
                }
                Layout {
                    Text("DoP.").font(.title2)
                    TextField("Director of Photography", text: $metaDoP)
                        .font(.largeTitle.bold())
                        .frame(maxHeight: .infinity)
                }
            }.border(slating ? ColourBG: ColourFG)
            
            HStack(alignment: .bottom) {
                Layout {
                    Text("Date").font(.title2)
                    Text(Date(), style: .date)
                        .font(.largeTitle.bold())
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(alignment: .center) {
                    HStack {
                        CreatePickerBlockS(tgt: $metaDay, slating: $slating, Type: DayType)
                        CreatePickerBlockS(tgt: $metaLoc, slating: $slating, Type: LocType)
                    }.border(slating ? ColourBG: ColourFG)
                    HStack {
                        CreatePickerBlockS(tgt: $metaAng, slating: $slating, Type: AngType)
                        CreatePickerBlockS(tgt: $metaAud, slating: $slating, Type: AudType)
                    }.border(slating ? ColourBG: ColourFG)
                }
            }.border(slating ? ColourBG: ColourFG).frame(maxHeight: .infinity)
            Button(action: {
                slating = true
                beepPlayer?.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    slating = false
                }
            }){
                Text("Press me or swipe down to slate")
                    .font(.system(size: 24))
            }
        }
            .foregroundColor(slating ? ColourBG: ColourFG)
            .background(slating ? ColourFG: ColourBG)
            .modifier(SlateViewModifier())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Detecting down swiping gesture
            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                        .onEnded { value in
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height
                            
                            if abs(horizontalAmount) < abs(verticalAmount) && verticalAmount > 0 {
                                slating = true
                                beepPlayer?.play()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    slating = false
                                }

                            }
                        })
    }
}

struct SlateView_Preview: PreviewProvider {
    static var previews: some View {
        SlateView()
    }
}

