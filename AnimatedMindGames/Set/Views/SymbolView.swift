//
//  SymbolView.swift
//  GraphicalSet
//
//  Created by Christiaan van Bemmel on 26/08/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import UIKit

class SymbolView: UIView {
    var shape: Shape = .diamond { didSet { setNeedsDisplay() }}
    var shade: Shade = .fill  { didSet { setNeedsDisplay() }}
    var color: Color = .red  { didSet { setNeedsDisplay() }}
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame);
        isOpaque = false;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isOpaque = false
    }
    
    // MARK: Draw shape functions
    private func drawDiamond(in rect: CGRect) -> UIBezierPath {
        let diamondPath = UIBezierPath()
        
        // Start at the left middle side
        diamondPath.move(to: CGPoint(x: rect.minX, y: rect.midY))
        // Draw a line to the outmost top of the diamond
        diamondPath.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        // To the outmost right side of the diamond
        diamondPath.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        // To the outmost bottom of the diamond
        diamondPath.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        // And close the diamond
        diamondPath.close()
        
        return diamondPath
    }
    
    private func drawOval(in rect: CGRect) -> UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height), cornerRadius: ovalSymbolCornerRadiusFor(width: rect.width))
    }
    
    private func drawSquiggle(in rect: CGRect) -> UIBezierPath {
        let squigglePath = UIBezierPath()
        let heightDiff: CGFloat = squiggleSymbolHeightDifferenceFor(height: rect.height)
        
        let verticalStartPosition = rect.minY + heightDiff
        let verticalEndPosition = rect.maxY - heightDiff
        
        // First to the outmost left top
        squigglePath.move(to: CGPoint(x: rect.minX, y: verticalStartPosition))
        // Draw a curved line to the outmost right top
        squigglePath.addCurve(to: CGPoint(x: rect.maxX, y: verticalStartPosition), controlPoint1: CGPoint(x: rect.minX, y: squigglePath.currentPoint.y - heightDiff), controlPoint2: CGPoint(x: rect.maxX, y:  squigglePath.currentPoint.y + heightDiff))
        // Draw a straight line down to the outmost right bottom
        squigglePath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - heightDiff))
        // Draw a curved line to the outmost left bottom
        squigglePath.addCurve(to: CGPoint(x: rect.minX, y: verticalEndPosition), controlPoint1: CGPoint(x: rect.maxX, y: squigglePath.currentPoint.y + heightDiff), controlPoint2: CGPoint(x: rect.minX, y: squigglePath.currentPoint.y - heightDiff))
        // Close the path
        squigglePath.close()
        
        return squigglePath
    }
    
    // MARK: Draw shade functions
    private func drawFillShade(for symbol: UIBezierPath) -> UIBezierPath {
        color.asUIColor.setFill()
        symbol.fill()
        
        return symbol
    }
    
    private func drawOutlineShade(for symbol: UIBezierPath) -> UIBezierPath {
        symbol.addClip()
        symbol.lineWidth = strokeWidth
        color.asUIColor.setStroke()
        symbol.stroke()
        
        return symbol
    }
    
    private func drawStrokeShade(for symbol: UIBezierPath, rect: CGRect) -> UIBezierPath {
        // Apply clipping for the stripes
        symbol.addClip()

        // Outline the symbol with a slightly thicker line
        color.asUIColor.setStroke()
        symbol.lineWidth = strokeWidth
        symbol.stroke()
        

        // Create a new stripe path
        let stripePath = UIBezierPath(rect: rect)
        
        var linePoint = rect.origin.x
        repeat {
            // Move to the top of the rect
            stripePath.move(to: CGPoint(x: linePoint, y: rect.minY))
            // Draw a line to the bottom of the rect at the same `x` coordinate
            stripePath.addLine(to: CGPoint(x: linePoint, y: rect.maxY))
            // Make sure the next line will be `stripGutter` further
            linePoint += stripeGutter
        } while linePoint <= rect.maxX
        
        stripePath.stroke()
        
        return symbol
    }
    
    // MARK: Drawing
    override func draw(_ rect: CGRect) {
        var symbol: UIBezierPath
        
        // Draw the right shape first
        switch(shape) {
        case .diamond: symbol = drawDiamond(in: rect)
        case .oval: symbol = drawOval(in: rect)
        case .squiggle: symbol = drawSquiggle(in: rect)
        }
        
        // Apply shading on drawing
        switch(shade) {
        case .fill: symbol = drawFillShade(for: symbol)
        case .outline: symbol = drawOutlineShade(for: symbol)
        case .stroke: symbol = drawStrokeShade(for: symbol, rect: rect)
        }
    }
    
}

extension SymbolView {
    struct Ratios {
        static let ovalSymbolCornerRadiusToRectWidth: CGFloat = 0.45
        static let stripeGutterToBoundsWidth: CGFloat = 0.075
        static let strokeWidthToBoundsWidth: CGFloat = 0.05
        static let squiggleHeightDifferenceToRectHeight: CGFloat = 0.1
    }
    
    // The gutter between the strips depends on the width of the view
    private var stripeGutter: CGFloat {
        return bounds.size.width * Ratios.stripeGutterToBoundsWidth
    }
    
    private var strokeWidth: CGFloat {
        return bounds.size.width * Ratios.strokeWidthToBoundsWidth
    }
    
    // The corner radius of the oval depends on the width of the view
    private func ovalSymbolCornerRadiusFor(width: CGFloat) -> CGFloat {
        return width * Ratios.ovalSymbolCornerRadiusToRectWidth
    }
    
    private func squiggleSymbolHeightDifferenceFor(height: CGFloat) -> CGFloat {
        return height * Ratios.squiggleHeightDifferenceToRectHeight
    }
    
    enum Shape: CustomStringConvertible {
        case diamond
        case oval
        case squiggle
        
        var description: String {
            switch self {
            case .diamond: return "♦️"
            case .oval: return "⭕️"
            case .squiggle: return "〽️"
            }
        }
        
        // Determine Shape on the CardProperty enum
        static func fromProperty(_ property: CardProperty) -> Shape {
            switch property {
            case .optionOne: return .diamond
            case .optionTwo: return .oval
            case .optionThree: return .squiggle
            }
        }
    }
    
    enum Color: CustomStringConvertible {
        case red
        case green
        case blue
        
        var description: String {
            switch self {
            case .red: return "Red"
            case .green: return "Green"
            case .blue: return "Blue"
            }
        }
        
        var asUIColor: UIColor {
            switch self {
            case .red: return UIColor(cgColor: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
            case .green: return UIColor(cgColor: #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1))
            case .blue: return UIColor(cgColor: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1))
            }
        }
        
        // Determine Color on the CardProperty enum
        static func fromProperty(_ property: CardProperty) -> Color {
            switch property {
            case .optionOne: return .red
            case .optionTwo: return .green
            case .optionThree: return .blue
            }
        }
    }
    
    enum Shade: CustomStringConvertible {
        case fill
        case outline
        case stroke
        
        var description: String {
            switch self {
            case .fill: return "Fill"
            case .outline: return "Outline"
            case .stroke: return "Stroke"
            }
        }
        
        // Determine Shade on the CardProperty enum
        static func fromProperty(_ property: CardProperty) -> Shade {
            switch property {
            case .optionOne: return .fill
            case .optionTwo: return .outline
            case .optionThree: return .stroke
            }
        }
    }
}
