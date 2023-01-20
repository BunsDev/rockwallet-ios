// 
//  LimitsPopupView.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 20.1.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct LimitsPopupConfiguration: Configurable {
    var perTransaction: TitleValueConfiguration = Presets.TitleValue.common
    var dailyMin: TitleValueConfiguration = Presets.TitleValue.common
    var dailyMax: TitleValueConfiguration = Presets.TitleValue.common
    var weekly: TitleValueConfiguration = Presets.TitleValue.common
    var monthly: TitleValueConfiguration = Presets.TitleValue.common
}

struct LimitsPopupViewModel: ViewModel {
    var perTransaction: TitleValueViewModel
    var dailyMin: TitleValueViewModel
    var dailyMax: TitleValueViewModel
    var weekly: TitleValueViewModel
    var monthly: TitleValueViewModel
}

class LimitsPopupView: FEView<LimitsPopupConfiguration, LimitsPopupViewModel> {
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.large.rawValue
        return view
    }()
    
    private lazy var perTransactionView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var dailyMinView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var dailyMaxView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var weeklyView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var monthlyView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = LightColors.Outline.one
        return view
    }()
    
    private lazy var secondLineView: UIView = {
        let view = UIView()
        view.backgroundColor = LightColors.Outline.one
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(perTransactionView)
        perTransactionView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        mainStack.addArrangedSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.minimum.rawValue)
            make.leading.trailing.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(dailyMinView)
        dailyMinView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        mainStack.addArrangedSubview(dailyMaxView)
        dailyMaxView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        mainStack.addArrangedSubview(secondLineView)
        secondLineView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.minimum.rawValue)
            make.leading.trailing.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(weeklyView)
        weeklyView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        mainStack.addArrangedSubview(monthlyView)
        monthlyView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
    }
    
    override func configure(with config: LimitsPopupConfiguration?) {
        super.configure(with: config)
        
        perTransactionView.configure(with: config?.perTransaction)
        dailyMinView.configure(with: config?.dailyMin)
        dailyMaxView.configure(with: config?.dailyMax)
        weeklyView.configure(with: config?.weekly)
        monthlyView.configure(with: config?.monthly)
    }
    
    override func setup(with viewModel: LimitsPopupViewModel?) {
        super.setup(with: viewModel)
        
        perTransactionView.setup(with: viewModel?.perTransaction)
        dailyMinView.setup(with: viewModel?.dailyMin)
        dailyMaxView.setup(with: viewModel?.dailyMax)
        weeklyView.setup(with: viewModel?.weekly)
        monthlyView.setup(with: viewModel?.monthly)
    }
}
