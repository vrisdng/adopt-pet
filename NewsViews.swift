import SwiftUI

struct NewsItemRow: View {
    let item: NewsItem
    let showChatButton: Bool
    let onChat: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.sentiment.rawValue)
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(sentimentColor.opacity(0.2))
                    .foregroundColor(sentimentColor)
                    .clipShape(Capsule())
                
                Spacer()
                
                Text(item.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(item.title)
                .font(.headline)
                .multilineTextAlignment(.leading)

            Text(item.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            if let tip = item.practicalTip {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text(tip)
                        .font(.caption.italic())
                        .foregroundColor(.brandBlack)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(8)
            }
            
            HStack {
                Text("Source: \(item.source)")
                    .font(.caption)
                    .foregroundColor(.brandPrimary)
                
                Spacer()
                
                if let urlString = item.url, let url = URL(string: urlString) {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Text("Read")
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.caption.bold())
                        .foregroundColor(.brandSecondary)
                    }
                }
                
                if showChatButton {
                    Button(action: onChat) {
                        HStack(spacing: 4) {
                            Text("Chat")
                            Image(systemName: "message.fill")
                        }
                        .font(.caption.bold())
                        .foregroundColor(.brandPrimary)
                        .padding(.leading, 12)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    var sentimentColor: Color {
        switch item.sentiment {
        case .positive: return .green
        case .neutral: return .blue
        case .negative: return .brandAlert
        }
    }
}

struct SpeciesNewsView: View {
    let species: Species
    @EnvironmentObject var service: PetService
    @State private var isLoading = false
    @State private var navigateToChat = false
    
    var news: [NewsItem] {
        service.speciesNews[species.id] ?? []
    }
    
    var adoptedPet: Pet? {
        service.adoptedPets.first(where: { $0.species.id == species.id })
    }
    
    var body: some View {
        ZStack {
            if let pet = adoptedPet {
                NavigationLink(isActive: $navigateToChat) {
                    ChatView(pet: pet)
                } label: { EmptyView() }
            }
            
            List {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Checking latest news...")
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
                
                if news.isEmpty && !isLoading {
                    Text("No recent news found for \(species.name).")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(news) { item in
                        Section {
                            NewsItemRow(item: item, showChatButton: adoptedPet != nil) {
                                service.pendingNewsContext = item
                                navigateToChat = true
                            }
                            
                            if item.sentiment == .negative {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Suggested Actions")
                                        .font(.caption.bold())
                                        .foregroundColor(.secondary)
                                    
                                    ForEach(service.getSuggestedActions(for: .negative)) { action in
                                        HStack {
                                            Image(systemName: action.iconName)
                                                .foregroundColor(.brandSecondary)
                                            VStack(alignment: .leading) {
                                                Text(action.title)
                                                    .font(.subheadline.bold())
                                                Text(action.description)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("\(species.name) News")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    refreshNews()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(isLoading)
            }
        }
        .onAppear {
            service.isTabBarHidden = true
            
            // Only fetch if news is missing
            if service.speciesNews[species.id]?.isEmpty ?? true {
                refreshNews()
            }
        }
    }
    
    private func refreshNews() {
        isLoading = true
        Task {
            await service.fetchNews(for: species, force: true)
            isLoading = false
        }
    }
}

struct GlobalNewsView: View {

    @EnvironmentObject var service: PetService

    

    var body: some View {

        NavigationView {

            List {

                ForEach(service.availableSpecies) { species in

                    if let news = service.speciesNews[species.id] {

                        Section(header: Text(species.name)) {

                            ForEach(news) { item in

                                NewsItemRow(item: item, showChatButton: false) {}

                            }

                        }

                    }

                }

            }

            .navigationTitle("Eco Watch")

            .onAppear {

                service.isTabBarHidden = false

            }

        }

    }

}
