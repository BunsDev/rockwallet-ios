// 
//  Presets+Veriff.swift
//  breadwallet
//
//  Created by Rok on 20/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import Veriff

extension Presets {
    static var veriff: VeriffSdk.Configuration {
        let branding = VeriffSdk.Branding()
        branding.backgroundColor = LightColors.Background.one
        branding.primaryTextColor = LightColors.Text.three
        branding.secondaryTextColor = LightColors.Text.one
        branding.primaryButtonBackgroundColor = LightColors.primary
        branding.buttonCornerRadius = CornerRadius.large.rawValue * 5
        branding.bulletPoint = .init(named: "bullet") // TODO: due to naming clash.. refactor in the future?
        branding.font = VeriffSdk.Branding.Font(regularFontName: Fonts.Secondary,
                                                lightFontName: Fonts.Secondary,
                                                semiBoldFontName: Fonts.Tertiary,
                                                boldFontName: Fonts.Primary)
        let locale = Locale.current
        
        return .init(branding: branding, languageLocale: locale)
    }
}
