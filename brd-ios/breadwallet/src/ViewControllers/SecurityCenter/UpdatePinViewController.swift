//
//  UpdatePinViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-16.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import LocalAuthentication
import WalletKit
import SwiftUI

enum UpdatePinType {
    case creationNoPhrase
    case creationWithPhrase
    case update
    case recoverBackup
}

class UpdatePinViewController: UIViewController, Subscriber {

    // MARK: - Public
    var setPinSuccess: ((String) -> Void)?
    var resetFromDisabledSuccess: ((String) -> Void)?
    var resetFromDisabledWillSucceed: (() -> Void)?
    var didRecoverAccount: ((Account) -> Void)?
    var didFailRecoverBackup: (() -> Void)?
    
    init(keyMaster: KeyMaster,
         type: UpdatePinType,
         showsBackButton: Bool = true,
         phrase: String? = nil,
         eventContext: EventContext = .none,
         backupKey: String? = nil) {
        self.keyMaster = keyMaster
        self.phrase = phrase
        self.pinView = PinView(style: .create, length: Store.state.pinLength)
        self.showsBackButton = showsBackButton
        self.type = type
        self.eventContext = eventContext
        self.backupKey = backupKey
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Private
    private let header = UILabel.wrapping(font: Fonts.Title.six, color: LightColors.Text.three)
    private let instruction = UILabel.wrapping(font: Fonts.Body.two, color: LightColors.Text.two)
    private let caption: UILabel = {
        let label = UILabel.wrapping(font: Fonts.Body.two, color: LightColors.Text.two)
        label.textAlignment = .center
        return label
    }()
        
    private let warning = UILabel.wrapping(font: Fonts.Body.two, color: LightColors.Text.two)
    private var pinView: PinView
    private let pinPadBackground = UIView(color: LightColors.Text.one)
    private let pinPad = PinPadViewController(style: .clear, keyboardType: .pinPad, maxDigits: 0, shouldShowBiometrics: false)
    private let spacer = UIView()
    private let keyMaster: KeyMaster
    private let backupKey: String?
    
    private lazy var faqButton = UIButton.buildHelpBarButton(articleId: ArticleIds.setPin, currency: nil, position: .right)
    
    private var shouldShowFAQButton: Bool {
        if type == .recoverBackup { return false }
        switch type {
        case .recoverBackup, .creationWithPhrase:
            return false
            
        case .creationNoPhrase:
            return true
            
        default:
            return eventContext != .onboarding
        }
    }
    
    private var step: Step = .verify {
        didSet {
            switch step {
            case .verify:
                instruction.text = isCreatingPin ? L10n.UpdatePin.createInstruction : L10n.UpdatePin.enterCurrent
                
            case .new:
                let instructionText = isCreatingPin ? L10n.UpdatePin.createInstruction : L10n.UpdatePin.enterNew
                header.text = isCreatingPin ? L10n.UpdatePin.setNewPinTitle : L10n.UpdatePin.createTitle
                if instruction.text != instructionText {
                    instruction.pushNewText(instructionText)
                }
                
            case .confirmNew:
                if isCreatingPin {
                    header.text = L10n.UpdatePin.createTitleConfirm
                } else {
                    instruction.pushNewText(L10n.UpdatePin.reEnterNew)
                }
            }
            
            caption.isHidden = step == .verify
        }
    }
    private var currentPin: String?
    private var newPin: String?
    private var phrase: String?
    private let type: UpdatePinType
    private var isCreatingPin: Bool { return type != .update }
    private let newPinLength = 6
    private let showsBackButton: Bool
    private var eventContext: EventContext = .none
    
    private enum Step {
        case verify
        case new
        case confirmNew
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shouldShowFAQButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: faqButton)
        }
        
        header.textAlignment = .center
        instruction.textAlignment = .center
        
        addSubviews()
        addConstraints()
        setData()
        setupBackButton()
    }

    private func addSubviews() {
        view.addSubview(header)
        view.addSubview(instruction)
        view.addSubview(caption)
        view.addSubview(pinView)
        view.addSubview(spacer)
        view.addSubview(pinPadBackground)
        view.addSubview(warning)
    }

    private func addConstraints() {
        let leftRightMargin: CGFloat = Margins.extraLarge.rawValue * 3
        header.constrain([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Margins.extraHuge.rawValue),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftRightMargin),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -leftRightMargin) ])
        instruction.constrain([
            instruction.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            instruction.topAnchor.constraint(equalTo: header.bottomAnchor, constant: Margins.large.rawValue),
            instruction.trailingAnchor.constraint(equalTo: header.trailingAnchor) ])
        pinView.constrain([
            pinView.centerYAnchor.constraint(equalTo: spacer.centerYAnchor),
            pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinView.widthAnchor.constraint(equalToConstant: pinView.width),
            pinView.heightAnchor.constraint(equalToConstant: ViewSizes.small.rawValue)])
        addPinPad()
        spacer.constrain([
            spacer.topAnchor.constraint(equalTo: instruction.bottomAnchor),
            spacer.bottomAnchor.constraint(equalTo: caption.topAnchor) ])
        caption.constrain([
            caption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftRightMargin),
            caption.bottomAnchor.constraint(equalTo: pinPad.view.topAnchor, constant: -Margins.extraExtraHuge.rawValue),
            caption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -leftRightMargin) ])
        warning.constrain([
            warning.topAnchor.constraint(equalTo: pinView.bottomAnchor, constant: Margins.large.rawValue),
            warning.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }

    private func addPinPad() {
        addChild(pinPad)
        pinPadBackground.addSubview(pinPad.view)
        pinPadBackground.constrain([
            pinPadBackground.widthAnchor.constraint(equalToConstant: floor(view.bounds.width/3.0)*3.0),
            pinPadBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinPadBackground.heightAnchor.constraint(equalToConstant: pinPad.height),
            pinPadBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) ])
        pinPad.view.constrain(toSuperviewEdges: nil)
        pinPad.didMove(toParent: self)
    }
    
    private func addCloudView() {
        guard type == .recoverBackup else { return }
        let hosting = UIHostingController(rootView: CloudBackupIcon(style: .down))
        view.addSubview(hosting.view)
        hosting.view.backgroundColor = .clear
        hosting.view.constrain([
            hosting.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hosting.view.topAnchor.constraint(equalTo: header.bottomAnchor, constant: Margins.huge.rawValue)
        ])
    }

    private func setData() {
        view.backgroundColor = LightColors.Background.one
        pinPad.ouputDidUpdate = { [weak self] text in
            guard let step = self?.step else { return }
            switch step {
            case .verify:
                self?.didUpdateForCurrent(pin: text)
            case .new:
                self?.didUpdateForNew(pin: text)
            case .confirmNew:
                self?.didUpdateForConfirmNew(pin: text)
            }
        }

        if type == .recoverBackup {
            header.text = L10n.CloudBackup.recoverHeader
            instruction.text = ""
            caption.text = ""
        } else {
            caption.text = L10n.UpdatePin.caption
            header.text = isCreatingPin ? L10n.UpdatePin.setNewPinTitle : L10n.UpdatePin.updateTitle
            instruction.text = isCreatingPin ? L10n.UpdatePin.createInstruction : L10n.UpdatePin.enterCurrent
            if isCreatingPin {
                step = .new
                caption.isHidden = false
                faqButton.tap = {
                    self.faqButtonPressed()
                }
            } else {
                caption.isHidden = true
            }
        }
        
        addCloudView()
    }
    
    func setupBackButton() {
        if !showsBackButton {
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = true
            
            return
        }
        
        let back = UIBarButtonItem(image: Asset.back.image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(backButtonPressed))
        back.tintColor = LightColors.Text.three
        navigationItem.leftBarButtonItem = back
    }
    
    @objc func backButtonPressed() {
        guard navigationController?.viewControllers.first == self else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        navigationController?.dismiss(animated: true)
    }
    
    func faqButtonPressed() {
        let model = PopupViewModel(title: .text(L10n.UpdatePin.Alert.title),
                                   body: L10n.UpdatePin.Alert.body,
                                   closeButton: .init(image: Asset.close.image))
        showInfoPopup(with: model, config: Presets.Popup.whiteCentered)
    }

    private func didUpdateForCurrent(pin: String) {
        pinView.fill(pin.utf8.count)
        if type == .recoverBackup {
            if pin.utf8.count == 6 {
                self.recoverBackupFor(pin: pin)
            }
        } else {
            if pin.utf8.count == Store.state.pinLength {
                if keyMaster.authenticate(withPin: pin) {
                    pushNewStep(.new)
                    currentPin = pin
                    replacePinView()
                } else {
                    if keyMaster.walletDisabledUntil > 0 {
                        dismiss(animated: true, completion: {
                            Store.perform(action: RequireLogin())
                        })
                    } else {
                        clearAfterFailure()
                    }
                }
            }
        }
    }
    
    private func recoverBackupFor(pin: String) {
        guard let backupKey = backupKey else { return }
        let result = keyMaster.unlockBackup(pin: pin, key: backupKey)
        switch result {
        case .success(let account):
            self.didRecoverAccount?(account)
        case .failure(let error):
            switch error {
            case UnlockBackupError.wrongPin(let retries):
                if retries < 5 {
                    warning.pushNewText(L10n.CloudBackup.pinAttempts("\(retries)"))
                    let retryCount = 3
                    if retries == retryCount {
                        let alert = UIAlertController(title: L10n.Alert.warning,
                                                      message: L10n.CloudBackup.warningBody("\(retryCount)"),
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: L10n.Button.ok, style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                    }
                } else {
                    warning.text = ""
                }
                clearAfterFailure()
            case UnlockBackupError.backupDeleted:
                caption.pushNewText(L10n.CloudBackup.backupDeleted)
                clearAfterFailure()
                let alert = UIAlertController(title: L10n.CloudBackup.backupDeleted,
                                              message: L10n.CloudBackup.backupDeletedMessage,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: L10n.Button.ok, style: .default, handler: { _ in exit(0) }))
                present(alert, animated: true, completion: nil)
            default:
                clearAfterFailure()
            }
        }
    }

    private func didUpdateForNew(pin: String) {
        pinView.fill(pin.utf8.count)
        if pin.utf8.count == newPinLength {
            newPin = pin
            pushNewStep(.confirmNew)
        }
    }

    private func didUpdateForConfirmNew(pin: String) {
        guard let newPin = newPin else { return }
        pinView.fill(pin.utf8.count)
        if pin.utf8.count == newPinLength {
            if pin == newPin {
                didSetNewPin()
            } else {
                if pin != newPin {
                    let model: InfoViewModel = .init(description: .text(L10n.UpdatePin.pinDoesntMatch), dismissType: .auto)
                    ToastMessageManager.shared.show(model: model,
                                                    configuration: Presets.InfoView.error)
                }
                
                clearAfterFailure()
                pushNewStep(.new)
            }
        }
    }

    private func clearAfterFailure() {
        pinPad.view.isUserInteractionEnabled = false
        pinView.shake { [weak self] in
            self?.pinPad.view.isUserInteractionEnabled = true
            self?.pinView.fill(0)
        }
        pinPad.clear()
    }

    private func replacePinView() {
        pinView.removeFromSuperview()
        pinView = PinView(style: .create, length: newPinLength)
        view.addSubview(pinView)
        pinView.constrain([
            pinView.centerYAnchor.constraint(equalTo: spacer.centerYAnchor),
            pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinView.widthAnchor.constraint(equalToConstant: pinView.width),
            pinView.heightAnchor.constraint(equalToConstant: ViewSizes.small.rawValue)])
    }

    private func pushNewStep(_ newStep: Step) {
        step = newStep
        pinPad.clear()
        DispatchQueue.main.asyncAfter(deadline: .now() + Presets.Delay.immediate.rawValue) { [weak self] in
            self?.pinView.fill(0)
        }
    }

    private func didSetNewPin() {
        guard let newPin = newPin else { return }
        
        var success = false
        if let seedPhrase = phrase {
            success = keyMaster.resetPin(newPin: newPin, seedPhrase: seedPhrase)
            
            GoogleAnalytics.logEvent(GoogleAnalytics.PinReset())
        } else if let currentPin = currentPin {
            success = keyMaster.changePin(newPin: newPin, currentPin: currentPin)
            DispatchQueue.main.async { Store.trigger(name: .didUpgradePin) }
        } else if type == .creationNoPhrase || type == .creationWithPhrase {
            success = keyMaster.setPin(newPin)
            
            GoogleAnalytics.logEvent(GoogleAnalytics.SetPin(onboarding: (eventContext == .onboarding).description, skipWriteDownKey: ""))
        }

        DispatchQueue.main.async {
            if success {
                if self.resetFromDisabledSuccess != nil {
                    self.resetFromDisabledWillSucceed?()
                    Store.perform(action: Alert.Show(.pinSet(callback: { [weak self] in
                        self?.presentResetPinSuccess(newPin: newPin)
                        
                        GoogleAnalytics.logEvent(GoogleAnalytics.PinResetCompleted())
                    })))
                } else {
                    let callback = { [weak self] in
                        guard let self = self else { return }
                        
                        self.setPinSuccess?(newPin)
                        
                        if self.type != .creationNoPhrase {
                            (self.parent ?? self)?.dismiss(animated: true)
                        }
                    }
                    
                    let type: AlertType
                    if self.type == .creationNoPhrase {
                        type = .pinSet(callback: callback)
                    } else {
                        type = .pinUpdated(callback: callback)
                    }
                    Store.perform(action: Alert.Show(type))
                }

            } else {
                let alert = UIAlertController(title: L10n.UpdatePin.updateTitle, message: L10n.UpdatePin.setPinError, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: L10n.Button.ok, style: .default, handler: { [weak self] _ in
                    self?.clearAfterFailure()
                    self?.pushNewStep(.new)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func presentResetPinSuccess(newPin: String) {
        dismiss(animated: true, completion: { [weak self] in
            self?.resetFromDisabledSuccess?(newPin)
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isCreatingPin ? .default : .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
