import Foundation

struct Quote: Codable, Identifiable {
    let id: Int
    let text: String
}

class QuoteManager: ObservableObject {
    static let shared = QuoteManager()
    
    @Published var dailyQuote: Quote?
    
    private init() {
        loadQuotes()
    }
    
    private func loadQuotes() {
        guard let url = Bundle.main.url(forResource: "Quotes", withExtension: "json") else {
            print("Quotes.json not found in Bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let quotes = try JSONDecoder().decode([Quote].self, from: data)
            self.dailyQuote = selectDailyQuote(from: quotes)
        } catch {
            print("Error decoding quotes: \(error)")
        }
    }
    
    private func selectDailyQuote(from quotes: [Quote]) -> Quote? {
        guard !quotes.isEmpty else { return nil }
        
        let date = Date()
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        
        // Use the day of the year to select a quote index
        // Subtract 1 because array is 0-indexed, but dayOfYear starts at 1
        let index = (dayOfYear - 1) % quotes.count
        return quotes[index]
    }
}
