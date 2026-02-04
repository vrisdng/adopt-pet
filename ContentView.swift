import SwiftUI

struct ContentView: View {
    @StateObject private var service = PetService()
    @State private var showMainApp = false
    
    var body: some View {
        if showMainApp {
            MainAppView()
                .environmentObject(service)
        } else {
            WelcomeView(showMainApp: $showMainApp)
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var service: PetService
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.brandNeutral.ignoresSafeArea()
            
            Group {
                switch service.selectedTab {
                case .home:
                    SelectionView()
                case .favorites:
                    MyPetsView()
                case .chat:
                    GlobalNewsView() // Using News as Chat/Activity for now based on previous structure
                case .profile:
                    Text("Profile Settings") // Placeholder
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Floating Tab Bar
            if !service.isTabBarHidden {
                HStack {
                    TabBarButton(icon: "house", text: "Home", isSelected: service.selectedTab == .home) {
                        service.selectedTab = .home
                    }
                    
                    TabBarButton(icon: "heart", text: "Saved", isSelected: service.selectedTab == .favorites) {
                        service.selectedTab = .favorites
                    }
                    
                    TabBarButton(icon: "newspaper", text: "News", isSelected: service.selectedTab == .chat) {
                        service.selectedTab = .chat
                    }
                    
                    TabBarButton(icon: "person", text: "Profile", isSelected: service.selectedTab == .profile) {
                        service.selectedTab = .profile
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 0) // Adjust for safe area automatically?
                .transition(.move(edge: .bottom))
            }
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? icon + ".fill" : icon)
                    .font(.system(size: 20))
                
                if isSelected {
                    Text(text)
                        .font(.subheadline.bold())
                }
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.vertical, 12)
            .padding(.horizontal, isSelected ? 20 : 12)
            .background(isSelected ? Color.brandPrimary : Color.clear)
            .clipShape(Capsule())
        }
        .animation(.spring(), value: isSelected)
    }
}
