//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Roberto Cruz on 01/08/22.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult: SearchResult! {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    var downloadTask: URLSessionDownloadTask?
    private var isPopUp = false
    
    enum AnimationStyle {
        case slide
        case fade
    }

    var dismissStyle = AnimationStyle.fade
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPopUp {
            popupView.layer.cornerRadius = 10
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            addGradient().addGestureRecognizer(gestureRecognizer)
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
            popupView.isHidden = true
        }

        if searchResult != nil {
            updateUI()
        }
    }
    
    // Setting the transitioning delegate for animation
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
    }

    // Dealloc Image to memory save
    deinit {
//        print("deinit: \(self)")
        downloadTask?.cancel()
    }

}

//MARK: - Actions

extension DetailViewController {
    
    @IBAction func close() {
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}


 // MARK: - Gesture Recognizer Delegate - click outside the view, and it closes the view.
// TODO: - First OR is unnecesary, but i'll wait to fix it.
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        (touch.view == self.view) || (touch.view?.subviews.startIndex == self.view.subviews.startIndex)
    }
}

// MARK: - Helper Methods
extension DetailViewController {
    func updateUI() {
        nameLabel.text = searchResult.name
        
        if searchResult.artist.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Artist Name: Unknown")
        } else {
            artistNameLabel.text = searchResult.artist
        }
        
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        
        // Show Price in Button
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        let priceText: String
        if searchResult.price == 0 {
            priceText = NSLocalizedString("Free", comment: "Price Text: Free")
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        
        priceButton.setTitle(priceText, for: .normal)
        
        priceButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        // Show Image
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        
        popupView.isHidden = false
    }
    
    func addGradient() -> UIView {
        view.backgroundColor = UIColor.clear
        let dimmingView = GradientView(frame: CGRect.zero)
        dimmingView.frame = view.bounds
        view.insertSubview(dimmingView, at: 0)
        return dimmingView
    }

}

// MARK: - Animation: Controller transition Delegate
extension DetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
    }
}

