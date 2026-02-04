import SwiftUI

struct NewsItemRow: View {
    let item: NewsItem
    
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
            
            Text("Source: \(item.source)")
                .font(.caption)
                .foregroundColor(.brandPrimary)
            
            if let urlString = item.url, let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack {
                        Text("Read More")
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.caption.bold())
                    .foregroundColor(.brandPrimary)
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
    
    var news: [NewsItem] {
        service.speciesNews[species.id] ?? []
    }
    
    var body: some View {
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
                        NewsItemRow(item: item)
                        
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
                                NewsItemRow(item: item)
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