import Foundation

struct CountryDTOFixtures {
    static let validCountryJSON = """
    {
        "name": "Germany",
        "capital": "Berlin",
        "currencies": [
            {
                "code": "EUR",
                "name": "Euro",
                "symbol": "€"
            }
        ],
        "alpha2Code": "DE",
        "flags": {
            "png": "https://flagcdn.com/w320/de.png",
            "svg": "https://flagcdn.com/de.svg"
        }
    }
    """.data(using: .utf8)!
    
    static let countryWithMultipleCurrenciesJSON = """
    {
        "name": "Switzerland",
        "capital": "Bern",
        "currencies": [
            {
                "code": "CHF",
                "name": "Swiss franc",
                "symbol": "Fr."
            },
            {
                "code": "EUR",
                "name": "Euro",
                "symbol": "€"
            }
        ],
        "alpha2Code": "CH",
        "flags": {
            "png": "https://flagcdn.com/w320/ch.png",
            "svg": "https://flagcdn.com/ch.svg"
        }
    }
    """.data(using: .utf8)!
    
    static let countryWithoutCapitalJSON = """
    {
        "name": "Antarctica",
        "currencies": [],
        "alpha2Code": "AQ",
        "flags": {
            "png": "https://flagcdn.com/w320/aq.png",
            "svg": "https://flagcdn.com/aq.svg"
        }
    }
    """.data(using: .utf8)!
    
    static let countryWithoutCurrenciesJSON = """
    {
        "name": "United States",
        "capital": "Washington, D.C.",
        "alpha2Code": "US",
        "flags": {
            "png": "https://flagcdn.com/w320/us.png",
            "svg": "https://flagcdn.com/us.svg"
        }
    }
    """.data(using: .utf8)!
    
    static let countryArrayJSON = """
    [
        {
            "name": "Germany",
            "capital": "Berlin",
            "currencies": [
                {
                    "code": "EUR",
                    "name": "Euro",
                    "symbol": "€"
                }
            ],
            "alpha2Code": "DE",
            "flags": {
                "png": "https://flagcdn.com/w320/de.png",
                "svg": "https://flagcdn.com/de.svg"
            }
        },
        {
            "name": "United States",
            "capital": "Washington, D.C.",
            "currencies": [
                {
                    "code": "USD",
                    "name": "United States dollar",
                    "symbol": "$"
                }
            ],
            "alpha2Code": "US",
            "flags": {
                "png": "https://flagcdn.com/w320/us.png",
                "svg": "https://flagcdn.com/us.svg"
            }
        }
    ]
    """.data(using: .utf8)!
    
    static let invalidJSON = """
    {
        "invalid": "json structure"
    }
    """.data(using: .utf8)!
    
    static let malformedJSON = "not a valid json".data(using: .utf8)!
}