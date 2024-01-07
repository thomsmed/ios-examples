//
//  UIViewControllerPreview.swift
//  BottomSheetController
//
//  Created by hyonsoo on 1/7/24.
//

import SwiftUI

struct UIViewControllerPreview<U: UIViewController>: UIViewControllerRepresentable {
    
    let builder: () -> U
    
    init(_ builder: @escaping () -> U) {
        self.builder = builder
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return builder()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //
    }
    
}
