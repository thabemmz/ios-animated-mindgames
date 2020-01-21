//
//  OpenCardsView.swift
//  GraphicalSet
//
//  Created by Christiaan van Bemmel on 22/08/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import UIKit

@IBDesignable
class OpenCardsView: UIView {
    var cardViews = [CardView]() {
        didSet {
            grid.cellCount = cardViews.count
        }
    }
    lazy var grid = Grid(layout: .aspectRatio(CardView.Ratios.cardAspectRatio), frame: bounds)
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if (grid.frame != bounds) {
            // The grid has changed, redraw all the cards
            grid.frame = bounds
            layoutCardsWithAnimation(dealCardAfterwards: false)
        }
    }
    
    func layoutCardsWithAnimation(dealCardAfterwards: Bool = false) {
        let hiddenCardsAtStartOfLayout = self.hiddenCards
        
        for cardViewsIndex in cardViews.indices {
            // Find the gridFrame for each cardView. Since the `grid.cellCount` changed in the `didSet` of `cardViews`, these should have the same size.
            guard let gridFrame = grid[cardViewsIndex] else {
                return print("Griditem with index \(cardViewsIndex) could not be found")
            }
            
            let gridFrameForCard = gridFrame.insetBy(dx: self.gridGutter, dy: self.gridGutter)
            let cardView = cardViews[cardViewsIndex]
                
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0,
                options: [.curveEaseInOut],
                animations: {
                    // Inset the frames with the gutter
                    cardView.frame = gridFrameForCard
                },
                completion: {
                    if $0 == .end {
                        if dealCardAfterwards, let hiddenCardIndex = hiddenCardsAtStartOfLayout.firstIndex(of: cardView) {
                            self.dealCardWithAnimation(cardView: cardView, at: hiddenCardIndex)
                        }
                    }
                }
            )
        }
    }
    
    func dealAllHiddenCards() {
        hiddenCards.enumerated().forEach { dealCardWithAnimation(cardView: $0.element, at: $0.offset) }
    }
    
    func dealCardWithAnimation(cardView: CardView, at hiddenCardIndex: Int) {
        let targetFrameOrigin = cardView.frame.origin
        cardView.frame.origin = rightBottomOrigin
        cardView.alpha = 1
        cardView.isFaceUp = false
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: Double(hiddenCardIndex) * 0.1,
            animations: {
                cardView.frame.origin = targetFrameOrigin
            },
            completion: {
                if $0 == .end {
                    // Make sure cardView is layed out properly
                    cardView.transform = .identity
                    
                    // Set isFaceUp if it was not yet set.
                    if !cardView.isFaceUp {
                        UIView.transition(
                            with: cardView,
                            duration: 0.5,
                            options: [.transitionFlipFromLeft],
                            animations: {
                                cardView.isFaceUp = true
                            }
                        )
                    }
                }
            }
        )
    }
    
    func removeAllViews() {
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
    }
}

extension OpenCardsView {
    private struct Ratios {
        static let gutterToWidthRatio: CGFloat = 0.05
    }
    
    // return the origin of the most left bottom part of the grid
    var leftBottomOrigin: CGPoint {
        return CGPoint(x: bounds.minX, y: bounds.maxY)
    }
    
    // return the origin of the most right bottom part of the grid
    var rightBottomOrigin: CGPoint {
        return CGPoint(x: CGFloat(bounds.maxX - grid.cellSize.width), y: bounds.maxY)
    }
    
    // Calculate gutter of grid frames since grid frame size depends on `grid.cellCount`
    private var gridGutter: CGFloat {
        return grid.cellSize.width * Ratios.gutterToWidthRatio
    }
    
    var visibleCards: [CardView] {
        return cardViews.filter { $0.alpha != 0 }
    }
    
    var hiddenCards: [CardView] {
        return cardViews.filter { $0.alpha == 0 }
    }
    
    private var existingCards: [CardView] {
        return cardViews.filter { $0.superview == self }
    }
}
