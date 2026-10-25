import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var store: NotesViewModel
    @State private var query = ""
    @State private var filter = "Все"
    var body: some View {
        List {
            Picker("Тип", selection: $filter) { Text("Все").tag("Все"); Text("Заметки").tag("Заметки"); Text("Демоаккаунты").tag("Аккаунты") }.pickerStyle(.segmented)
            if filter != "Аккаунты" {
                Section("Заметки") {
                    ForEach(store.matching(query)) { note in NavigationLink { NoteEditor(note: note) } label: { Label(note.title.isEmpty ? "Без названия" : note.title, systemImage: note.symbol) } }
                    if store.matching(query).isEmpty { Text("Заметки не найдены").foregroundStyle(.secondary) }
                }
            }
            if filter != "Заметки" {
                Section("Демонстрационные аккаунты") {
                    ForEach(DemoAccount.all.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }) { account in NavigationLink(account.name) { AccountView(account: account) } }
                }
            }
            Text("Поиск работает локально. Секретные данные не индексируются.").font(.caption).foregroundStyle(.secondary)
        }.navigationTitle("Поиск").searchable(text: $query, prompt: "Заметки, папки, теги…")
    }
}
