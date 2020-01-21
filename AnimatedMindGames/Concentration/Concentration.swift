//
//  Concentration.swift
//  Concentration
//
//  Created by Christiaan van Bemmel on 01/08/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import Foundation

struct Concentration {
    private(set) var cards = [ConcentrationCard]()
    private(set) var flipCount = 0
    private(set) var score = 0
    private var timeOfLastPairUp: Date?
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue
            }
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(numberOfPairsOfCards: \(numberOfPairsOfCards)): You must have at least 1 pair of cards")
        for _ in 0..<numberOfPairsOfCards {
            let card = ConcentrationCard()
            cards += [card, card]
        }
        cards.shuffle()
        flipCount = 0
        score = 0
    }
    
    private func didFlipHappenQuick() -> Bool {
        if let previousPairFlipTime = timeOfLastPairUp {
            return abs(previousPairFlipTime.timeIntervalSinceNow) < 15.0
        }
        
        return false
    }
    
    private mutating func calculateMatchedScore() {
        score += didFlipHappenQuick() ? 3 : 2
    }
    
    private mutating func calculatePunishScore(forMismatches numberOfMismatches: Int) {
        score -= didFlipHappenQuick() ? Int(numberOfMismatches / 2) : numberOfMismatches
    }
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): Chosen index not in cards")
        if cards[index].isMatched {
            return
        }
        
        flipCount += 1
        
        if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
            // check if cards match
            if cards[matchIndex] == cards[index] {
                cards[matchIndex].isMatched = true
                cards[index].isMatched = true
                calculateMatchedScore()
            } else {
                // calculate mismatch score by subtracting the sum of mismatches of the two cards
                calculatePunishScore(forMismatches: cards[index].numberOfMismatches + cards[matchIndex].numberOfMismatches)
                
                // and update mismatch administration
                cards[index].numberOfMismatches += 1
                cards[matchIndex].numberOfMismatches += 1
            }
            
            cards[index].isFaceUp = true
            timeOfLastPairUp = Date()
        } else {
            // either no cards or 2 cards are face up
            indexOfOneAndOnlyFaceUpCard = index
        }
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
