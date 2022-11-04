//
//  StartImportViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-06-13.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import WalletKit

/**
 *  Screen that allows the user to scan a QR code corresponding to a private key.
 *
 *  It can be displayed in response to the "Redeem Private Key" menu item under Bitcoin
 *  preferences or in response to the user scanning a private key using the Scan QR Code
 *  item in the main menu. In the latter case, an initial QR code is passed to the init() method.
 */
class ImportKeyViewController: UIViewController, Subscriber {
    /**
     *  Initializer
     *
     *  walletManager - Bitcoin wallet manager
     *  initialQRCode - a QR code that was previously scanned, causing this import view controller to
     *                  be displayed
     */
    init(wallet: Wallet, initialQRCode: QRCode? = nil) {
        self.wallet = wallet
        self.initialQRCode = initialQRCode
        assert(wallet.currency.isBitcoin || wallet.currency.isBitcoinCash, "Importing only supports btc or bch")
        super.init(nibName: nil, bundle: nil)
    }

    private let wallet: Wallet
    private let header = RadialGradientView(backgroundColor: .blue, offset: 64.0)
    private let illustration = UIImageView(image: #imageLiteral(resourceName: "ImportIllustration"))
    private let message = UILabel.wrapping(font: .customBody(size: 16.0), color: .almostBlack)
    private let warning = UILabel.wrapping(font: .customBody(size: 16.0), color: .almostBlack)
    private let button = BRDButton(title: L10n.Import.scan, type: .primary)
    private let bullet = UIImageView(image: #imageLiteral(resourceName: "deletecircle"))
    private let leftCaption = UILabel.wrapping(font: .customMedium(size: 13.0), color: .darkText)
    private let rightCaption = UILabel.wrapping(font: .customMedium(size: 13.0), color: .darkText)
    private let balanceActivity = BRActivityViewController(message: L10n.Import.checking)
    private let importingActivity = BRActivityViewController(message: L10n.Import.importing)
    private let unlockingActivity = BRActivityViewController(message: L10n.Import.unlockingActivity)
    private var viewModel: (any TxViewModel)?
    
    // Previously scanned QR code passed to init()
    private var initialQRCode: QRCode?

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        addConstraints()
        setInitialData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let code = initialQRCode {
            handleScanResult(code)
            
            // Set this nil so that if the user tries to can another QR code via the
            // Scan Private Key button we don't end up trying to process the initial
            // code again. viewWillAppear() will get called again when the scanner/camera
            // is dismissed.
            initialQRCode = nil
        }
    }
    
    deinit {
        wallet.unsubscribe(self)
    }
    
    private func addSubviews() {
        view.addSubview(header)
        header.addSubview(illustration)
        header.addSubview(leftCaption)
        header.addSubview(rightCaption)
        view.addSubview(message)
        view.addSubview(button)
        view.addSubview(bullet)
        view.addSubview(warning)
    }

    private func addConstraints() {
        header.constrainTopCorners(sidePadding: 0, topPadding: 0)
        header.constrain([
            header.constraint(.height, constant: E.isIPhoneX ? 250.0 : 220.0) ])
        illustration.constrain([
            illustration.constraint(.width, constant: 64.0),
            illustration.constraint(.height, constant: 84.0),
            illustration.constraint(.centerX, toView: header),
            illustration.constraint(.centerY, toView: header, constant: E.isIPhoneX ? 4.0 : -Margins.small.rawValue) ])
        leftCaption.constrain([
            leftCaption.topAnchor.constraint(equalTo: illustration.bottomAnchor, constant: Margins.small.rawValue),
            leftCaption.trailingAnchor.constraint(equalTo: header.centerXAnchor, constant: -Margins.large.rawValue),
            leftCaption.widthAnchor.constraint(equalToConstant: 80.0)])
        rightCaption.constrain([
            rightCaption.topAnchor.constraint(equalTo: illustration.bottomAnchor, constant: Margins.small.rawValue),
            rightCaption.leadingAnchor.constraint(equalTo: header.centerXAnchor, constant: Margins.large.rawValue),
            rightCaption.widthAnchor.constraint(equalToConstant: 80.0)])
        message.constrain([
            message.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            message.topAnchor.constraint(equalTo: header.bottomAnchor, constant: Margins.large.rawValue),
            message.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue) ])
        bullet.constrain([
            bullet.leadingAnchor.constraint(equalTo: message.leadingAnchor),
            bullet.topAnchor.constraint(equalTo: message.bottomAnchor, constant: Margins.extraHuge.rawValue),
            bullet.widthAnchor.constraint(equalToConstant: 16.0),
            bullet.heightAnchor.constraint(equalToConstant: 16.0) ])
        warning.constrain([
            warning.leadingAnchor.constraint(equalTo: bullet.trailingAnchor, constant: Margins.large.rawValue),
            warning.topAnchor.constraint(equalTo: bullet.topAnchor),
            warning.trailingAnchor.constraint(equalTo: message.trailingAnchor) ])
        button.constrain([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.huge.rawValue),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Margins.extraHuge.rawValue),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.huge.rawValue),
            button.constraint(.height, constant: ViewSizes.Common.defaultCommon.rawValue) ])
    }

    private func setInitialData() {
        view.backgroundColor = .darkBackground
        illustration.contentMode = .scaleAspectFill
        message.text = L10n.Import.message
        leftCaption.text = L10n.Import.leftCaption
        leftCaption.textAlignment = .center
        rightCaption.text = L10n.Import.rightCaption
        rightCaption.textAlignment = .center
        warning.text = L10n.Import.warning

        // Set up the tap handler for the "Scan Private Key" button.
        button.tap = { [weak self] in
            guard let self = self else { return }
            let scan = ScanViewController(forScanningPrivateKeysOnly: true) { result in
                guard let result = result else { return }
                self.handleScanResult(result)
            }
            self.parent?.present(scan, animated: true, completion: nil)
        }
    }
    
    private func handleScanResult(_ result: QRCode) {
        switch result {
        case .privateKey(let key):
            didReceiveAddress(key)
        case .gift(let key, let model):
            didReceiveAddress(key)
            self.viewModel = model
        default:
            break
        }
    }

    private func didReceiveAddress(_ address: String) {
        guard !Key.isProtected(asPrivate: address) else {
            return unlock(address: address) { self.createTransaction(withPrivKey: $0) }
        }
        
        guard let key = Key.createFromString(asPrivate: address) else {
            showErrorMessage(L10n.Import.Error.notValid)
            return
        }

        createTransaction(withPrivKey: key)
        
    }
    
    private func createTransaction(withPrivKey key: Key) {
        present(balanceActivity, animated: true, completion: nil)
        wallet.createSweeper(forKey: key) { result in
            DispatchQueue.main.async {
                self.balanceActivity.dismiss(animated: true) {
                    switch result {
                    case .success(let sweeper):
                        self.importFrom(sweeper)
                    case .failure(let error):
                        self.handleError(error)
                    }
                }
            }
        }
    }
    
    private func importFrom(_ sweeper: WalletSweeper) {
        guard let balance = sweeper.balance else { return self.showErrorMessage(L10n.Import.Error.empty) }
        let balanceAmount = Amount(cryptoAmount: balance, currency: wallet.currency)
        guard !balanceAmount.isZero else { return self.showErrorMessage(L10n.Import.Error.empty) }
        sweeper.estimate(fee: wallet.feeForLevel(level: .regular)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let feeBasis):
                    self.confirmImport(fromSweeper: sweeper, fee: feeBasis)
                case .failure(let error):
                    self.handleEstimateFeeError(error)
                }
            }
        }
    }
    
    private func confirmImport(fromSweeper sweeper: WalletSweeper, fee: TransferFeeBasis) {
        let balanceAmount = Amount(cryptoAmount: sweeper.balance!, currency: wallet.currency)
        let feeAmount = Amount(cryptoAmount: fee.fee, currency: wallet.currency)
        let balanceText = "\(balanceAmount.fiatDescription) (\(balanceAmount.description))"
        let feeText = "\(feeAmount.fiatDescription)"
        let message = L10n.Import.confirm(balanceText, feeText)
        let alert = UIAlertController(title: L10n.Import.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Button.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: L10n.Import.importButton, style: .default, handler: { _ in
            self.present(self.importingActivity, animated: true)
            self.submit(sweeper: sweeper, fee: fee)
        }))
        present(alert, animated: true)
    }
    private func submit(sweeper: WalletSweeper, fee: TransferFeeBasis) {
        guard let transfer = sweeper.submit(estimatedFeeBasis: fee) else {
            importingActivity.dismiss(animated: true)
            return showErrorMessage(L10n.Alerts.sendFailure)
        }
        wallet.subscribe(self) { event in
            switch event {
            case .transferSubmitted(let eventTransfer, let success):
                guard eventTransfer.hash == transfer.hash,
                        success
                else {
                    return self.showErrorMessage(L10n.Import.Error.failedSubmit)
                }
                
                DispatchQueue.main.async {
                    self.importingActivity.dismiss(animated: true) {
                        self.markAsReclaimed()
                        self.showSuccess()
                    }
                }
                
            default:
                print("IMPORT: \(event.description)")
                return
                
            }
        }
        
        // TODO: quick (not) fix... basically we just dismiss loading, cause WK is not returning any event updates
        importingActivity.dismiss(animated: true) {
            self.markAsReclaimed()
            self.showSuccess()
        }
    }
    
    private func markAsReclaimed() {
        guard let kvStore = Backend.kvStore else { return assertionFailure() }
        guard let viewModel = viewModel else { return assertionFailure() }
        guard let gift = viewModel.gift else { return assertionFailure() }
        let newGift = Gift(shared: gift.shared,
                           claimed: gift.claimed,
                           reclaimed: true,
                           txnHash: gift.txnHash,
                           keyData: gift.keyData,
                           name: gift.name,
                           rate: gift.rate,
                           amount: gift.amount)
        viewModel.tx?.updateGiftStatus(gift: newGift, kvStore: kvStore)
        if let hash = newGift.txnHash {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Store.trigger(name: .txMetaDataUpdated(hash))
            }
        }
        
    }
    
    private func handleError(_ error: WalletSweeperError) {
        switch error {
        case .unsupportedCurrency:
            showErrorMessage(L10n.Import.Error.unsupportedCurrency)
        case .invalidKey:
            showErrorMessage(L10n.Send.invalidAddressTitle)
        case .invalidSourceWallet:
            showErrorMessage(L10n.Send.invalidAddressTitle)
        case .insufficientFunds:
            showErrorMessage(L10n.Send.insufficientFunds)
        case .unableToSweep:
            showErrorMessage(L10n.Import.Error.sweepError)
        case .noTransfersFound:
            showErrorMessage(L10n.Import.Error.empty)
        case .unexpectedError:
            showErrorMessage(L10n.Alert.somethingWentWrong)
        case .clientError(let error):
            showErrorMessage(error.localizedDescription)
        }
    }
    
    private func handleEstimateFeeError(_ error: WalletKit.Wallet.FeeEstimationError) {
        switch error {
        case .InsufficientFunds:
            showErrorMessage(L10n.Send.insufficientFunds)
        case .ServiceError:
            showErrorMessage(L10n.Import.Error.serviceError)
        case .ServiceUnavailable:
            showErrorMessage(L10n.Import.Error.serviceUnavailable)
        }
    }

    private func unlock(address: String, callback: @escaping (Key) -> Void) {
        let alert = UIAlertController(title: L10n.Import.title, message: L10n.Import.password, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = L10n.Import.passwordPlaceholder
            textField.isSecureTextEntry = true
            textField.returnKeyType = .done
        })
        alert.addAction(UIAlertAction(title: L10n.Button.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: L10n.Button.ok, style: .default, handler: { _ in
            self.unlock(alert: alert, address: address, callback: callback)
        }))
        present(alert, animated: true)
    }
    
    private func unlock(alert: UIAlertController, address: String, callback: @escaping (Key) -> Void) {
        present(self.unlockingActivity, animated: true, completion: {
            guard let password = alert.textFields?.first?.text,
                let key = Key.createFromString(asPrivate: address, withPassphrase: password) else {
                self.unlockingActivity.dismiss(animated: true, completion: {
                    self.showErrorMessage(L10n.Import.wrongPassword)
                })
                return
            }
            self.unlockingActivity.dismiss(animated: true, completion: {
                callback(key)
            })
        })
    }

    private func showSuccess() {
        Store.perform(action: Alert.Show(.sweepSuccess(callback: { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        })))
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
