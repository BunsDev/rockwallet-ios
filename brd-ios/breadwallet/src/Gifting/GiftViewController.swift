// 
//  GiftViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2020-11-20.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

class GiftViewController: BaseSendViewController {
    private let wallet: Wallet
    private let currency: Currency
    
    init(sender: Sender, wallet: Wallet, currency: Currency) {
        self.wallet = wallet
        self.currency = currency
        super.init(sender: sender)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let coinGeckoClient = CoinGeckoClient()
    private let gradientView = UIView()
    private let headerView = GiftHeaderView()
    private let qr = UIImageView(image: Asset.empty.image)
    private let header = UILabel.wrapping(font: Fonts.Title.one, color: LightColors.Contrast.two)
    private let subHeader = UILabel.wrapping(font: Fonts.Body.one, color: LightColors.Contrast.two.withAlphaComponent(0.85))
    private let amountHeader = UILabel(font: Fonts.Body.three, color: LightColors.Contrast.two)
    private let name = BorderedTextInput(placeholder: "Recipient's Name", keyboardType: .default)
    private let bottomBorder = UIView(color: .white)
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle(L10n.CreateGift.create, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
        return button
    }()
    private let toolbar = UIStackView()
    private var buttons: [(Double, UIButton)] = {
        return [25, 50, 100, 250, 500].map { amount in
            let button = UIButton()
            button.setTitle("$ \(amount)", for: .normal)
            button.tintColor = .white
            button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            button.layer.cornerRadius = 4
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
            return (Double(amount), button)
        }
    }()
    
    private var selectedIndex: Int = -1
    private let extraSwitch = UISwitch()
    private let extraLabel = UILabel.wrapping(font: Fonts.Body.three, color: .white)
    
    // State
    private var rate: SimplePrice?
    private var maximum: Amount?
    private var minimum: Amount?
    private var privKey: Key?
    private var address: Address?
    private var recipientName: String? { didSet { validate() }}
    private var selectedAmount: Amount? { didSet { validate() }}
    private var rawAmount: Double?
    private var gift: Gift?
    
    // For managing keyboard and scrollview offset
    var scrollOffset: CGFloat = 0
    var distance: CGFloat = 0
    
    override func viewDidLoad() {
        addSubviews()
        setupConstraints()
        setInitialData()
        subscribeToKeyboardNotifications()
    }
    
    private func addSubviews() {
        view.addSubview(gradientView)
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(qr)
        contentView.addSubview(header)
        contentView.addSubview(subHeader)
        contentView.addSubview(amountHeader)
        contentView.addSubview(toolbar)
        contentView.addSubview(name)
        contentView.addSubview(extraSwitch)
        contentView.addSubview(extraLabel)
        contentView.addSubview(bottomBorder)
        contentView.addSubview(createButton)
        addButtons()
    }
    
    private func setupConstraints() {
        gradientView.constrain(toSuperviewEdges: nil)
        headerView.constrain([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        scrollView.constrain([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        contentView.constrain([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)])
        qr.constrain([
            qr.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.extraHuge.rawValue),
            qr.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        header.constrain([
            header.topAnchor.constraint(equalTo: qr.bottomAnchor, constant: Margins.large.rawValue),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.custom(6)),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.custom(6))])
        subHeader.constrain([
            subHeader.topAnchor.constraint(equalTo: header.bottomAnchor, constant: Margins.large.rawValue),
            subHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            subHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue)])
        amountHeader.constrain([
            amountHeader.topAnchor.constraint(equalTo: subHeader.bottomAnchor, constant: Margins.large.rawValue),
            amountHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            amountHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue)])
        toolbar.constrain([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            toolbar.topAnchor.constraint(equalTo: amountHeader.bottomAnchor, constant: Margins.large.rawValue),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue),
            toolbar.heightAnchor.constraint(equalToConstant: 44.0)])
        name.constrain([
            name.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            name.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: Margins.large.rawValue),
            name.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue)])
        extraSwitch.constrain([
            extraSwitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            extraSwitch.topAnchor.constraint(equalTo: name.bottomAnchor, constant: Margins.large.rawValue),
            extraSwitch.widthAnchor.constraint(equalToConstant: 53.0) ])
        extraLabel.constrain([
            extraLabel.leadingAnchor.constraint(equalTo: extraSwitch.trailingAnchor, constant: Margins.small.rawValue),
            extraLabel.centerYAnchor.constraint(equalTo: extraSwitch.centerYAnchor),
            extraLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue)])
        bottomBorder.constrain([
            bottomBorder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBorder.topAnchor.constraint(equalTo: extraLabel.bottomAnchor, constant: Margins.huge.rawValue),
            bottomBorder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: 1.0)])
        createButton.constrain([
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            createButton.topAnchor.constraint(equalTo: bottomBorder.bottomAnchor, constant: Margins.huge.rawValue),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue),
            createButton.heightAnchor.constraint(equalToConstant: 44.0),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.extraHuge.rawValue)])
    }

    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIApplication.keyboardWillShowNotification,
                                               object: nil)
    }
    
    private func setInitialData() {
        fetchInitialData()
        header.text = "Send Bitcoin to someone\n even if they don't have a wallet."
        header.textAlignment = .center
        subHeader.text = """
            We'll create what's called a \"paper wallet\" with a QR code and instructions for installing BRD that you can email or text to friends and family
            """
        subHeader.textAlignment = .center
        amountHeader.text = "Choose amount ($USD)"
        toolbar.distribution = .fillEqually
        toolbar.spacing = 8.0
        extraSwitch.onTintColor = .white
        extraLabel.text = "add an additional $10 for import network fees"
        extraLabel.numberOfLines = 0
        extraLabel.lineBreakMode = .byWordWrapping
        createButton.tap = create
        createButton.setDisabled()
        
        name.didUpdate = { [weak self] output in
            self?.recipientName = output
        }
        
        scrollView.keyboardDismissMode = .onDrag
        extraLabel.numberOfLines = 0
        extraLabel.lineBreakMode = .byWordWrapping
        
        scrollView.clipsToBounds = true
        headerView.close.tap = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        disableExtraSwitch()
        disableAllButtons()
    }
    
    private func fetchInitialData() {
        let group = DispatchGroup()
        group.enter()
        let resource = Resources.simplePrice(ids: ["bitcoin"],
                                             vsCurrency: "usd",
                                             options: []) {  (result: Result<[SimplePrice], CoinGeckoError>) in
            group.leave()
            guard case .success(let data) = result else { return }
            self.rate = data.first
        }
        coinGeckoClient.load(resource)
        
        let result = wallet.createExportablePaperWallet()
        guard case .success(let paperWallet) = result else { return }
        guard let address = paperWallet.address else { return }
        guard let privKey = paperWallet.privateKey else { return }
        self.address = address
        self.privKey = privKey
        let feeLevel: FeeLevel = .regular
        group.enter()
        wallet.estimateLimitMaximum(address: address.description, fee: feeLevel, completion: { [weak self] result in
            group.leave()
            guard let self = self else { return }
            switch result {
            case .success(let maximumAmount):
                DispatchQueue.main.async {
                    self.maximum = Amount(cryptoAmount: maximumAmount, currency: self.currency)
                }
            case .failure(let error):
                print("[LIMIT] error: \(error)")
            }
        })
        
        group.enter()
        wallet.estimateLimitMinimum(address: address.description, fee: feeLevel) { [weak self] result in
            group.leave()
            guard let self = self else { return }
            switch result {
            case .success(let minimumAmount):
                DispatchQueue.main.async {
                    self.minimum = Amount(cryptoAmount: minimumAmount, currency: self.currency)
                }
            case .failure(let error):
                print("[LIMIT] error: \(error)")
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.setButtonStates()
        }
    }
    
    private func validate() {
        guard selectedAmount != nil else { createButton.setDisabled(); return }
        verifyExtraAmount()
        
        guard recipientName != nil && !recipientName!.isEmpty else { return }
        createButton.setEnabled()
    }
    
    private func setButtonStates() {
        guard let rate = rate else { return }
        guard let maximum = maximum, let minimum = minimum else {
            disableAllButtons()
            return }
        buttons.forEach {
            let btcAmount = round(100000000.0*$0.0/rate.price)/100000000.0
            let amount = Amount(tokenString: "\(btcAmount)", currency: currency)
            if amount > maximum || amount < minimum {
                $0.1.setDisabled()
            } else {
                $0.1.setEnabled()
            }
        }
    }
    
    private func disableAllButtons() {
        buttons.forEach { $0.1.setDisabled() }
    }
    
    private func enableAllButtons() {
        buttons.forEach { $0.1.setEnabled() }
    }
    
    private func create() {
        guard let address = address else { return }
        guard let privKey = privKey else { return }
        guard let rate = rate else { return }
        let comment = recipientName != nil ? "Gift to \(recipientName!)" : "Gift"
        name.textField.resignFirstResponder()

        guard let amount = extraSwitch.isOn ? totalWithExtra : selectedAmount else { return }

        sender.estimateFee(address: address.description, amount: amount, tier: .regular, isStake: false) { [weak self] result in
            switch result {
            case .success(let feeBasis):
                guard let self = self else { return }
                let feeCurrency = self.sender.wallet.feeCurrency
                let fee = Amount(cryptoAmount: feeBasis.fee, currency: feeCurrency)
                let rate = Rate(code: "USD", name: "USD", rate: rate.price, reciprocalCode: Constant.BTC)
                let displayAmount = Amount(amount: amount,
                                          rate: rate,
                                          maximumFractionDigits: Amount.highPrecisionDigits)
                let feeAmount = Amount(amount: fee,
                                       rate: rate,
                                       maximumFractionDigits: Amount.highPrecisionDigits)
                let gift = Gift.create(key: privKey,
                                       hash: nil,
                                       name: self.recipientName!,
                                       rate: rate.rate,
                                       amount: self.rawAmount!)
                self.gift = gift
                
                _ = self.sender.createTransaction(address: address.description,
                                                  amount: amount,
                                                  feeBasis: feeBasis,
                                                  comment: comment,
                                                  gift: gift)

                DispatchQueue.main.async {
                    let confirm = ConfirmationViewController(amount: displayAmount,
                                                             fee: feeAmount,
                                                             displayFeeLevel: .regular,
                                                             address: "Gift to \(self.recipientName!)",
                                                             currency: self.currency,
                                                             resolvedAddress: nil,
                                                             shouldShowMaskView: false)
                    confirm.successCallback = self.send
                    confirm.cancelCallback = self.sender.reset
                    self.present(confirm, animated: true, completion: nil)
                }

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func onSuccess() {
        super.onSuccess()
        
        guard let gift = self.gift else { return }
        let share = ShareGiftViewController(gift: gift)
        DispatchQueue.main.async {
            self.present(share, animated: true, completion: nil)
        }
    }
    
    private func verifyExtraAmount() {
        guard let maximum = maximum else { return }
        guard let totalExtra = totalWithExtra else { return }
        if totalExtra > maximum {
            disableExtraSwitch()
        } else {
            enableExtraSwitch()
        }
    }
    
    private var totalWithExtra: Amount? {
        guard let amount = selectedAmount else { return nil }
        guard let rate = rate else { return nil }
        let fiatValue = 10.0
        let extra = round(100000000.0*Double(fiatValue)/rate.price)/100000000.0
        let extraAmount = Amount(tokenString: "\(extra)", currency: currency)
        return amount + extraAmount
    }
    
    private func disableExtraSwitch() {
        extraSwitch.isOn = false
        extraSwitch.isEnabled = false
        extraSwitch.tintColor = UIColor.white.withAlphaComponent(0.2)
        extraLabel.textColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    private func enableExtraSwitch() {
        extraSwitch.isOn = false
        extraSwitch.isEnabled = true
        extraLabel.textColor = UIColor.white
    }
    
    private func addButtons() {
        for (index, button) in buttons.enumerated() {
            let button = button.1
            self.toolbar.addArrangedSubview(button)
            button.tap = {
                self.didTap(index: index)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//Handling User Input
extension GiftViewController {
    fileprivate func didTap(index: Int) {
        let selectedButton = buttons[index].1
        let previousSelectedButton: UIButton? = selectedIndex >= 0 ? buttons[selectedIndex].1 : nil
        
        //If unselecting current button
        guard selectedButton != previousSelectedButton else {
            selectedIndex = -1
            selectedAmount = nil
            selectedButton.setUnSelected()
            return
        }
        
        //Selecting a new button
        selectedIndex = index
        if let rate = rate {
            let fiatAmount = buttons[index].0
            let btcAmount = round(100000000.0*Double(fiatAmount)/rate.price)/100000000.0
            rawAmount = btcAmount
            selectedAmount = Amount(tokenString: "\(btcAmount)", currency: currency)
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            selectedButton.setSelected()
            previousSelectedButton?.setUnSelected()
        })

        if name.textField.text?.isEmpty ?? true {
            name.textField.becomeFirstResponder()
        }
    }

    @objc func keyboardWillShow(_ notification: Notification?) {
        let key = UIApplication.keyboardFrameEndUserInfoKey
        guard let frame = (notification?.userInfo?[key] as? NSValue)?.cgRectValue else {
            return
        }

        let keyboardFrame = scrollView.convert(frame, from: scrollView.window)
        let offset = CGPoint(x: scrollView.contentOffset.y,
                             y: createButton.frame.maxY - keyboardFrame.minY + Margins.large.rawValue)

        scrollView.setContentOffset(offset, animated: true)
    }
}

private extension UIButton {
    func setDisabled() {
        isEnabled = false
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = 4
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        tintColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    func setEnabled() {
        isEnabled = true
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = 4
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
        tintColor = .white
    }
    
    func setSelected() {
        backgroundColor = UIColor.white.withAlphaComponent(0.85)
        layer.cornerRadius = 4
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.cgColor
        tintColor = UIColor(hex: "FF7E47")
    }
    
    func setUnSelected() {
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = 4
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
        tintColor = .white
    }
}

// MARK: - Keyboard Notifications

extension GiftViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        var safeArea = view.frame
        safeArea.size.height += scrollView.contentOffset.y
        safeArea.size.height -= keyboardSize.height + (UIScreen.main.bounds.height*0.04)

        let field = name.textField
        let fieldFrame = field.convert(field.frame, to: view)
        
        if safeArea.contains(fieldFrame) {
            print("No need to Scroll")
            return
        } else {
            distance = fieldFrame.maxY - safeArea.size.height
            scrollOffset = scrollView.contentOffset.y
            self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset + distance), animated: true)
        }

        scrollView.isScrollEnabled = false
        presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if distance == 0 {
            return
        }
        self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
        scrollOffset = 0
        distance = 0
        scrollView.isScrollEnabled = true
        presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
    }
}
