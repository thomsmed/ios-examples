//
//  FullScreenImageViewController.swift
//  StretchyTableViewHeader
//
//  Created by Thomas Asheim Smedmann on 19/12/2021.
//

import UIKit
import TinyConstraints

class FullScreenImageViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let octocatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setHugging(.defaultHigh, for: .horizontal)
        imageView.setCompressionResistance(.defaultHigh, for: .horizontal)
        return imageView
    }()
    
    private lazy var imageViewLandscapeConstraint = octocatImageView.heightToSuperview(isActive: false, usingSafeArea: true)
    private lazy var imageViewPortraitConstraint = octocatImageView.widthToSuperview(isActive: false, usingSafeArea: true)
    
    init(octocat: Octocat, tag: Int) {
        super.init(nibName: nil, bundle: nil)
        octocatImageView.tag = tag
        octocatImageView.image = UIImage(contentsOfFile: octocat.imagePath)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBehaviour()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Force any ongoing scrolling to stop and prevent the image view jumping during dismiss animation.
        // Which is caused by the scroll animation and dismiss animation running at the same time.
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(wrapperView)
        wrapperView.addSubview(octocatImageView)
        
        scrollView.edgesToSuperview()
        
        // The wrapper view will fill up the scroll view, and act as a target for pinch and pan event
        wrapperView.edges(to: scrollView.contentLayoutGuide)
        wrapperView.width(to: scrollView.safeAreaLayoutGuide)
        wrapperView.height(to: scrollView.safeAreaLayoutGuide)
        
        octocatImageView.centerInSuperview()
        
        // Constraint UIImageView to fit the aspect ratio of the containing image
        let aspectRatio = octocatImageView.intrinsicContentSize.height / octocatImageView.intrinsicContentSize.width
        octocatImageView.heightToWidth(of: octocatImageView, multiplier: aspectRatio)
    }
    
    private func configureBehaviour() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        // scrollView.maximumZoomScale = 1.0001 // "Hack" to enable bouncy zoom without zooming
        scrollView.maximumZoomScale = 2.0
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomMaxMin))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass != .compact {
            // Ladscape
            imageViewPortraitConstraint.isActive = false
            imageViewLandscapeConstraint.isActive = true
        } else {
            // Portrait
            imageViewLandscapeConstraint.isActive = false
            imageViewPortraitConstraint.isActive = true
        }
    }
    
    @objc private func zoomMaxMin(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

// MARK: UIScrollViewDelegate

extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        octocatImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Make sure the zoomed image stays centred
        let currentContentSize = scrollView.contentSize
        let originalContentSize = wrapperView.bounds.size
        let offsetX = max((originalContentSize.width - currentContentSize.width) * 0.5, 0)
        let offsetY = max((originalContentSize.height - currentContentSize.height) * 0.5, 0)
        octocatImageView.center = CGPoint(x: currentContentSize.width * 0.5 + offsetX,
                                          y: currentContentSize.height * 0.5 + offsetY)
    }
}
