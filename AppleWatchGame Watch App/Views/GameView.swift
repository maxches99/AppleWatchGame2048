//
//  GameView.swift
//  AppleWatchGame Watch App
//
//  Created by Максим Чесников on 07.12.2022.
//

import SwiftUI
import UIKit

extension Edge {
    
    static func from(_ from: GameLogic.Direction) -> Self {
        switch from {
        case .down:
            return .top
        case .up:
            return .bottom
        case .left:
            return .trailing
        case .right:
            return .leading
        }
    }
    
}

struct GameView : View {
    
    @State var ignoreGesture = false
    @EnvironmentObject var gameLogic: GameLogic
    
    fileprivate struct LayoutTraits {
        let bannerOffset: CGSize
        let showsBanner: Bool
        let containerAlignment: Alignment
    }
    
    fileprivate func layoutTraits(`for` proxy: GeometryProxy) -> LayoutTraits {
#if os(macOS)
        let landscape = false
#else
        let landscape = proxy.size.width > proxy.size.height
#endif
        
        return LayoutTraits(
            bannerOffset: landscape
                ? .init(width: 3, height: 0)
                : .init(width: 0, height: 3),
            showsBanner: landscape ? proxy.size.width > 720 : proxy.size.height > 550,
            containerAlignment: landscape ? .leading : .top
        )
    }
    
    var gestureEnabled: Bool {
        // Existed for future usage.
#if os(macOS) || targetEnvironment(macCatalyst)
        return false
#else
        return true
#endif
    }
    
    var gesture: some Gesture {
        let threshold: CGFloat = 42
        let drag = DragGesture()
            .onChanged { v in
                guard !self.ignoreGesture else { return }
                
                guard abs(v.translation.width) > threshold ||
                    abs(v.translation.height) > threshold else {
                    return
                }
                
                withTransaction(Transaction(animation: .spring())) {
                    self.ignoreGesture = true
                    
                    if v.translation.width > threshold {
                        // Move right
                        self.gameLogic.move(.right)
                    } else if v.translation.width < -threshold {
                        // Move left
                        self.gameLogic.move(.left)
                    } else if v.translation.height > threshold {
                        // Move down
                        self.gameLogic.move(.down)
                    } else if v.translation.height < -threshold {
                        // Move up
                        self.gameLogic.move(.up)
                    }
                }
            }
            .onEnded { _ in
                self.ignoreGesture = false
            }
        return drag
    }
    
    var content: some View {
        GeometryReader { proxy in
            bind(self.layoutTraits(for: proxy)) { layoutTraits in
                ZStack(alignment: layoutTraits.containerAlignment) {
                    if layoutTraits.showsBanner {
                        Text("2048")
                            .font(Font.system(size: 6).weight(.black))
                            .foregroundColor(Color(red:0.47, green:0.43, blue:0.40, opacity:1.00))
                            .offset(layoutTraits.bannerOffset)
                    }
                    
                    ZStack(alignment: .center) {
                        VStack {
                            HStack {
                                Text("\(gameLogic.sum)")
                                    .padding(.leading, getSizeOfPaddingHorizontally())
                                    .foregroundColor(Color("secondary"))
                                Spacer()
                                Button(action: {gameLogic.newGame()}) {
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(Color("secondary"))
                                }
                                .padding(.leading, getSizeOfPaddingHorizontally())
                                
                            }
                            
                            Spacer()
                            BlockGridView(matrix: self.gameLogic.blockMatrix,
                                          blockEnterEdge: .from(self.gameLogic.lastGestureDirection))
                        }
                    }
                    .frame(width: proxy.size.width, height: getWidthOfScreen() , alignment: .center)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                .background(
                    Rectangle()
                        .fill(Color("background"))
                        .edgesIgnoringSafeArea(.all)
                )
            }
        }
    }
    
    var body: AnyView {
        return gestureEnabled ? (
            content
                .gesture(gesture, including: .all)>*
        ) : content>*
    }
    
}

#if DEBUG
struct GameView_Previews : PreviewProvider {
    
    static var previews: some View {
        GameView()
            .environmentObject(GameLogic())
    }
    
}
#endif

func getWidthOfScreen() -> CGFloat {
#if os(watchOS)
    return WKInterfaceDevice.current().screenBounds.size.width
    #else
    return UIScreen.main.bounds.size.width
#endif
}
