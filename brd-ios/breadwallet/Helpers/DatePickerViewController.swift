// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

extension UIAlertController {
    /// Add a date picker
    ///
    /// - Parameters:
    ///   - mode: date picker mode
    ///   - date: selected date of date picker
    ///   - minimumDate: minimum date of date picker
    ///   - maximumDate: maximum date of date picker
    ///   - action: an action for datePicker value change
    
    public func addDatePicker(mode: UIDatePicker.Mode, date: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil) -> DatePickerViewController {
        let datePicker = DatePickerViewController(mode: mode, date: date, minimumDate: minimumDate, maximumDate: maximumDate)
        set(vc: datePicker, height: 217)
        return datePicker
    }
}

final public class DatePickerViewController: UIViewController {
    public typealias Action = (Date?) -> Void
    
    fileprivate var action: Action?
    
    fileprivate lazy var datePicker: UIDatePicker = { [unowned self] in
        $0.addTarget(self, action: #selector(DatePickerViewController.actionForDatePicker), for: .valueChanged)
        $0.preferredDatePickerStyle = .wheels
        return $0
    }(UIDatePicker())
    
    fileprivate var selectedDate = Date()

    required public init(mode: UIDatePicker.Mode, date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil) {
        super.init(nibName: nil, bundle: nil)
        datePicker.datePickerMode = mode
        datePicker.date = date ?? Date()
        selectedDate = datePicker.date
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
    }
    
    static func show(on viewController: UIViewController,
                     sourceView: UIView,
                     title: String?,
                     date: Date? = nil,
                     minimumDate: Date? = nil,
                     maximumDate: Date? = nil,
                     action: Action?) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = LightColors.Text.one
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.frame
        
        let pickerController = alert.addDatePicker(mode: .date, date: date, minimumDate: minimumDate, maximumDate: maximumDate)
        
        alert.addAction(UIAlertAction(title: L10n.Button.cancel, style: .cancel, handler: { _ in
            action?(nil)
        }))
        
        alert.addAction(UIAlertAction(title: L10n.Button.confirm, style: .default, handler: { _ in
            action?(pickerController.selectedDate)
        }))
        
        viewController.present(alert, animated: true)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func loadView() {
        let wrapper = UIView()
        wrapper.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.topAnchor.constraint(equalTo: wrapper.topAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor).isActive = true
        
        view = wrapper
    }
    
    @objc func actionForDatePicker() {
        selectedDate = datePicker.date
    }
    
    public func setDate(_ date: Date) {
        datePicker.setDate(date, animated: true)
    }
}
