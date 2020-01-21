//
//  Card.swift
//  Set
//
//  Created by Christiaan van Bemmel on 11/08/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import Foundation

struct Card: Equatable, Hashable {
    let numberOfShapes: NumberOfShapesProperty
    let shape: CardProperty
    let shade: CardProperty
    let color: CardProperty
}

enum CardProperty: CaseIterable {
    case optionOne, optionTwo, optionThree
}

enum NumberOfShapesProperty: Int, CaseIterable {
    case one = 1, two, three
}
