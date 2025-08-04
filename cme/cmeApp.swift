//
//  cmeApp.swift
//  cme
//
//  Created by Attia Elsayed on 04.08.25.
//

import SwiftUI

@main
struct cmeApp: App {
    @MainActor
    private let appConfig = AppConfiguration()
    
    var body: some Scene {
        WindowGroup {
            CountryListView(
                viewModel: CountryListViewModel(
                    repository: appConfig.countryRepository,
                    locationBootstrap: appConfig.locationBootstrapUseCase
                )
            )
        }
    }
}
