import SwiftUI

struct WelcomeView: View {
    @Binding var showMainApp: Bool
    
    var body: some View {
        ZStack {
            Color.brandPrimary
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                // Illustration Area (Placeholder using SF Symbols)
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .offset(x: -50, y: -50)
                    
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.brandAccent)
                        .rotationEffect(.degrees(-20))
                        .offset(x: 20, y: -20)
                    
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.brandAccent)
                        .offset(x: 80, y: 60)
                }
                .frame(height: 400)
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Welcome\nto Loving Paws,")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.brandAccent)
                    
                    Text("where love finds a home")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.brandBlack.opacity(0.7))
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showMainApp = true
                    }
                }) {
                    HStack {
                        Text("Get started")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.brandAccent)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(30)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}
