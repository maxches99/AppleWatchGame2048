//
//  BlockView.swift
//  AppleWatchGame Watch App
//
//  Created by Максим Чесников on 07.12.2022.
//

import SwiftUI

struct BlockView : View {
    
    fileprivate let colorScheme: [(Color, Color)] = [
        // 2
        (Color("2"), Color("white")),
        // 4
        (Color("4"), Color("white")),
        // 8
        (Color("8"), Color("white")),
        // 16
        (Color("16"), Color("white")),
        // 32
        (Color("32"), Color("white")),
        // 64
        (Color("64"), Color("white")),
        // 128
        (Color("128"), Color("white")),
        // 256
        (Color("256"), Color("white")),
        // 512
        (Color("512"), Color("white")),
        // 1024
        (Color("1024"), Color("white")),
        // 2048
        (Color("2048"), Color("white")),
    ]
    
    fileprivate let number: Int?
    
    // This is required to make the Text element be a different
    // instance every time the block is updated. Otherwise, the
    // text will be incorrectly rendered.
    //
    // TODO: File a bug.
    fileprivate let textId: String?
    
    init(block: IdentifiedBlock) {
        self.number = block.number
        self.textId = "\(block.id):\(block.number)"
    }
    
    fileprivate init() {
        self.number = nil
        self.textId = ""
    }
    
    static func blank() -> Self {
        return self.init()
    }
    
    fileprivate var numberText: String {
        guard let number = number else {
            return ""
        }
        return String(number)
    }
    
    fileprivate var fontSize: CGFloat {
        let textLength = numberText.count
        if textLength < 3 {
            return 26
        } else if textLength < 4 {
            return 18
        } else {
            return 12
        }
    }
    
    fileprivate var colorPair: (Color, Color) {
        guard let number = number else {
            return (Color("triple"), Color("white"))
        }
        let index = Int(log2(Double(number))) - 1
        if index < 0 || index >= colorScheme.count {
            fatalError("No color for such number")
        }
        return colorScheme[index]
    }
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorPair.0)
                .zIndex(1)

            Text(numberText)
                .font(Font.system(size: fontSize).bold())
                .foregroundColor(colorPair.1)
                .id(textId!)
                // ⚠️ Gotcha: `zIndex` is important for removal transition!!
                .zIndex(1000)
                .transition(AnyTransition.opacity.combined(with: .scale))
        }
        .clipped()
        .cornerRadius(6)
    }
    
}

// MARK: - Previews

#if DEBUG
struct BlockView_Previews : PreviewProvider {
    
    static var previews: some View {
        Group {
            ForEach((1...11).map { Int(pow(2, Double($0))) }, id: \.self) { i in
                BlockView(block: IdentifiedBlock(id: 0, number: i))
                    .previewLayout(.sizeThatFits)
            }
            
            BlockView.blank()
                .previewLayout(.sizeThatFits)
        }
    }
    
}
#endif
