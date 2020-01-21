//
//  ViewController.swift
//  Set
//
//  Created by Christiaan van Bemmel on 09/08/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var cardViews = [Card: CardView]()
    private var setGame: SetGame!
    private var canDealThreeMoreCards: Bool { return !setGame.deck.isEmpty() }
    private lazy var deckTap = UITapGestureRecognizer(target: self, action: #selector(deckTouched))
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehavior = CardBehavior(in: animator)

    // MARK: Outlets
    @IBOutlet weak var openCardsView: OpenCardsView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
            swipe.direction = [.down]
            openCardsView.addGestureRecognizer(swipe)
            
            let rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotated))
            openCardsView.addGestureRecognizer(rotation)
        }
    }
    @IBOutlet weak private var scoreLabel: UILabel!
    @IBOutlet weak var matchedCardsView: DeckView!
    @IBOutlet weak var deckView: DeckView!
    
    // MARK: Actions
    @IBAction private func touchNewGameButton(_ sender: UIButton) {
        startNewGame()
    }
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewGame()
    }
    
    // MARK: ObjectiveC gesture responders
    @objc private func swipedDown(_ sender: UISwipeGestureRecognizer) {
        switch(sender.state) {
        case .ended:maybeDealThreeMoreCards()
        default:break
        }
    }
    
    @objc private func rotated(_ sender: UIRotationGestureRecognizer) {
        switch(sender.state) {
        case .changed: fallthrough
        case .ended:
            if sender.rotation >= 0.6 {
                setGame.shuffleOpenCards()
                updateViewFromModel()
                sender.rotation = 0.0
            }
        default: break
        }
    }
    
    @objc func deckTouched(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            maybeDealThreeMoreCards()
        default: break
        }
    }
    
    @objc func cardTouched(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            // Cast view of the sender to a CardView
            if let senderAsCardView = sender.view as? CardView {
                // Retrieve index of cardView in the openCardsView
                if let cardViewIndex = openCardsView.cardViews.firstIndex(of: senderAsCardView) {
                    // Select the card and update the view
                    setGame.selectOrDeselectCard(at: cardViewIndex)
                    updateViewFromModel()
                } else {
                    print("Chosen card was not recognized in open cards")
                }
            }
        default: break
        }
    }
    
    // MARK: Game features
    // Deal three more cards if we are allowed to
    private func maybeDealThreeMoreCards() {
        if canDealThreeMoreCards {
            setGame.dealThreeMoreCards()
            updateViewFromModel()
        }
    }
        
    private func startNewGame() {
        openCardsView.removeAllViews()
        setGame = SetGame()
        updateViewFromModel()
    }
    
    private func populateCardView(_ cardView: CardView, with card: Card) {
        cardView.numberOfShapes = card.numberOfShapes.rawValue
        cardView.color = SymbolView.Color.fromProperty(card.color)
        cardView.shape = SymbolView.Shape.fromProperty(card.shape)
        cardView.shade = SymbolView.Shade.fromProperty(card.shade)
        cardView.isSelected = setGame.selectedCards.contains(card)
        
        if cardView.isSelected, setGame.threeCardsSelected {
            // Only display special isMatch flag when three cards are selected
            if setGame.selectedCardsMatch {
                cardView.isMatch = true
                
                // Fly away animation
                let flyAwayCard = cardView.clone()
                openCardsView.addSubview(flyAwayCard)
                cardBehavior.addItem(flyAwayCard)
                                
                // Animate!
                Timer.scheduledTimer(withTimeInterval: AnimationTimers.intervalBeforeFlyAwayAnimationKicksIn, repeats: false) { timer in
                    self.cardBehavior.removeItem(flyAwayCard)

                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: AnimationTimers.toMatchedCardsAnimationDuration,
                        delay: 0,
                        animations: {
                            // Transform back into position
                            flyAwayCard.transform = CGAffineTransform.init(rotationAngle: 0.0)
                            // Reset frame origin
                            flyAwayCard.frame.size = self.matchedCardsView.cardRectLeftAligned.size
                            flyAwayCard.frame.origin = self.openCardsView.leftBottomOrigin
                        },
                        completion: {
                            if $0 == .end {
                                UIView.transition(
                                    with: flyAwayCard,
                                    duration: AnimationTimers.flipCardAnimationDuration,
                                    options: [.transitionFlipFromLeft],
                                    animations: {
                                        flyAwayCard.isFaceUp = false
                                    },
                                    completion: {
                                        if $0 {
                                            timer.invalidate()

                                            flyAwayCard.removeFromSuperview()
                                            self.matchedCardsView.addCardView(flyAwayCard, alignment: DeckView.Alignment.left)
                                        }
                                    }
                                )
                            }
                        }
                    )
                }
                
                if !setGame.deck.isEmpty() {
                    // Hide the original cardView
                    cardView.alpha = 0
                }
            } else {
                // Cards don't match, communicate this to the view
                cardView.isMatch = false
            }
        } else {
            // If the card is not selected or less then three cards have been selected, don't visualize matching border
            cardView.isMatch = nil
        }
        
        // Generate tap gesture
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(cardTouched))
        // Add tap gesture to cardView
        cardView.addGestureRecognizer(cardTap)
    }

    private func getCardView(for card: Card) -> CardView {
        if cardViews[card] == nil {
            cardViews[card] = CardView()
        }

        return cardViews[card]!
    }

    private func rearrangeCards() {
        let numberOfCardsInModel = setGame.openCards.count
        let numberOfCardsInView = openCardsView.cardViews.count
        
        if (numberOfCardsInView == numberOfCardsInModel) {
            // Same amount of cards, fire afterRearrangement immediately
            openCardsView.dealAllHiddenCards()
            return
        }
        
        if numberOfCardsInView < numberOfCardsInModel {
            // We have too few cardViews in our view. Calculate the number of cardViews to add
            let numberOfCardViewsToAdd = numberOfCardsInModel - numberOfCardsInView

            for _ in 0..<numberOfCardViewsToAdd {
                // Create new cardView
                let newCardView = CardView()
                newCardView.alpha = 0

                openCardsView.addSubview(newCardView)

                // @TODO: Maybe implement this in the cardView itself?
                // Append cardView to array of cardViews
                openCardsView.cardViews.append(newCardView)
            }
            
            openCardsView.layoutCardsWithAnimation(dealCardAfterwards: true)
        }
        
        if numberOfCardsInView > numberOfCardsInModel {
            // We have to many cardViews in our view. Calculate the number of cardViews to remove
            let numberOfCardViewsToRemove = numberOfCardsInView - numberOfCardsInModel

            // @TODO: Maybe implement this in the cardView itself?
            for cardViewIndex in 0..<numberOfCardViewsToRemove {
                openCardsView.cardViews[cardViewIndex].removeFromSuperview()
            }

            openCardsView.cardViews.removeSubrange(0..<numberOfCardViewsToRemove)
            
            openCardsView.layoutCardsWithAnimation()
        }
        
    }
    
    private func updateViewFromModel () {
        // 1. Rearrange cards by setting the number of cards. That defines the amount of cards.
        rearrangeCards()
                        
        // 3. Update the states of all other cards
        for openCardIndex in setGame.openCards.indices {
            let card = setGame.openCards[openCardIndex]
            let cardView = openCardsView.cardViews[openCardIndex]
            populateCardView(cardView, with: card)
        }
                
        if setGame.selectedCardsMatch {
            setGame.handleThreeCardsSelected()
            updateViewFromModel()
        }

        deckView.cardViews = setGame.deck.deck.map { card in
            let cardView = CardView()
            cardView.frame = deckView.cardRectRightAligned
            cardView.isFaceUp = false
            return cardView
        }
        
        // Update score label with current setGame score
        scoreLabel.text = "Score: \(setGame.score)"
        
        // If no more then three cards can be dealt, grey out the button
        if !canDealThreeMoreCards {
            // Disable the button
            deckView.removeGestureRecognizer(deckTap)
        } else {
            // Enable the three more cards "button" with a tap gesture
            deckView.addGestureRecognizer(deckTap)
        }

    }
}

extension ViewController {
    struct AnimationTimers {
        static let intervalBeforeFlyAwayAnimationKicksIn = 1.2
        static let toMatchedCardsAnimationDuration = 0.5
        static let flipCardAnimationDuration = 0.7
    }
}
