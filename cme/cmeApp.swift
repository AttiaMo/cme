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
            RootView(appConfig: appConfig)
        }
    }
}

@MainActor
struct RootView: View {
    let appConfig: AppConfiguration
    @State private var viewModel: CountryListViewModel
    
    init(appConfig: AppConfiguration) {
        self.appConfig = appConfig
        let vm = CountryListViewModel(
            repository: appConfig.countryRepository,
            locationBootstrap: appConfig.locationBootstrapUseCase
        )
        self._viewModel = State(initialValue: vm)
    }
    
    var body: some View {
        CountryListView(viewModel: viewModel)
    }
}
