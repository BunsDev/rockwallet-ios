// 
//  BackupCodesView.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 24.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct BackupCodesViewConfiguration: Configurable {
    var backupCodes: [LabelConfiguration] = [LabelConfiguration(font: Fonts.Title.five,
                                                                textColor: LightColors.Text.three,
                                                                textAlignment: .center)]
}

struct BackupCodesViewModel: ViewModel {
    var backupCodes: [LabelViewModel] = []
}

class BackupCodesView: FEView<BackupCodesViewConfiguration, BackupCodesViewModel> {
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var backupCodeLabels: [FELabel] = []
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    override func setup(with viewModel: BackupCodesViewModel?) {
        super.setup(with: viewModel)
        
        setupBackupCodesView()
    }
    
    private func setupBackupCodesView() {
        guard let viewModel = viewModel, let config = config else { return }
        
        backupCodeLabels = []
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, model) in viewModel.backupCodes.enumerated() {
            let backupCodeLabel = FELabel()
            
            var labelConfig: LabelConfiguration?
            if index < config.backupCodes.count {
                labelConfig = config.backupCodes[index]
            } else {
                labelConfig = config.backupCodes.last
            }
            
            backupCodeLabel.configure(with: labelConfig)
            backupCodeLabel.setup(with: model)
            
            backupCodeLabels.append(backupCodeLabel)
            stack.addArrangedSubview(backupCodeLabel)
        }
        
        stack.layoutIfNeeded()
    }
}
