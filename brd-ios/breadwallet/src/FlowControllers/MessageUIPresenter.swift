//
//  MessageUIPresenter.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-11.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import MessageUI

class MessageUIPresenter: NSObject {

    weak var presenter: UIViewController?

    /** Allows the user to share a wallet address and QR code image using the iOS system share action sheet. */
    func presentShareSheet(text: String, image: UIImage) {
        let shareItems = [text, image] as [Any]
        let shareVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)

        shareVC.excludedActivityTypes = shareAddressExclusions
        present(shareVC)
    }
    
    // Returns (name, data) pairs for the available logfile attachments.
    private func getLogAttachments() -> [(String, Data)] {
        var attachments: [(String, Data)] = [(String, Data)]()
        
        // We include the previous log since it may provide clues about crashes etc. affecting
        // the current run of the app.
        if let previousLogData = try? Data(contentsOf: Constant.previousLogFilePath) {
            attachments.append(("brd_logs_previous.txt", previousLogData))
        }
        
        if let currentLogData = try? Data(contentsOf: Constant.logFilePath) {
            attachments.append(("brd_logs_current.txt", currentLogData))
        }
        
        return attachments
    }
    
    // Displays an email compose view controller, attaching the available console logs.
    func presentEmailLogs() {
        guard MFMailComposeViewController.canSendMail() else { showEmailUnavailableAlert(); return }
        
        let attachments = getLogAttachments()
        guard !attachments.isEmpty else { showErrorMessage(L10n.Settings.noLogsFound); return }
        
        originalTitleTextAttributes = UINavigationBar.appearance().titleTextAttributes
        UINavigationBar.appearance().titleTextAttributes = nil
        
        let emailView = MFMailComposeViewController()
        
        emailView.setToRecipients([Constant.feedbackEmail])
        emailView.setSubject("RockWallet Logs")
        emailView.setMessageBody("RockWallet Logs", isHTML: false)
        
        for attachment in attachments {
            let filename = attachment.0
            let data = attachment.1
            emailView.addAttachmentData(data, mimeType: "text/plain", fileName: filename)
        }
        
        emailView.mailComposeDelegate = self
        
        present(emailView)
    }
    
    func presentFeedbackCompose() {
        guard MFMailComposeViewController.canSendMail() else { showEmailUnavailableAlert(); return }
        originalTitleTextAttributes = UINavigationBar.appearance().titleTextAttributes
        UINavigationBar.appearance().titleTextAttributes = nil
        let emailView = MFMailComposeViewController()
        emailView.setToRecipients([Constant.feedbackEmail])
        emailView.mailComposeDelegate = self
        present(emailView)
    }

    func presentMailCompose(emailAddress: String, subject: String? = nil, body: String? = nil) {
        guard MFMailComposeViewController.canSendMail() else { showEmailUnavailableAlert(); return }
        originalTitleTextAttributes = UINavigationBar.appearance().titleTextAttributes
        UINavigationBar.appearance().titleTextAttributes = nil
        let emailView = MFMailComposeViewController()
        emailView.setToRecipients([emailAddress.replacingOccurrences(of: "%40", with: "@")])
        if let subject = subject {
            emailView.setSubject(subject)
        }
        if let body = body {
            emailView.setMessageBody(body, isHTML: false)
        }
        emailView.mailComposeDelegate = self
        present(emailView)
    }

    // MARK: - Private

    // Filters out the sharing options that don't make sense for sharing a wallet
    // address and QR code. `saveToCameraRoll` is excluded because it crashes
    // without adding `NSPhotoLibraryAddUsageDescription` to the plist.
    private var shareAddressExclusions: [UIActivity.ActivityType] {
        return [.airDrop, .openInIBooks, .addToReadingList, .saveToCameraRoll, .assignToContact]
    }

    private var originalTitleTextAttributes: [NSAttributedString.Key: Any]?

    private func present(_ viewController: UIViewController) {
        presenter?.view.isFrameChangeBlocked = true
        presenter?.present(viewController, animated: true, completion: {})
    }

    fileprivate func dismiss(_ viewController: UIViewController) {
        UINavigationBar.appearance().titleTextAttributes = originalTitleTextAttributes
        viewController.dismiss(animated: true, completion: {
            self.presenter?.view.isFrameChangeBlocked = false
        })
    }

    private func showEmailUnavailableAlert() {
        let alert = UIAlertController(title: L10n.ErrorMessages.emailUnavailableTitle, message: L10n.ErrorMessages.emailUnavailableMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Button.ok, style: .default, handler: nil))
        presenter?.present(alert, animated: true, completion: nil)
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: L10n.Alert.error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Button.ok, style: .default, handler: nil))
        presenter?.present(alert, animated: true, completion: nil)
    }
}

extension MessageUIPresenter: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(controller)
    }
}

extension MessageUIPresenter: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(controller)
    }
}
