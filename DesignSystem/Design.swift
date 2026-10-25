import SwiftUI
import UIKit

enum Design {
    static let accent = Color(red: 166/255, green: 117/255, blue: 1)
    static let gradient = LinearGradient(colors: [accent, Color(red: 112/255, green: 69/255, blue: 217/255)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let background = adaptive(0x0B0D14, 0xF4F3F9)
    static let surface = adaptive(0x171A25, 0xFFFFFF)
    static let secondary = adaptive(0x222636, 0xEAE7F2)
    static let spacing: CGFloat = 16
    static let radius: CGFloat = 20
    static func adaptive(_ dark: UInt32, _ light: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((hex >> 16) & 255)/255, green: CGFloat((hex >> 8) & 255)/255, blue: CGFloat(hex & 255)/255, alpha: 1)
        })
    }
}
struct VaultCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content.padding(Design.spacing).frame(maxWidth: .infinity, alignment: .leading)
            .background(Design.surface, in: RoundedRectangle(cornerRadius: Design.radius))
    }
}
struct SymbolTile: View {
    let symbol: String
    var color: Color = Design.accent
    var body: some View {
        Image(systemName: symbol).font(.title3.weight(.semibold)).foregroundStyle(.white)
            .frame(width: 44, height: 44).background(color.gradient, in: RoundedRectangle(cornerRadius: 12)).accessibilityHidden(true)
    }
}
struct DemoNotice: View {
    var body: some View {
        Label("Демонстрация. Настоящие пароли и секреты сохранять нельзя.", systemImage: "lock.shield")
            .font(.footnote).foregroundStyle(.secondary).padding().background(Design.secondary, in: RoundedRectangle(cornerRadius: 14))
    }
}
