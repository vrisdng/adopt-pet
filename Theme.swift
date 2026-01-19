import SwiftUI

extension Color {
    static let brandPrimary = Color(red: 50/255, green: 181/255, blue: 157/255) // Soft mint
    static let brandSecondary = Color(red: 255/255, green: 182/255, blue: 163/255) // Warm coral
    static let brandAccent = Color(red: 45/255, green: 95/255, blue: 63/255) // Deep forest green
    static let brandNeutral = Color(red: 250/255, green: 249/255, blue: 246/255) // Cream
    static let brandAlert = Color(red: 255/255, green: 216/255, blue: 156/255) // Gentle amber
    static let brandBlack = Color.black
}

struct BrandButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.brandPrimary)
            .cornerRadius(30)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.brandAccent)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
