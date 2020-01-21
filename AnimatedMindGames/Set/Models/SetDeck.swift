//
//  SetDeck.swift
//  GraphicalSet
//
//  Created by Christiaan van Bemmel on 22/08/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import Foundation

struct SetDeck {
    private(set) var deck = [Card]()
    
    init() {
        for color in CardProperty.allCases {
            for numberOfShapes in NumberOfShapesProperty.allCases {
                for shape in CardProperty.allCases {
                    for shade in CardProperty.allCases {
                        deck.append(Card(numberOfShapes: numberOfShapes, shape: shape, shade: shade, color: color))
                    }
                }
            }
        }
        
        deck.shuffle()
    }
    
    mutating func drawCardFromDeck() -> Card? {
        return deck.count == 0 ? nil : deck.removeFirst()
    }
    
    func isEmpty() -> Bool {
        return deck.isEmpty
    }
}
