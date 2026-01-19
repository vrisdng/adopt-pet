import SwiftUI

struct SelectionView: View {
    @EnvironmentObject var service: PetService
    @State private var selectedCategory: String = "All"
    
    let categories = ["All", "Mammals", "Marine", "Birds"]
    
    var filteredSpecies: [Species] {
        if selectedCategory == "All" {
            return service.availableSpecies
        } else {
            return service.availableSpecies.filter { species in
                species.category == selectedCategory
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.brandNeutral.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.brandPrimary)
                                    Text("Global Conservation")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Text("Protecting Species,\nOne Life at a Time!")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.brandAccent)
                            }
                            Spacer()
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: .black.opacity(0.05), radius: 5)
                                .overlay(Image(systemName: "magnifyingglass").foregroundColor(.brandAccent))
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Categories
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) {
                                    category in
                                    CategoryPill(text: category, isSelected: selectedCategory == category) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Adopt & Protect")
                                .font(.title3.bold())
                                .padding(.horizontal)
                            
                            ForEach(filteredSpecies) { // Use filteredSpecies here
                                species in
                                NavigationLink(destination: SpeciesDetailView(species: species)) {
                                    SpeciesCard(species: species)
                                }
                            }
                        }
                        .padding(.bottom, 100) // Space for floating tab bar
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                service.isTabBarHidden = false
            }
        }
    }
}

struct CategoryPill: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.brandPrimary : Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    Image(systemName: iconForCategory(text))
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .brandAccent)
                }
                
                Text(text)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .brandAccent : .gray)
            }
        }
    }
    
    func iconForCategory(_ category: String) -> String {
        switch category {
        case "All": return "square.grid.2x2"
        case "Mammals": return "hare"
        case "Marine": return "tortoise"
        case "Birds": return "bird"
        default: return "circle"
        }
    }
}

struct SpeciesCard: View {
    let species: Species
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Image(species.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(20)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(species.name)
                    .font(.title3.bold())
                    .foregroundColor(.brandAccent)
                
                Text(species.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.brandAlert)
                    Text(species.status.rawValue)
                        .font(.caption.bold())
                        .foregroundColor(.brandAlert)
                }
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}