import Foundation

// Gemini REST API Request/Response Structures
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent?
}

@MainActor
class PetService: ObservableObject {
    @Published var availableSpecies: [Species] = []
    @Published var adoptedPets: [Pet] = []
    @Published var speciesNews: [UUID: [NewsItem]] = [:]
    @Published var isTabBarHidden: Bool = false
    
    init() {
        loadMockData()
    }
    
    // Helper function to call Gemini REST API
    private func callGeminiAPI(prompt: String) async throws -> String {
        let modelName = "gemini-2.0-flash" 
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent?key=\(Secrets.apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let requestBody = GeminiRequest(contents: [
            GeminiContent(parts: [GeminiPart(text: prompt)])
        ])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Gemini API Error: \(String(data: data, encoding: .utf8) ?? "Unknown error")")
            throw URLError(.badServerResponse)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return geminiResponse.candidates?.first?.content?.parts.first?.text ?? "I have no words."
    }
    
    private func loadMockData() {
        let polarBear = Species(
            id: UUID(),
            name: "Polar Bear",
            scientificName: "Ursus maritimus",
            category: "Mammals",
            status: .vulnerable,
            description: "A large bear native to the Arctic, known for its white fur and dependence on sea ice.",
            habitat: "Arctic Circle, sea ice",
            population: "22,000-31,000",
            thumbnail: "Polar_Bear_thumbnail",
            avatar: "Polar_Bear_avatar",
            realisticPhotos: ["Polar_Bear_realistic"]
        )
        
        let giantPanda = Species(
            id: UUID(),
            name: "Giant Panda",
            scientificName: "Ailuropoda melanoleuca",
            category: "Mammals",
            status: .vulnerable,
            description: "A bear native to south central China. It is easily recognized by the large, distinctive black patches around its eyes, over the ears, and across its round body.",
            habitat: "Bamboo forests in mountains of central China",
            population: "1,864 in the wild",
            thumbnail: "Polar_Bear_thumbnail", // Placeholder
            avatar: "Polar_Bear_avatar", // Placeholder
            realisticPhotos: ["Polar_Bear_realistic"] // Placeholder
        )
        
        let seaTurtle = Species(
            id: UUID(),
            name: "Hawksbill Sea Turtle",
            scientificName: "Eretmochelys imbricata",
            category: "Marine",
            status: .criticallyEndangered,
            description: "A critically endangered sea turtle belonging to the family Cheloniidae. It is the only extant species in the genus Eretmochelys.",
            habitat: "Tropical reefs of Indian, Pacific, and Atlantic Oceans",
            population: "20,000 - 23,000 nesting females",
            thumbnail: "Polar_Bear_thumbnail", // Placeholder
            avatar: "Polar_Bear_avatar", // Placeholder
            realisticPhotos: ["Polar_Bear_realistic"] // Placeholder
        )
        
        let kakapo = Species(
            id: UUID(),
            name: "Kakapo",
            scientificName: "Strigops habroptilus",
            category: "Birds",
            status: .criticallyEndangered,
            description: "A nocturnal, flightless parrot with a distinct facial disc of sensory feather whiskers, a large grey beak, short legs, large feet, and wings and a tail of relatively short length.",
            habitat: "New Zealand",
            population: "252",
            thumbnail: "Polar_Bear_thumbnail", // Placeholder
            avatar: "Polar_Bear_avatar", // Placeholder
            realisticPhotos: ["Polar_Bear_realistic"] // Placeholder
        )

        availableSpecies = [polarBear, giantPanda, seaTurtle, kakapo]
        
        // Mock News
        speciesNews = [
            polarBear.id: [
                NewsItem(id: UUID(), title: "Sea Ice Extent Grows", content: "Recent satellite data shows a slight increase in Arctic sea ice extent this winter, providing more hunting grounds for polar bears.", date: Date(), sentiment: .positive, source: "Arctic Watch"),
                NewsItem(id: UUID(), title: "Warming Temperatures Concern", content: "Scientists warn that despite short-term gains, long-term warming trends continue to threaten polar bear habitats.", date: Date().addingTimeInterval(-86400), sentiment: .negative, source: "Climate Daily")
            ],
            giantPanda.id: [
                NewsItem(id: UUID(), title: "New Panda Park Opens", content: "A new national park dedicated to Giant Panda conservation has opened in China, connecting fragmented habitats.", date: Date(), sentiment: .positive, source: "Panda Conservation")
            ]
        ]
    }
    
    func adopt(species: Species, name: String) {
        guard !adoptedPets.contains(where: { $0.species.id == species.id }) else {
            return
        }

        let newPet = Pet(
            id: UUID(),
            species: species,
            name: name,
            persona: "I am a curious and shy \(species.name). I love my habitat and hope for a better future.",
            avatarURL: nil,
            happiness: 0.5,
            health: 0.8
        )
        adoptedPets.append(newPet)
    }
    
    func performAction(_ action: PetAction, for pet: Pet) {
        if let index = adoptedPets.firstIndex(where: { $0.id == pet.id }) {
            var updatedPet = adoptedPets[index]
            switch action {
            case .feed:
                updatedPet.health = min(1.0, updatedPet.health + 0.1)
                updatedPet.happiness = min(1.0, updatedPet.happiness + 0.05)
            case .play:
                updatedPet.happiness = min(1.0, updatedPet.happiness + 0.15)
                updatedPet.health = max(0.0, updatedPet.health - 0.05) // Playing tires them out?
            case .pat:
                updatedPet.happiness = min(1.0, updatedPet.happiness + 0.1)
            }
            adoptedPets[index] = updatedPet
        }
    }
    
    func getSuggestedActions(for sentiment: Sentiment) -> [SuggestedAction] {
        switch sentiment {
        case .negative:
            return [
                SuggestedAction(id: UUID(), title: "Spread Awareness", description: "Share this news on social media to educate others.", iconName: "megaphone.fill"),
                SuggestedAction(id: UUID(), title: "Donate to NGOs", description: "Support organizations working on the ground.", iconName: "heart.fill")
            ]
        case .positive:
            return [
                SuggestedAction(id: UUID(), title: "Celebrate", description: "Share the good news with your friends!", iconName: "star.fill")
            ]
        case .neutral:
            return [
                SuggestedAction(id: UUID(), title: "Stay Informed", description: "Keep tracking updates about your pet's species.", iconName: "info.circle")
            ]
        }
    }
    
    func generateAIResponse(for pet: Pet, userMessage: String) async -> String {
        let prompt = """
        You are \(pet.name), a \(pet.species.name) from \(pet.species.habitat). 
        Your persona is: \(pet.persona)
        The user says: "\(userMessage)"
        
        Respond as the pet in a way that reflects your species, habitat, and current status (\(pet.species.status.rawValue)). 
        Keep the response relatively short (1-3 sentences) and stay in character.
        """
        
        do {
            let responseText = try await callGeminiAPI(prompt: prompt)
            return responseText
        } catch {
            print("Error generating AI response: \(error)")
            return "Sorry, I'm having trouble thinking right now. Maybe we can chat later?"
        }
    }
    
    func generateGreeting(for pet: Pet) async -> String {
        // Find latest news for this species
        let newsList = speciesNews[pet.species.id] ?? []
        let latestNews = newsList.sorted(by: { $0.date > $1.date }).first
        
        let newsContext: String
        if let news = latestNews {
            newsContext = "Latest news headline: \"\(news.title)\". Sentiment: \(news.sentiment.rawValue)."
        } else {
            newsContext = "There is no specific recent news."
        }
        
        let prompt = """
        You are \(pet.name), a \(pet.species.name).
        Your current happiness is \(Int(pet.happiness * 100))%.
        \(newsContext)
        
        Write a short, single-sentence greeting (max 15 words) to display in a speech bubble to your owner.
        
        Rules:
        1. If the latest news is Negative, you MUST mention it briefly and sound sad or worried.
        2. If the latest news is Positive, sound excited about it.
        3. If there is no significant news, reflect your happiness level:
           - Low happiness (< 40%): Sound sad or ask for food/play.
           - High happiness (> 70%): Sound happy and energetic.
           - Medium happiness: Friendly and calm.
        """
        
        do {
            let responseText = try await callGeminiAPI(prompt: prompt)
            return responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Error generating greeting: \(error)")
            return "Hello friend!"
        }
    }
}
