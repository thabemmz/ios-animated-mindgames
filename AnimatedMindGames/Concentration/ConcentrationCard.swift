//
//  Card.swift
//  Concentration
//
//  Created by Christiaan van Bemmel on 01/08/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import Foundation

struct ConcentrationCard: Hashable
{
    private var identifier: Int
    var isFaceUp = false
    var isMatched = false
    var numberOfMismatches = 0
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func ==(lhs: ConcentrationCard, rhs: ConcentrationCard) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    private static var identifierFactory = 0
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init() {
        self.identifier = ConcentrationCard.getUniqueIdentifier()
    }
}
