import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: NotesViewModel
    let openSearch: () -> Void
    let create: () -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Всё важное в одном месте").font(.subheadline).foregroundStyle(.secondary)
                Button(action: openSearch) { Label("Поиск по заметкам…", systemImage: "magnifyingglass").frame(maxWidth: .infinity, alignment: .leading).padding().background(Design.surface, in: RoundedRectangle(cornerRadius: 14)) }.foregroundStyle(.secondary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 10) {
                    Button(action: create) { quick("Заметка", "doc.text.fill", .orange) }
                    NavigationLink { VaultView() } label: { quick("Пароль", "key.fill", Design.accent) }
                    NavigationLink { LockedVaultView() } label: { quick("Секретная", "lock.fill", Design.accent) }
                    Button(action: create) { quick("Сканер", "viewfinder", .purple) }
                }
                VaultCard {
                    HStack { SymbolTile(symbol: "lock.shield.fill"); VStack(alignment: .leading) { Text("Ваше личное пространство").font(.headline); Text("Заметки доступны без интернета").font(.caption).foregroundStyle(.secondary) } }
                }
                section("Недавние", Array(store.active.prefix(4)))
                section("Избранное", store.active.filter(\.favorite))
                section("Закреплённые", store.active.filter(\.pinned))
                NavigationLink { LinkedMaterialsView() } label: { Label("Связанные материалы · демо", systemImage: "link").frame(maxWidth: .infinity, alignment: .leading).padding().background(Design.surface, in: RoundedRectangle(cornerRadius: 16)) }
            }.padding()
        }.background(Design.background).navigationTitle("NoteVault")
            .toolbar { NavigationLink { SettingsView() } label: { Image(systemName: "gearshape") }.accessibilityLabel("Настройки") }
    }
    private func quick(_ title: String, _ symbol: String, _ color: Color) -> some View {
        VStack(spacing: 10) { SymbolTile(symbol: symbol, color: color); Text(title).font(.caption).foregroundStyle(.primary) }.frame(maxWidth: .infinity).padding(.vertical, 12).background(Design.surface, in: RoundedRectangle(cornerRadius: 16))
    }
    private func section(_ title: String, _ notes: [Note]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text(title).font(.title3.bold()); Spacer(); NavigationLink("Все") { NotesView() }.font(.caption) }
            if notes.isEmpty { Text("Пока ничего нет").foregroundStyle(.secondary) }
            ForEach(notes) { note in NavigationLink { NoteEditor(note: note) } label: { NoteRow(note: note) }.buttonStyle(.plain) }
        }
    }
}
struct NoteRow: View {
    let note: Note
    var body: some View {
        VaultCard {
            HStack { SymbolTile(symbol: note.symbol, color: .orange); VStack(alignment: .leading, spacing: 4) { Text(note.title.isEmpty ? "Без названия" : note.title).font(.headline).lineLimit(2); Text(note.category).font(.caption).foregroundStyle(.secondary) }; Spacer(); if note.favorite { Image(systemName: "star.fill").foregroundStyle(.yellow).accessibilityLabel("Избранное") }; if note.pinned { Image(systemName: "pin.fill").foregroundStyle(Design.accent).accessibilityLabel("Закреплена") } }
        }
    }
}
