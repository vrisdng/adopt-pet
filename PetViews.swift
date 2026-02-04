import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ChatView: View {
    let pet: Pet
    @EnvironmentObject var service: PetService
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    @State private var isTyping = false
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            HStack(alignment: .bottom, spacing: 8) {
                                if message.isUser { Spacer() }

                                if !message.isUser {
                                    Image(pet.species.avatar)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                }

                                Text(message.text)
                                    .padding(12)
                                    .background(message.isUser ? Color.brandPrimary : Color(.systemGray6))
                                    .foregroundColor(message.isUser ? .white : .primary)
                                    .cornerRadius(16)
                                    .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)

                                if !message.isUser { Spacer() }
                            }
                            .id(message.id)
                        }
                        
                        if isTyping {
                            HStack {
                                Text("\(pet.name) is thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            
            HStack {
                TextField("Message \(pet.name)...", text: $newMessage)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.brandPrimary)
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .navigationTitle(pet.name)
        .onAppear {
            service.isTabBarHidden = true
            if messages.isEmpty {
                messages.append(Message(text: "Hi! I'm \(pet.name), your \(pet.species.name). \(pet.persona)", isUser: false))
            }
        }
    }
    
    private func sendMessage() {
        let text = newMessage
        newMessage = ""
        messages.append(Message(text: text, isUser: true))
        
        isTyping = true
        Task {
            let response = await service.generateAIResponse(for: pet, userMessage: text)
            messages.append(Message(text: response, isUser: false))
            isTyping = false
        }
    }
}

struct PetProfileView: View {
    let petId: UUID
    @EnvironmentObject var service: PetService
    @State private var greeting: String?
    
    var pet: Pet? {
        service.adoptedPets.first(where: { $0.id == petId })
    }
    
    var body: some View {
        Group {
            if let pet = pet {
                ScrollView {
                    VStack(spacing: 24) {
                        // AI Avatar Placeholder
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(Color.brandPrimary.opacity(0.1))
                                .frame(width: 150, height: 150)

                            Image(pet.species.avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                            
                            if let greeting = greeting {
                                Text(greeting)
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.white)
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                    .frame(width: 140)
                                    .offset(x: 40, y: -20)
                            }
                        }
                        .padding(.top)
                        
                        VStack(spacing: 8) {
                            Text(pet.name)
                                .font(.largeTitle.bold())
                            Text(pet.species.name)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        // Stats
                        HStack(spacing: 20) {
                            VStack {
                                Text("Happiness")
                                    .font(.caption)
                                ProgressView(value: pet.happiness)
                                    .tint(.brandPrimary)
                            }
                            VStack {
                                Text("Health")
                                    .font(.caption)
                                ProgressView(value: pet.health)
                                    .tint(.brandSecondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Actions
                        HStack(spacing: 30) {
                            ActionButton(icon: "fork.knife", text: "Feed") {
                                service.performAction(.feed, for: pet)
                            }
                            ActionButton(icon: "figure.play", text: "Play") {
                                service.performAction(.play, for: pet)
                            }
                            ActionButton(icon: "hand.wave", text: "Pat") {
                                service.performAction(.pat, for: pet)
                            }
                        }
                        .padding(.vertical)
                        
                        HStack(spacing: 20) {
                            NavigationLink(destination: ChatView(pet: pet)) {
                                VStack {
                                    Image(systemName: "message.fill")
                                        .font(.title)
                                    Text("Chat")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brandPrimary.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            NavigationLink(destination: SpeciesNewsView(species: pet.species)) {
                                VStack {
                                    Image(systemName: "newspaper.fill")
                                        .font(.title)
                                    Text("News")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brandAccent.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Persona")
                                .font(.headline)
                            Text(pet.persona)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Pet Profile")
                .onAppear {
                    service.isTabBarHidden = true
                    if greeting == nil {
                        Task {
                            greeting = await service.generateGreeting(for: pet)
                        }
                    }
                }
            } else {
                Text("Pet not found")
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                Text(text)
                    .font(.caption)
            }
        }
    }
}

struct MyPetsView: View {
    @EnvironmentObject var service: PetService
    
    var body: some View {
        NavigationView {
            Group {
                if service.adoptedPets.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No pets adopted yet.")
                            .font(.headline)
                        Text("Visit the Explore tab to find an endangered friend to protect.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List(service.adoptedPets) { pet in
                        NavigationLink(destination: PetProfileView(petId: pet.id)) {
                            HStack {
                                Circle()
                                    .fill(Color.brandPrimary.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: "pawprint.fill").foregroundColor(.brandPrimary))
                                
                                VStack(alignment: .leading) {
                                    Text(pet.name)
                                        .font(.headline)
                                    Text(pet.species.name)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("My Pets")
            .onAppear {
                service.isTabBarHidden = false
            }
        }
    }
}
