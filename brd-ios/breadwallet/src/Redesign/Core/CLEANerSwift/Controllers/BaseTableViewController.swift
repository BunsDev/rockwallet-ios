// 
//  BaseTableViewController.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class BaseTableViewController<C: CoordinatableRoutes,
                              I: Interactor,
                              P: Presenter,
                              DS: BaseDataStore & NSObject>: VIPTableViewController<C, I, P, DS>,
                                                             FetchResponseDisplays {
    override var isRoundedBackgroundEnabled: Bool { return false }
    override var isModalDismissableEnabled: Bool { return true }
    override var dismissText: String { return L10n.Button.skip }
    override var closeImage: UIImage? { return Asset.close.image }
    
    // MARK: - Cleaner Swift setup
    
    lazy var continueButton: FEButton = {
        let view = FEButton()
        return view
    }()

    override func setupCloseButton(closeAction: Selector) {
        var closeButton: UIBarButtonItem = .init()
        
        if coordinator is AccountCoordinator
            && !self.isKind(of: RegistrationConfirmationViewController.self)
            && !self.isKind(of: DeleteProfileInfoViewController.self) {
            guard navigationItem.leftBarButtonItem?.title != dismissText,
                  navigationItem.rightBarButtonItem?.title != dismissText else { return }
            
            let attributes: [NSAttributedString.Key: Any] = [.font: Fonts.Subtitle.two,
                                                             .foregroundColor: LightColors.Text.three,
                                                             .underlineStyle: NSUnderlineStyle.single.rawValue]
            closeButton = UIBarButtonItem(title: dismissText, style: .plain, target: self, action: closeAction)
            closeButton.setTitleTextAttributes(attributes, for: .normal)
            closeButton.setTitleTextAttributes(attributes, for: .highlighted)
        } else {
            guard navigationItem.leftBarButtonItem?.image != closeImage,
                  navigationItem.rightBarButtonItem?.image != closeImage else { return }
            
            closeButton = UIBarButtonItem(image: closeImage,
                                          style: .plain,
                                          target: self,
                                          action: closeAction)
        }
        
        guard navigationItem.rightBarButtonItem == nil else {
            navigationItem.setLeftBarButton(closeButton, animated: false)
            return
        }
        
        closeButton.tintColor = (navigationController as? RootNavigationController)?.navigationBar.tintColor
        navigationItem.setRightBarButton(closeButton, animated: false)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.backgroundColor = LightColors.Background.one
        tableView.backgroundColor = .clear
        
        tableView.registerAccessoryView(WrapperAccessoryView<FELabel>.self)
        tableView.registerAccessoryView(WrapperAccessoryView<FEButton>.self)
        tableView.registerAccessoryView(WrapperAccessoryView<AssetView>.self)
        tableView.register(WrapperTableViewCell<FELabel>.self)
        tableView.register(WrapperTableViewCell<FEButton>.self)
        tableView.register(WrapperTableViewCell<FETextField>.self)
        tableView.register(WrapperTableViewCell<WrapperView<FEInfoView>>.self)
        tableView.register(WrapperTableViewCell<NavigationItemView>.self)
        tableView.register(WrapperTableViewCell<ProfileView>.self)
        tableView.register(WrapperTableViewCell<DoubleHorizontalTextboxView>.self) // TODO: Add validators
        tableView.register(WrapperTableViewCell<FEImageView>.self)
        tableView.register(WrapperTableViewCell<HorizontalButtonsView>.self)
        tableView.register(WrapperTableViewCell<ChecklistItemView>.self)
        tableView.register(WrapperTableViewCell<TickboxItemView>.self)
        tableView.register(WrapperTableViewCell<FESegmentControl>.self)
        tableView.register(WrapperTableViewCell<ExchangeRateView>.self)
        tableView.register(WrapperTableViewCell<DateView>.self)
        tableView.register(WrapperTableViewCell<TitleValueView>.self)
    }

    override func prepareData() {
        super.prepareData()
        (interactor as? FetchViewActions)?.getData(viewAction: .init())
    }

    // MARK: ResponseDisplay
    func displayData(responseDisplay: FetchModels.Get.ResponseDisplay) {
        sections = responseDisplay.sections
        sectionRows = responseDisplay.sectionRows
        
        // TODO: DiffableDataSource
        UIView.transition(with: tableView, duration: Presets.Animation.short.rawValue, options: .transitionCrossDissolve) { [weak self] in
            self?.tableView.reloadData()
        }
        
        tableView.backgroundView?.isHidden = !sections.isEmpty
        LoadingView.hide()
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let type = (sections[section] as? Sectionable)?.header
        return self.tableView(tableView, accessoryViewForType: type, for: section) { [weak self] in
            self?.tableView(tableView, didSelectHeaderIn: section)
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let type = (sections[section] as? Sectionable)?.footer
        return self.tableView(tableView, accessoryViewForType: type, for: section) { [weak self] in
            self?.tableView(tableView, didSelectFooterIn: section)
        }
    }

    // MARK: Headers/Footer dequeuing
    func tableView(_ tableView: UITableView, accessoryViewForType type: AccessoryType?, for section: Int, callback: @escaping (() -> Void)) -> UIView? {
        let view: UIView?
        switch type {
        case .plain(let string):
            view = self.tableView(tableView, supplementaryViewWith: string)
            view?.setupCustomMargins(vertical: .small, horizontal: .small)

        case .attributed(let attributedString):
            view = self.tableView(tableView, supplementaryViewWith: attributedString)
            view?.setupCustomMargins(vertical: .small, horizontal: .small)

        case .action(let title):
            view = self.tableView(tableView, supplementaryViewWith: title, for: section, callback: callback)
            view?.setupCustomMargins(vertical: .small, horizontal: .small)
            
        case .advanced(let icon, let title, let description):
            view = self.tableView(tableView, advancedSupplementaryViewWith: icon, title: title, description: description, for: section)

        default:
            view = UIView(frame: .zero)
        }

        return view
    }
    
    private func tableView(_ tableView: UITableView, supplementaryViewWith text: String?) -> UIView? {
        guard let view: WrapperAccessoryView<FELabel> = tableView.dequeueAccessoryView(),
              let text = text
        else { return UIView(frame: .zero) }

        view.setup { view in
            view.setup(with: .text(text))
            view.configure(with: .init(font: Fonts.Body.three, textColor: LightColors.Text.one))
        }

        return view
    }

    private func tableView(_ tableView: UITableView, supplementaryViewWith attributedText: NSAttributedString?) -> UIView? {
        guard let view: WrapperAccessoryView<FELabel> = tableView.dequeueAccessoryView(),
              let text = attributedText
        else { return UIView(frame: .zero) }

        view.setup { view in
            // TODO: attributed string support
            view.setup(with: .attributedText(text))
            view.configure(with: .init(font: Fonts.Body.three, textColor: LightColors.Text.one))
        }

        return view
    }

    private func tableView(_ tableView: UITableView, supplementaryViewWith buttonTitle: String?, for section: Int, callback: @escaping (() -> Void)) -> UIView? {
        // TODO: custom button (actionButton look alike?)
        guard let view: WrapperAccessoryView<FEButton> = tableView.dequeueAccessoryView(),
              let text = buttonTitle
        else { return UIView(frame: .zero) }

        view.setup { view in
            view.setup(with: .init(title: text))
            view.configure(with: Presets.Button.primary)
            // TODO: add callback to suplementaryViewTapped
        }

        return view
    }
    
    private func tableView(_ tableView: UITableView,
                           advancedSupplementaryViewWith icon: UIImage? = nil,
                           title: String? = nil,
                           description: String? = nil,
                           for section: Int) -> UIView? {
        guard let view: WrapperAccessoryView<AssetView> = tableView.dequeueAccessoryView()
        else { return UIView(frame: .zero) }
        
        view.setup { view in
            view.configure(with: Presets.AssetSelection.header)
        }
        view.setupCustomMargins(vertical: .small, horizontal: .large)

        return view
    }
    
    func tableView(_ tableView: UITableView, supplementaryViewTapped section: Int) {
        // TODO: override in class to handle suplementary button events
    }
    
    // MARK: Custom cells
    func tableView(_ tableView: UITableView, coverCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<FEImageView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? ImageViewModel
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.configure(with: Presets.Background.transparent)
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, labelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.three, textColor: LightColors.Text.two))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleLabelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Title.five, textColor: LightColors.Text.three))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleValueCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? TitleValueViewModel,
              let cell: WrapperTableViewCell<TitleValueView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.setupCustomMargins(vertical: .large, horizontal: .huge)
            view.axis = .vertical
            
            view.configure(with: .init(title: .init(font: Fonts.Subtitle.two,
                                                    textColor: LightColors.Text.three),
                                       value: .init(font: Fonts.Body.two,
                                                    textColor: LightColors.Text.two),
                                       shadow: Presets.Shadow.light,
                                       background: .init(backgroundColor: LightColors.Background.one,
                                                         border: .init(borderWidth: 0,
                                                                       cornerRadius: .medium))))
            view.setup(with: model)
        }
        
        cell.contentView.setupCustomMargins(vertical: .extraSmall, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, descriptionLabelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.two, textColor: LightColors.Text.two))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, buttonCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? ButtonViewModel,
              let cell: WrapperTableViewCell<FEButton> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: Presets.Button.primary)
            view.setup(with: model)
            view.setupCustomMargins(vertical: .large, horizontal: .large)
            view.snp.makeConstraints { make in
                make.height.equalTo(ViewSizes.Common.largeCommon.rawValue)
            }
            view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, buttonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? HorizontalButtonsViewModel,
              let cell: WrapperTableViewCell<HorizontalButtonsView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(background: Presets.Background.transparent,
                                       buttons: [Presets.Button.primary]))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, textFieldCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? TextFieldModel,
              let cell: WrapperTableViewCell<FETextField> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: Presets.TextField.primary)
            view.setup(with: model)
            
            view.beganEditing = { [weak self] field in
                self?.textFieldDidBegin(for: indexPath, with: field.text)
            }
            
            view.valueChanged = { [weak self] field in
                self?.textFieldDidUpdate(for: indexPath, with: field.text)
            }
            
            view.finishedEditing = { [weak self] field in
                self?.textFieldDidFinish(for: indexPath, with: field.text)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, infoViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? InfoViewModel,
              let cell: WrapperTableViewCell<WrapperView<FEInfoView>> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.setup { view in
                view.setup(with: model)
                view.configure(with: Presets.InfoView.verification)
                view.setupCustomMargins(all: .large)
            }
            view.setupCustomMargins(all: .large)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, navigationCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<NavigationItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? NavigationViewModel
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.configure(with: .init(image: .init(tintColor: LightColors.Text.three),
                                       label: .init(font: Fonts.Subtitle.one, textColor: LightColors.Text.three),
                                       button: Presets.Button.blackIcon))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, profileViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<ProfileView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? ProfileViewModel
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, checkmarkCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<ChecklistItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? ChecklistItemViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            view.setupCustomMargins(horizontal: .large)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, tickboxCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<TickboxItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? TickboxItemViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            view.setupCustomMargins(horizontal: .large)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, segmentControlCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<FESegmentControl> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? SegmentControlViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    // MARK: UserInteractions
    
    /// Override in subclass
    func textFieldDidBegin(for indexPath: IndexPath, with text: String?) {
    }
    
    /// Override in subclass
    func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        DispatchQueue.main.async {
            self.tableView.isScrollEnabled = false
            self.tableView.isScrollEnabled = true
        }
    }
    
    /// Override in subclass
    func textFieldDidUpdate(for indexPath: IndexPath, with text: String?) {
    }
    
    /// Override in subclass
    @objc func buttonTapped() {
        view.endEditing(true)
    }
}
