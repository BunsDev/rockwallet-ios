// 
//  AlertPresenter.swift
//  breadwallet
//
//  Created by Ray Vander Veen on 2019-09-05.
//  Copyright © 2019 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class AlertPresenter: Subscriber {
    private let window: UIWindow
    private let alertHeight: CGFloat = 260.0
    
    private var topViewController: UIViewController? {
        var viewController = window.rootViewController
        if let nc = viewController as? UINavigationController {
            viewController = nc.topViewController
        }
        while viewController?.presentedViewController != nil {
            viewController = viewController?.presentedViewController
        }
        return viewController
    }
    
    init(window: UIWindow) {
        self.window = window

        addSubscriptions()
    }
    
    private func addSubscriptions() {
        Store.subscribe(self, name: .showAlert(nil), callback: { [weak self] in
            guard let trigger = $0 else { return }
            if case let .showAlert(alert) = trigger {
                if let alert = alert {
                    self?.topViewController?.present(alert, animated: true, completion: nil)
                }
            }
        })
        
        Store.lazySubscribe(self,
                            selector: { $0.alert != $1.alert && $1.alert != .none },
                            callback: { [weak self] in self?.handleAlertChange($0.alert) })
    }
    
    private func handleAlertChange(_ type: AlertType) {
        guard type != .none else { return }
        presentAlert(type, completion: {
            Store.perform(action: Alert.Hide())
        })
    }

    func presentAlert(_ type: AlertType, completion: @escaping () -> Void) {
        let alertView = AlertView(type: type)
        guard let window = UIApplication.shared.activeWindow else { return }
        let size = window.bounds.size
        window.addSubview(alertView)
        
        let topConstraint = alertView.constraint(.top, toView: window, constant: size.height)
        alertView.constrain([
            alertView.constraint(.width, constant: size.width),
            alertView.constraint(.height, constant: alertHeight + 25.0),
            alertView.constraint(.leading, toView: window, constant: nil),
            topConstraint ])
        window.layoutIfNeeded()
        
        UIView.spring(0.6, animations: {
            topConstraint?.constant = size.height - self.alertHeight
            window.layoutIfNeeded()
        }, completion: { _ in
            alertView.animate()
            UIView.spring(0.6, delay: 2.0, animations: {
                topConstraint?.constant = size.height
                window.layoutIfNeeded()
            }, completion: { _ in
                switch type {
                case .paperKeySet(let callback),
                        .pinSet(let callback),
                        .pinUpdated(let callback),
                        .sweepSuccess(let callback),
                        .cloudBackupRestoreSuccess(let callback),
                        .walletRestored(let callback),
                        .walletUnlinked(callback: let callback),
                        .recoveryPhraseConfirmed(callback: let callback):
                    callback()
                    
                default:
                    break
                }
                completion()
                alertView.removeFromSuperview()
            })
        })
    }
}
