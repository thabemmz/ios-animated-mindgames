//
//  DeckView.swift
//  AnimatedMindGames
//
//  Created by Christiaan van Bemmel on 06/09/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import UIKit

class DeckView: UIView {
    var cardViews = [CardView]() {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for subview in subviews {
            subview.removeFromSuperview()
        }

        for cardViewIndex in cardViews.indices {
            let cardView = cardViews[cardViewIndex]
            cardView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            addSubview(cardView)
        }
    }
    
    func addCardView(_ cardView: CardView, alignment: Alignment) {
        cardView.frame = alignment == Alignment.left ? cardRectLeftAligned : cardRectRightAligned
        cardViews.append(cardView)
    }
}

extension DeckView {
    enum Alignment {
        case left
        case right
    }
    
    enum Constants {
        static let cardWidth: CGFloat = 75
        static let rotationAngleMargin: CGFloat = 0.25
    }
    var cardRectLeftAligned: CGRect {
        return CGRect(origin: CGPoint(x: bounds.minX, y: bounds.minY), size: CGSize(width: Constants.cardWidth, height: Constants.cardWidth / CardView.Ratios.cardAspectRatio))
    }
    var cardRectRightAligned: CGRect {
        return CGRect(origin: CGPoint(x: bounds.maxX - Constants.cardWidth, y: bounds.minY), size: CGSize(width: Constants.cardWidth, height: Constants.cardWidth / CardView.Ratios.cardAspectRatio))
    }
    var rotationAngle: CGFloat {
        return (CGFloat(100).arc4random / 100) * Constants.rotationAngleMargin - (Constants.rotationAngleMargin / 2)
        
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}
