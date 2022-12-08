//
//  FunctionalUtils.swift
//  AppleWatchGame Watch App
//
//  Created by Максим Чесников on 07.12.2022.
//

func bind<T, U>(_ x: T, _ closure: (T) -> U) -> U {
    return closure(x)
}
