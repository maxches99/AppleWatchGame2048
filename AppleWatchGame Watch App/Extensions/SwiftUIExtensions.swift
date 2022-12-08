//
//  SwiftUIExtensions.swift
//  AppleWatchGame Watch App
//
//  Created by Максим Чесников on 07.12.2022.
//

import SwiftUI

extension View {
    
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
    
}

postfix operator >*
postfix func >*<V>(lhs: V) -> AnyView where V: View {
    return lhs.eraseToAnyView()
}
