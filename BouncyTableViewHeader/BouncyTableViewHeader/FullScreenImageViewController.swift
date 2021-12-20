//
//  FullScreenImageViewController.swift
//  BouncyTableViewHeader
//
//  Created by Thomas Asheim Smedmann on 13/12/2021.
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
    
    private let imageView: UIImageView = {
        let image = UIImage(named: "Bananas")!
        let imageView = UIImageView(image: image)
        let aspectRatio = imageView.intrinsicContentSize.width / imageView.intrinsicContentSize.height
        imageView.contentMode = .scaleAspectFit
        imageView.widthToHeight(of: imageView, multiplier: aspectRatio)
        return imageView
    }()
    
    private let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var imageViewLandscapeConstraint = imageView.height(to: wrapperView, isActive: false)
    private lazy var imageViewPortraitConstraint = imageView.width(to: wrapperView, isActive: false)
    
    init(tag: Int) {
        super.init(nibName: nil, bundle: nil)
        imageView.tag = tag
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
        // Force any ongoing scrolling to stop to prevent the image view jumping during dismiss animation
        // (caused by the scroll animation and dismiss animation running at the same time)
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
        wrapperView.addSubview(imageView)
        
        scrollView.edgesToSuperview()
        
        wrapperView.edges(to: scrollView.contentLayoutGuide)
        wrapperView.width(to: scrollView.safeAreaLayoutGuide)
        wrapperView.height(to: scrollView.safeAreaLayoutGuide)
        
        imageView.centerInSuperview()
        
        traitCollectionChanged(from: nil)
    }
    
    private func configureBehaviour() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 1.0001 // "Hack" to enable bouncy zoom without zooming
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
    
    @objc private func close(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: UIScrollViewDelegate

extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Make sure the zoomed image stays centred
        let currentContentSize = scrollView.contentSize
        let originalContentSize = wrapperView.bounds.size
        let offsetX = max((originalContentSize.width - currentContentSize.width) * 0.5, 0)
        let offsetY = max((originalContentSize.height - currentContentSize.height) * 0.5, 0)
        imageView.center = CGPoint(x: currentContentSize.width * 0.5 + offsetX,
                                   y: currentContentSize.height * 0.5 + offsetY)
    }
}
