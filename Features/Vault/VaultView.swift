import SwiftUI

struct VaultView: View {
    @State private var query = ""
    var body: some View {
        List {
            Section { DemoNotice() }
            Section("Демонстрационные аккаунты") {
                ForEach(DemoAccount.all.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }) { account in
                    NavigationLink { AccountView(account: account) } label: {
                        HStack { SymbolTile(symbol: account.symbol); VStack(alignment: .leading) { Text(account.name); Text(account.site).font(.caption).foregroundStyle(.secondary) } }
                    }
                }
            }
            Section { NavigationLink("Генератор паролей") { GeneratorView() }; NavigationLink("Защищённая зона") { LockedVaultView() } }
        }.scrollContentBackground(.hidden).background(Design.background).navigationTitle("Пароли").searchable(text: $query, prompt: "Поиск по демоаккаунтам")
    }
}
struct AccountView: View {
    let account: DemoAccount
    var body: some View {
        List {
            Section { HStack { SymbolTile(symbol: account.symbol); Text(account.name).font(.title2.bold()) }; DemoNotice() }
            Section("Логин") { Text("demo@example.invalid").textSelection(.enabled) }
            Section("Пароль") { Text("Недоступен — защищённое хранилище не реализовано").foregroundStyle(.secondary) }
            Section("Сайт") { if let url = URL(string: account.site) { Link("Открыть сайт", destination: url) } }
            Section("Связанные материалы") { NavigationLink("Пример связей") { LinkedMaterialsView() } }
        }.navigationTitle(account.name).navigationBarTitleDisplayMode(.inline)
    }
}
struct LockedVaultView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.shield.fill").font(.system(size: 72)).foregroundStyle(Design.gradient).accessibilityHidden(true)
            Text("Секретная зона").font(.title.bold())
            Text("Здесь будут зашифрованные заметки и аккаунты.").multilineTextAlignment(.center).foregroundStyle(.secondary)
            DemoNotice()
            Text("Face ID и мастер-пароль пока недоступны. Разблокировка не имитируется.").font(.footnote).multilineTextAlignment(.center).foregroundStyle(.secondary)
            Spacer()
        }.padding(24).frame(maxWidth: .infinity).background(Design.background).navigationTitle("Хранилище")
    }
}
struct LinkedMaterialsView: View {
    var body: some View {
        List {
            Section("Мой сайт · демонстрация") {
                Label("Заметки по разработке", systemImage: "doc.text")
                Label("Документы · следующий этап", systemImage: "paperclip")
                NavigationLink { LockedVaultView() } label: { Label("Аккаунты защищены · недоступно", systemImage: "lock.fill") }
            }
            Text("Создание и изменение связей запланированы. Реальные секреты здесь не отображаются.").font(.footnote).foregroundStyle(.secondary)
        }.navigationTitle("Связанные материалы")
    }
}
