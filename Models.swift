import Foundation

enum SpeciesStatus: String, Codable {
    case criticallyEndangered = "Critically Endangered"
    case endangered = "Endangered"
    case vulnerable = "Vulnerable"
}

struct Species: Identifiable, Codable {
    let id: UUID
    let name: String
    let scientificName: String
    let category: String // Added category
    let status: SpeciesStatus
    let description: String
    let habitat: String
    let population: String
    let thumbnail: String
    let avatar: String
    let realisticPhotos: [String]
}

struct Pet: Identifiable, Codable {
    let id: UUID
    let species: Species
    let name: String
    let persona: String
    let avatarURL: URL?
    var happiness: Double = 0.5
    var health: Double = 0.8
}

enum Sentiment: String, Codable {
    case positive = "Positive"
    case neutral = "Neutral"
    case negative = "Negative"
}

struct NewsItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let date: Date
    let sentiment: Sentiment
    let source: String
    let url: String?
    let practicalTip: String?
}

enum AppTab {
    case home, favorites, chat, profile
}

struct SuggestedAction: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
}

enum PetAction {
    case feed, play, pat
}
