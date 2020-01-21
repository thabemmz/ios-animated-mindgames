//
//  File.swift
//  Set
//
//  Created by Christiaan van Bemmel on 11/08/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import Foundation

struct SetGame {
    private(set) var deck = SetDeck()
    private(set) var openCards = [Card]()
    private(set) var selectedCards = [Card]()
    private(set) var matchedCards = [Card]()
    private(set) var score = 0
    var threeCardsSelected: Bool {
        return selectedCards.count == 3
    }
    var selectedCardsMatch: Bool {
        if !threeCardsSelected {
            return false
        }
        
        // We go through all selected cards and create a Set with unique values for each property of a card.
        // If there are three unique values for a property, it is a match. If there is one unique value for
        // a property, it is also a match. If there are only 2 unique values, it's not a match. Since matching on
        // two is shorter, we negate the outcome of the full set of properties
        let numUniqueColors = Set(selectedCards.map { $0.color }).count
        let numUniqueShapes = Set(selectedCards.map { $0.shape }).count
        let numUniqueNumberOfShapes = Set(selectedCards.map { $0.numberOfShapes }).count
        let numUniqueShades = Set(selectedCards.map { $0.shade }).count
        
        return (numUniqueColors == 2 || numUniqueShapes == 2 || numUniqueNumberOfShapes == 2 || numUniqueShades == 2)
    }
    
    init() {
        for _ in 0..<12 {
            drawCardAndAddToOpenCards()
        }
    }
    
    // MARK: Public methods
    mutating func dealThreeMoreCards() {
        if selectedCardsMatch {
            // Only when the three cards match, replace them with new ones
            handleThreeCardsSelected()
        } else {
            // In every other case, append three new cards at the end of the openCards
            for _ in 0..<3 {
                drawCardAndAddToOpenCards()
            }
        }
    }
    
    mutating func selectOrDeselectCard(at cardIndex: Int) {
        let card = openCards[cardIndex]
        if !threeCardsSelected, let selectedCardsIndex = selectedCards.firstIndex(of: card) {
            // Less then 3 cards were selected and the chosen card was in the selected cards: deselect
            selectedCards.remove(at: selectedCardsIndex)
            score -= 1
        } else {
            if threeCardsSelected {
                // Three cards are selected. Handle the logic in this separate function
                handleThreeCardsSelected()
            }
            
            if (openCards.contains(card)) {
                // It can be possible that the selected card is not in the openCards anymore, mostly
                // due to a match whose cards got removed from the deck. This is why this extra check
                // is necessary.
                selectedCards.append(card)
            }
        }
        
        calculateScore()
    }
    
    mutating func shuffleOpenCards() {
        openCards.shuffle()
    }
    
    func isPartOfMatchingSelection(card: Card) -> Bool {
        return selectedCards.contains(card) && selectedCardsMatch
    }
    
    // MARK: Private methods
    mutating private func drawCardAndAddToOpenCards() {
        if let card = deck.drawCardFromDeck() {
            openCards.append(card)
        }
    }
    
    mutating private func calculateScore() {
        if threeCardsSelected {
            score += selectedCardsMatch ? 3 : -5
        }
    }
    
    mutating func handleThreeCardsSelected() {
        if selectedCardsMatch {
            // Copy the selectedCards to the matchedCards
            matchedCards += selectedCards
            
            // Draw new card for the selected cards in open cards
            for selectedCardIndex in selectedCards.indices {
                // Check if selected card exists in open cards
                if let openCardIndex = openCards.firstIndex(of: selectedCards[selectedCardIndex]) {
                    if !deck.isEmpty(), let card = deck.drawCardFromDeck() {
                        // If the deck is empty and we can draw a card, draw a new card at the position of the old one.
                        openCards[openCardIndex] = card
                    } else {
                        // The deck is empty. Just remove the card from the open cards
                        openCards.remove(at: openCardIndex)
                    }
                } else {
                    print("Selected card not found in open cards!")
                }
            }
        }
        
        selectedCards.removeAll()
    }
}
