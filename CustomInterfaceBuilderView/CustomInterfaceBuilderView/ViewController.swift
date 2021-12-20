//
//  ViewController.swift
//  CustomInterfaceBuilderView
//
//  Created by Thomas Asheim Smedmann on 09/09/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var circularViewWidthConstraint: NSLayoutConstraint!
    
    @IBAction func handleRatingChange(_ sender: UISlider) {
        let newRating = Int(floor(sender.value))
        if newRating == ratingView.rating { return }
        ratingView.rating = newRating
        circularViewWidthConstraint.constant = CGFloat(newRating * 10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
