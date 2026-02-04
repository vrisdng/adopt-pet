import SwiftUI

struct SpeciesDetailView: View {
    let species: Species
    @EnvironmentObject var service: PetService
        @State private var petName: String = ""
        @State private var showingAdoptionAlert = false
        @State private var showingNamePrompt = false
        @State private var alreadyAdopted = false
        @State private var adoptedPet: Pet?
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            ZStack(alignment: .bottom) {
                Color.brandNeutral.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Map/Image Area
                        ZStack(alignment: .topLeading) {
                            Image(species.avatar)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 350)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .overlay(
                                    LinearGradient(colors: [.black.opacity(0.3), .clear], startPoint: .top, endPoint: .center)
                                )
                            
                            Button(action: { dismiss() }) {
                                Image(systemName: "arrow.left")
                                    .font(.headline)
                                    .foregroundColor(.brandAccent)
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding(.leading, 20)
                            .padding(.top, 60)
                        }
                        
                        // Info Card
                        VStack(alignment: .leading, spacing: 20) {
                            // Header Info
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(species.name)
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.brandAccent)
                                    
                                    Text(species.scientificName)
                                        .font(.subheadline)
                                        .italic()
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                Image(systemName: "heart.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.brandSecondary)
                            }
                            
                            // Pills
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    StatusPill(text: species.status.rawValue, isDark: true)
                                    StatusPill(text: "Wild", isDark: false)
                                    StatusPill(text: "Protected", isDark: false)
                                }
                            }
                            
                            // Gallery
                            TabView {
                                ForEach(species.realisticPhotos, id: \.self) { photo in
                                    Image(photo)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 280, height: 200)
                                        .clipped()
                                        .cornerRadius(16)
                                }
                            }
                            .frame(height: 200)
                            .tabViewStyle(PageTabViewStyle())
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline)
                                    .foregroundColor(.brandBlack)
                                
                                Text(species.description)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            // Habitat & Population
                            HStack(spacing: 30) {
                                VStack(alignment: .leading) {
                                    Text("Habitat")
                                        .font(.caption.bold())
                                        .foregroundColor(.brandPrimary)
                                    Text(species.habitat)
                                        .font(.subheadline)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Population")
                                        .font(.caption.bold())
                                        .foregroundColor(.brandPrimary)
                                    Text(species.population)
                                        .font(.subheadline)
                                }
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(40, corners: [.topLeft, .topRight])
                        .offset(y: -40)
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // Bottom Sticky Button
                VStack {
                    Spacer()
                    HStack(spacing: 16) {
                        Button(action: {
                            // Favorite action placeholder
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(16)
                                .background(Color.brandPrimary)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            showingNamePrompt = true
                        }) {
                            Text(alreadyAdopted ? "Already Adopted" : "Adopt Now")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(alreadyAdopted ? Color.gray : Color.brandPrimary)
                                .cornerRadius(30)
                        }
                        .disabled(alreadyAdopted)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    .background(
                        LinearGradient(colors: [.white.opacity(0), .white], startPoint: .top, endPoint: .bottom)
                            .padding(.top, -20)
                    )
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                service.isTabBarHidden = true
                alreadyAdopted = service.adoptedPets.contains(where: { $0.species.id == species.id })
            }
            .alert("Name your new friend", isPresented: $showingNamePrompt) {
                TextField("Enter name", text: $petName)
                Button("Adopt") {
                    if let newPet = service.adopt(species: species, name: petName.isEmpty ? species.name : petName) {
                        withAnimation {
                            adoptedPet = newPet
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .overlay {
                if let pet = adoptedPet {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        
                        VStack(spacing: 24) {
                            Image(pet.species.thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                            
                            VStack(spacing: 8) {
                                Text("Thank you for being my friend!")
                                    .font(.title3.bold())
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.brandAccent)
                                
                                Text("I promise to be a good \(pet.species.name).")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: { dismiss() }) {
                                Text("Yay!")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 120)
                                    .padding()
                                    .background(Color.brandPrimary)
                                    .cornerRadius(30)
                            }
                        }
                        .padding(30)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(radius: 20)
                        .padding(.horizontal, 40)
                    }
                }
            }
    }
}

struct StatusPill: View {
    let text: String
    let isDark: Bool
    
    var body: some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isDark ? Color.brandAccent : Color.brandNeutral)
            .foregroundColor(isDark ? .white : .brandAccent)
            .cornerRadius(20)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
