//
//  DescriptionSendCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-16.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class DescriptionSendCell: SendCell {

    init(placeholder: String) {
        super.init()
        textView.delegate = self
        textView.textColor = LightColors.Text.one
        textView.font = Fonts.Body.one
        textView.returnKeyType = .done
        self.placeholder.text = placeholder
        setupViews()
    }

    var didBeginEditing: (() -> Void)?
    var didReturn: ((UITextView) -> Void)?
    var didChange: ((String) -> Void)?
    var content: String? {
        didSet {
            textView.text = content
            textViewDidChange(textView)
        }
    }

    let textView = UITextView()
    fileprivate let placeholder = UILabel(font: Fonts.Subtitle.two, color: LightColors.Text.two)
    private func setupViews() {
        textView.isScrollEnabled = false
        addSubview(textView)
        textView.constrain([
            textView.constraint(.leading, toView: self, constant: 11.0),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: Margins.large.rawValue),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30.0),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Margins.large.rawValue) ])

        textView.addSubview(placeholder)
        placeholder.constrain([
            placeholder.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            placeholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5.0) ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DescriptionSendCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditing?()
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.utf8.isEmpty
        if let text = textView.text {
            didChange?(text)
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            textView.resignFirstResponder()
            return false
        }

        let count = (textView.text ?? "").utf8.count + text.utf8.count
        if count > Constant.maxMemoLength {
            return false
        } else {
            return true
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        didReturn?(textView)
    }
}
