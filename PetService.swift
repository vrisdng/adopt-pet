import Foundation

@MainActor
class PetService: ObservableObject {
    @Published var availableSpecies: [Species] = []
    @Published var adoptedPets: [Pet] = []
    @Published var speciesNews: [UUID: [NewsItem]] = [:]
    @Published var isTabBarHidden: Bool = false
    
    init() {
        loadMockData()
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
        // Mock AI Response with simple logic to simulate personality
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        let message = userMessage.lowercased()
        let greeting = ["hi", "hello", "hey", "greetings"]
        let howAreYou = ["how are you", "how are you doing", "how is it going"]
        let food = ["hungry", "food", "eat", "snack"]
        let play = ["play", "fun", "game", "bored"]
        
        if greeting.contains(where: { message.contains($0) }) {
            return "Hello friend! I am \(pet.name), the \(pet.species.name). It's good to see you!"
        } else if howAreYou.contains(where: { message.contains($0) }) {
            return "I am doing well, thanks for asking! Just thinking about my friends in the \(pet.species.habitat)."
        } else if food.contains(where: { message.contains($0) }) {
            return "I could go for a snack! Maybe something we find in the \(pet.species.habitat)?"
        } else if play.contains(where: { message.contains($0) }) {
            return "I love to play! But I also like to learn about how to protect my home. Do you want to learn a fun fact?"
        } else {
            // Default response using persona
            return "That is interesting! \(pet.persona) By the way, did you know that \(pet.species.population) of us are left in the wild?"
        }
    }
}
