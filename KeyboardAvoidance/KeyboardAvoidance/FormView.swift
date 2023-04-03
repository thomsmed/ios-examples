//
//  FormView.swift
//  KeyboardAvoidance
//
//  Created by Thomas Asheim Smedmann on 03/04/2023.
//

import UIKit

final class FormView: UIView {
    private lazy var textFieldOne: UITextField = {
        let toolbar = UIToolbar(frame: CGRect(
            origin: .zero, size: CGSize(width: 100, height: 100)
        ))
        toolbar.setItems(
            [
                .flexibleSpace(),
                UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: self,
                    action: #selector(endEditing)
                )
            ],
            animated: false
        )
        toolbar.sizeToFit()

        let textField = UITextField()
        textField.inputAccessoryView = toolbar
        textField.placeholder = "Write something..."
        textField.font = .systemFont(ofSize: 18)
        textField.backgroundColor = .systemRed
        return textField
    }()

    private lazy var textFieldTwo: UITextField = {
        let toolbar = UIToolbar(frame: CGRect(
            origin: .zero, size: CGSize(width: 100, height: 100)
        ))
        toolbar.setItems(
            [
                .flexibleSpace(),
                UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: self,
                    action: #selector(endEditing)
                )
            ],
            animated: false
        )
        toolbar.sizeToFit()

        let textField = UITextField()
        textField.inputAccessoryView = toolbar
        textField.placeholder = "Write something..."
        textField.font = .systemFont(ofSize: 18)
        textField.backgroundColor = .systemBlue
        return textField
    }()

    private lazy var textViewOne: UITextView = {
        let toolbar = UIToolbar(frame: CGRect(
            origin: .zero, size: CGSize(width: 100, height: 100)
        ))
        toolbar.setItems(
            [
                .flexibleSpace(),
                UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: self,
                    action: #selector(endEditing)
                )
            ],
            animated: false
        )
        toolbar.sizeToFit()

        let textView = UITextView()
        textView.inputAccessoryView = toolbar
        textView.font = .systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGreen
        return textView
    }()

    private lazy var textViewTwo: UITextView = {
        let toolbar = UIToolbar(frame: CGRect(
            origin: .zero, size: CGSize(width: 100, height: 100)
        ))
        toolbar.setItems(
            [
                .flexibleSpace(),
                UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: self,
                    action: #selector(endEditing)
                )
            ],
            animated: false
        )
        toolbar.sizeToFit()

        let textView = UITextView()
        textView.inputAccessoryView = toolbar
        textView.font = .systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemOrange
        return textView
    }()

    private var offsetLayoutPriority: Int = 0

    convenience init(
        textFieldOneText: String? = nil,
        textFieldTwoText: String? = nil,
        textViewOneText: String? = nil,
        textViewTwoText: String? = nil,
        offsetLayoutPriority: Int
    ) {
        self.init(offsetLayoutPriority: offsetLayoutPriority)
        textFieldOne.text = textFieldOneText
        textFieldTwo.text = textFieldTwoText
        textViewOne.text = textViewOneText
        textViewTwo.text = textViewTwoText
    }

    init(offsetLayoutPriority: Int) {
        self.offsetLayoutPriority = offsetLayoutPriority
        super.init(frame: .zero)
        configure()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        let verticalStackView = UIStackView(arrangedSubviews: [
            textFieldOne, textFieldTwo, textViewOne, textViewTwo
        ])
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 16

        verticalStackView.arrangedSubviews.enumerated().forEach { (index, view) in
            view.setContentHuggingPriority(.defaultHigh - .init(index + offsetLayoutPriority), for: .vertical)
            view.setContentCompressionResistancePriority(.defaultHigh - .init(index + offsetLayoutPriority), for: .vertical)
        }

        addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
