// 
//  AttributeCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2020-01-26.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class AttributeCell: UIView {

    init(currency: Currency) {
        self.currency = currency
        super.init(frame: .zero)
        setupViews()
    }

    private let currency: Currency
    
    var attribute: String? {
        return contentLabel.text
    }

    var textDidChange: ((String?) -> Void)?
    var didBeginEditing: (() -> Void)?

    func setContent(_ content: String?) {
        contentLabel.text = content
        textField.text = content
        textDidChange?(content)
    }

    var isEditable = false {
        didSet {
            gr.isEnabled = isEditable
        }
    }

    let textField = UITextField()
    fileprivate let contentLabel = UILabel(font: Fonts.Body.two, color: .darkText)
    private let label = UILabel(font: Fonts.Body.one)
    fileprivate let gr = UITapGestureRecognizer()
    fileprivate let tapView = UIView()
    private let border = UIView(color: LightColors.Outline.two)
    
    lazy var infoButton: UIButton = {
        let infoButton = UIButton()
        infoButton.setImage(Asset.help.image, for: .normal)
        infoButton.tintColor = LightColors.Text.three
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        
        return infoButton
    }()

    private func setupViews() {
        addSubviews()
        addConstraints()
        setInitialData()
    }

    private func addSubviews() {
        addSubview(label)
        addSubview(contentLabel)
        addSubview(textField)
        addSubview(tapView)
        addSubview(infoButton)
        addSubview(border)
    }

    private func addConstraints() {
        label.constrain([
            label.constraint(.centerY, toView: self),
            label.constraint(.leading, toView: self, constant: Margins.large.rawValue) ])
        contentLabel.constrain([
            contentLabel.constraint(.leading, toView: label),
            contentLabel.constraint(toBottom: label),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Margins.small.rawValue) ])
        textField.constrain([
            textField.constraint(.leading, toView: label),
            textField.constraint(toBottom: label),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Margins.small.rawValue) ])
        tapView.constrain([
            tapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tapView.topAnchor.constraint(equalTo: topAnchor),
            tapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tapView.trailingAnchor.constraint(equalTo: trailingAnchor) ])
        infoButton.constrain([
            infoButton.constraint(.centerY, toView: self),
            infoButton.constraint(.trailing, toView: self, constant: -Margins.small.rawValue)])
        border.constrain([
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.bottomAnchor.constraint(equalTo: bottomAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1.0) ])
    }

    private func setInitialData() {
        guard let attributeDefintion = currency.attributeDefinition else { return }
        label.text = attributeDefintion.label
        textField.font = contentLabel.font
        textField.textColor = contentLabel.textColor
        textField.isHidden = true
        textField.returnKeyType = .done
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = attributeDefintion.keyboardType
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        label.textColor = LightColors.Text.one
        contentLabel.lineBreakMode = .byTruncatingMiddle

        textField.editingChanged = { [weak self] in
            guard let self = self else { return }
            self.contentLabel.text = self.textField.text
        }

        // GR to start editing label
        gr.addTarget(self, action: #selector(didTap))
        tapView.addGestureRecognizer(gr)
    }

    @objc private func didTap() {
        textField.becomeFirstResponder()
        contentLabel.isHidden = true
        textField.isHidden = false
    }
    
    @objc private func infoButtonTapped() {
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        let titleAttributes = [NSAttributedString.Key.font: Fonts.AlertActionSheet.title,
                               NSAttributedString.Key.foregroundColor: LightColors.Text.one]
        let titleString = NSAttributedString(string: L10n.Send.whatIsDestinationTag, attributes: titleAttributes)
        
        let messageAttributes = [NSAttributedString.Key.font: Fonts.AlertActionSheet.body,
                                 NSAttributedString.Key.foregroundColor: LightColors.Text.one]
        let message = L10n.Send.destinationTagText
        let messageString = NSAttributedString(string: message, attributes: messageAttributes)
        
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        
        let okAction = UIAlertAction(title: L10n.Button.ok, style: .default, handler: nil)
        alert.addAction(okAction)
        
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange() {
        guard let maxLength = currency.attributeDefinition?.maxLength else { return }
        guard let newText = textField.text, newText.utf8.count > maxLength else {
            textDidChange?(textField.text)
            return }
        textField.text = String(newText[newText.startIndex..<newText.index(newText.startIndex, offsetBy: maxLength)])
        textDidChange?(textField.text)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AttributeCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing?()
        contentLabel.isHidden = true
        gr.isEnabled = false
        tapView.isUserInteractionEnabled = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        contentLabel.isHidden = false
        textField.isHidden = true
        gr.isEnabled = true
        tapView.isUserInteractionEnabled = true
        contentLabel.text = textField.text
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
