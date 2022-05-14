//
//  DenseContentSheetViewController.swift
//  BottomSheetController
//
//  Created by Thomas Asheim Smedmann on 04/05/2022.
//

import UIKit

final class DenseContentSheetViewController: BottomSheetController {

    override func loadView() {
        view = UIView()

        let topLabel = UILabel()
        topLabel.font = .systemFont(ofSize: 17, weight: .regular)
        topLabel.numberOfLines = 0
        topLabel.text = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mattis, est sed facilisis auctor, velit nunc facilisis lorem, quis consectetur elit lorem eget nisl.
        """

        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 4
        textView.text = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mattis, est sed facilisis auctor, velit nunc facilisis lorem, quis consectetur elit lorem eget nisl. Vivamus porttitor porttitor congue. Maecenas venenatis nunc eu sodales egestas. Phasellus ut ante in augue mollis aliquet. Morbi varius finibus orci, quis varius quam consectetur ut. Donec placerat quam at dictum fringilla. Aenean a lacus eget lacus elementum aliquam. Nullam ultrices nulla augue, sed mattis orci elementum eleifend. Proin viverra accumsan est vel aliquam.
        """

        let bottomLabel = UILabel()
        bottomLabel.font = .systemFont(ofSize: 17, weight: .regular)
        bottomLabel.numberOfLines = 0
        bottomLabel.text = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mattis, est sed facilisis auctor, velit nunc facilisis lorem, quis consectetur elit lorem eget nisl.
        """

        let stackView = UIStackView(arrangedSubviews: [
            topLabel, textView, bottomLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 20

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        view.backgroundColor = .systemBackground
    }
}
