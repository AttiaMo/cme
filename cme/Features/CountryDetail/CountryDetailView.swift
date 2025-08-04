import SwiftUI

struct CountryDetailView: View {
    let country: Country
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Flag Section
                flagSection
                
                // Country Info Section
                VStack(alignment: .leading, spacing: 20) {
                    // Capital Section
                    capitalSection
                    
                    Divider()
                    
                    // Currencies Section
                    currenciesSection
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var flagSection: some View {
        AsyncImage(url: country.flagPNGUrl) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        ProgressView()
                    }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
            case .failure:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxHeight: 250)
        .padding()
    }
    
    private var capitalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Capital", systemImage: "building.2.crop.circle")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(country.displayCapital)
                .font(.title2)
                .fontWeight(.medium)
        }
    }
    
    private var currenciesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Currencies", systemImage: "banknote.circle")
                .font(.headline)
                .foregroundStyle(.primary)
            
            if country.currencies.isEmpty {
                Text("No currency information available")
                    .font(.body)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(country.currencies, id: \.code) { currency in
                    CurrencyCard(currency: currency)
                }
            }
        }
    }
}

struct CurrencyCard: View {
    let currency: Currency
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(currency.name)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Spacer()
                
                if let symbol = currency.symbol {
                    Text(symbol)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)
                }
            }
            
            Text(currency.code)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}