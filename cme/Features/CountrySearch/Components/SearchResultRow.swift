import SwiftUI

struct SearchResultRow: View {
    let country: Country
    let isAlreadySaved: Bool
    
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
            .frame(width: 50, height: 35)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(country.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    if let capital = country.capital {
                        Label(capital, systemImage: "building.2")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            if isAlreadySaved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.green)
            } else {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.vertical, 4)
        .opacity(isAlreadySaved ? 0.7 : 1.0)
    }
}