//
//  CardView.swift
//  GraphicalSet
//
//  Created by Christiaan van Bemmel on 22/08/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    @IBInspectable var isFaceUp: Bool = true { didSet { rerender() } }
    var color: SymbolView.Color? { didSet { rerender() } }
    var shade: SymbolView.Shade? { didSet { rerender() } }
    var shape: SymbolView.Shape? { didSet { rerender() } }
    var numberOfShapes: Int? { didSet { rerender() } }
    var isSelected = false { didSet { setNeedsDisplay() } }
    var isMatch: Bool?
    private lazy var grid = Grid(layout: .aspectRatio(Ratios.symbolAspectRatio), frame: bounds.insetBy(dx: cardCornerOffset, dy: cardCornerOffset))
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Set opaqueness in initializer
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Set opaqueness in initializer
        isOpaque = false
    }
    
    private func rerender() {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    func clone() -> CardView {
        let newCardView = CardView()
        newCardView.frame = self.frame
        newCardView.isFaceUp = self.isFaceUp
        newCardView.color = self.color
        newCardView.shade = self.shade
        newCardView.shape = self.shape
        newCardView.numberOfShapes = self.numberOfShapes
        newCardView.isSelected = self.isSelected
        newCardView.isMatch = self.isMatch
        return newCardView
    }
    
    // MARK: Rendering and drawing
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        // Always remove all subviews first.
        removeAllSubviews()
        
        if color == nil || shade == nil || shape == nil || numberOfShapes == nil || !isFaceUp {
            return
        }
        
        // Reset the frame of the grid by the bounds of this view
        grid.frame = bounds.insetBy(dx: cardCornerOffset, dy: cardCornerOffset)
        grid.cellCount = numberOfShapes!
                
        for cellIndex in 0..<grid.cellCount {
            if let gridFrame = grid[cellIndex] {
                // Create a new symbolview and set the properties
                let symbolView = SymbolView(frame: gridFrame.insetBy(dx: 0, dy: symbolInset))
                symbolView.color = color!
                symbolView.shade = shade!
                symbolView.shape = shape!
                
                // Add subview to grid
                addSubview(symbolView)
            } else {
                print("Grid frame could not be found")
            }
        }
    }
        
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cardCornerRadius)
        roundedRect.addClip()
        UIColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)).setStroke()
        roundedRect.lineWidth = cardStrokeWidth
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            if isMatch != nil {
                if isMatch! {
                    UIColor.black.setStroke()
                } else {
                    roundedRect.lineWidth = cardInnerStrokeWidth
                    UIColor.red.setStroke()
                }
            } else if isSelected {
                UIColor.blue.setStroke()
                roundedRect.lineWidth = cardInnerStrokeWidth
            } else {
                UIColor.black.setStroke()
            }
        } else {
            let innerRoundedRect = UIBezierPath(roundedRect: bounds.insetBy(dx: cardCornerOffset, dy: cardCornerOffset), cornerRadius: cardCornerRadius)
            UIColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).setFill()
            innerRoundedRect.fill()
        }
        
        roundedRect.stroke()
    }
}

extension CardView {
    struct Ratios {
        static let cardAspectRatio: CGFloat = 5.5 / 8.5
        static let cardCornerRadiusToBoundsWidth: CGFloat = 0.1
        static let cardCornerOffsetToCornerRadius: CGFloat = 0.8
        static let cardStrokeWidthToBoundsWidth: CGFloat = 0.03
        static let cardInnerStrokeWidthToBoundsWidth: CGFloat = 0.15
        static let symbolAspectRatio: CGFloat = 110 / 55
        static let symbolInsetToBoundsHeight: CGFloat = 0.025
    }
    
    private var cardCornerRadius: CGFloat {
        return bounds.size.width * Ratios.cardCornerRadiusToBoundsWidth
    }
    
    private var cardCornerOffset: CGFloat {
        return cardCornerRadius * Ratios.cardCornerOffsetToCornerRadius
    }
    
    private var cardStrokeWidth: CGFloat {
        return bounds.size.width * Ratios.cardStrokeWidthToBoundsWidth
    }
    
    private var cardInnerStrokeWidth: CGFloat {
        return bounds.size.width * Ratios.cardInnerStrokeWidthToBoundsWidth
    }
    
    private var symbolInset: CGFloat {
        return bounds.size.height * Ratios.symbolInsetToBoundsHeight
    }
}
