//
//  GameLogic.swift
//  AppleWatchGame Watch App
//
//  Created by Максим Чесников on 07.12.2022.
//

import Foundation
import SwiftUI
import Combine

final class GameLogic : ObservableObject {
    
    enum Direction: Codable {
        case left
        case right
        case up
        case down
    }
    
    typealias BlockMatrixType = BlockMatrix<IdentifiedBlock>
    
    let objectWillChange = PassthroughSubject<GameLogic, Never>()
    
    fileprivate var _blockMatrix: BlockMatrixType!
    var blockMatrix: BlockMatrixType {
        return _blockMatrix
    }
    
    @Published var sum = 0
    
    @Published fileprivate(set) var lastGestureDirection: Direction = .up
    
    struct SavedGame: Codable {
        var blockMatrix: BlockMatrixType
        var sum: Int
        var lastGestureDirection: Direction
    }
    
    fileprivate var savedGame: SavedGame? {
        didSet {
            saveGame()
        }
    }
    
    fileprivate var _globalID = 0
    fileprivate var newGlobalID: Int {
        _globalID += 1
        return _globalID
    }
    
    init() {
        resumeGame()
    }
    
    func newGame() {
        sum = 0
        _blockMatrix = BlockMatrixType()
        resetLastGestureDirection()
        generateNewBlocks()
        
        objectWillChange.send(self)
    }
    
    func resumeGame() {
        if let game = loadGame() {
            _blockMatrix = game.blockMatrix
            lastGestureDirection = game.lastGestureDirection
            sum = game.sum
            generateNewBlocks()
            
            objectWillChange.send(self)
        } else {
            newGame()
        }
    }
    
    func resetLastGestureDirection() {
        lastGestureDirection = .up
    }
    
    func move(_ direction: Direction) {
        defer {
            objectWillChange.send(self)
        }
        
        lastGestureDirection = direction
        
        var moved = false
        
        let axis = direction == .left || direction == .right
        for row in 0..<4 {
            var rowSnapshot = [IdentifiedBlock?]()
            var compactRow = [IdentifiedBlock]()
            for col in 0..<4 {
                // Transpose if necessary.
                if let block = _blockMatrix[axis ? (col, row) : (row, col)] {
                    rowSnapshot.append(block)
                    compactRow.append(block)
                }
                rowSnapshot.append(nil)
            }
            
            merge(blocks: &compactRow, reverse: direction == .down || direction == .right)
            
            var newRow = [IdentifiedBlock?]()
            compactRow.forEach { newRow.append($0) }
            if compactRow.count < 4 {
                for _ in 0..<(4 - compactRow.count) {
                    if direction == .left || direction == .up {
                        newRow.append(nil)
                    } else {
                        newRow.insert(nil, at: 0)
                    }
                }
            }
            
            newRow.enumerated().forEach {
                if rowSnapshot[$0]?.number != $1?.number {
                    moved = true
                }
                _blockMatrix.place($1, to: axis ? ($0, row) : (row, $0))
            }
        }
        
        if moved {
            generateNewBlocks()
        }
        savedGame = SavedGame(blockMatrix: _blockMatrix, sum: sum, lastGestureDirection: lastGestureDirection)
    }
    
    fileprivate func merge(blocks: inout [IdentifiedBlock], reverse: Bool) {
        if reverse {
            blocks = blocks.reversed()
        }
        
        blocks = blocks
            .map { (false, $0) }
            .reduce([(Bool, IdentifiedBlock)]()) { acc, item in
                if acc.last?.0 == false && acc.last?.1.number == item.1.number {
                    var accPrefix = Array(acc.dropLast())
                    var mergedBlock = item.1
                    mergedBlock.number *= 2
                    accPrefix.append((true, mergedBlock))
                    return accPrefix
                } else {
                    var accTmp = acc
                    accTmp.append((false, item.1))
                    return accTmp
                }
            }
            .map { $0.1 }
        
        if reverse {
            blocks = blocks.reversed()
        }
    }
    
    @discardableResult fileprivate func generateNewBlocks() -> Bool {
        var blankLocations = [BlockMatrixType.Index]()
        for rowIndex in 0..<4 {
            for colIndex in 0..<4 {
                let index = (colIndex, rowIndex)
                if _blockMatrix[index] == nil {
                    blankLocations.append(index)
                }
            }
        }
        
        guard blankLocations.count >= 2 else {
            return false
        }
        
        // Don't forget to sync data.
        defer {
            objectWillChange.send(self)
        }
        
        // Place the first block.
        var placeLocIndex = Int.random(in: 0..<blankLocations.count)
        _blockMatrix.place(IdentifiedBlock(id: newGlobalID, number: 2), to: blankLocations[placeLocIndex])
        
        sum += 2
        
        // Place the second block.
        guard let lastLoc = blankLocations.last else {
            return false
        }
        blankLocations[placeLocIndex] = lastLoc
        placeLocIndex = Int.random(in: 0..<(blankLocations.count - 1))
        _blockMatrix.place(IdentifiedBlock(id: newGlobalID, number: 2), to: blankLocations[placeLocIndex])
        
        sum += 2
        
        return true
    }
    
//    fileprivate func forEachBlockIndices(mode: ForEachMode = .rowByRow,
//                                         reversed: Bool = false,
//                                         _ action: (BlockMatrixType.Index) -> ()) {
//        var indices = (0..<4).map { $0 }
//        if reversed {
//            indices = indices.reversed()
//        }
//
//        for row in indices {
//            for col in indices {
//                if mode == .rowByRow {
//                    action((col, row))
//                } else {
//                    action((row, col))  // transpose
//                }
//            }
//        }
//    }
    
    func saveGame() {
        if let encoded = try? JSONEncoder().encode(savedGame) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "Game")
        }
    }

    func loadGame() -> SavedGame? {
        let defaults = UserDefaults.standard
        if let saved = defaults.object(forKey: "Game") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(SavedGame.self, from: saved) {
                return loaded
            }
        }
        return nil
    }
    
}



