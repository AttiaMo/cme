import SwiftUI

struct CountryRowView: View {
    let country: Country
    
    var body: some View {
        HStack(spacing: 12) {
            // Flag image
            AsyncImage(url: country.flagPNGUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(country.displayCapital)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if let firstCurrency = country.currencies.first {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(firstCurrency.code)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}