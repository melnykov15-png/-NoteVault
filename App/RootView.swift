import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: NotesViewModel
    @Environment(\.scenePhase) private var phase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tab = 0
    @State private var create = false
    @State private var editor: Note?
    @State private var unavailable = false
    var body: some View {
        ZStack {
            Group {
                switch tab {
                case 0: NavigationStack { HomeView(openSearch: { tab = 4 }, create: { create = true }) }
                case 1: NavigationStack { NotesView() }
                case 3: NavigationStack { VaultView() }
                default: NavigationStack { SearchView() }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { navigation }
            if phase != .active {
                Design.background.ignoresSafeArea()
                Label("NoteVault", systemImage: "lock.shield.fill").font(.largeTitle).foregroundStyle(Design.accent)
            }
        }
        .sheet(isPresented: $create) {
            NavigationStack {
                List {
                    Button { create = false; editor = Note(title: "", body: "") } label: { Label("Новая заметка", systemImage: "doc.badge.plus") }
                    Button { unavailable = true } label: { Label("Новый пароль · недоступно", systemImage: "key.fill") }
                    Button { unavailable = true } label: { Label("Секретная заметка · недоступно", systemImage: "lock.fill") }
                    Button { unavailable = true } label: { Label("Сканировать · следующий этап", systemImage: "viewfinder") }
                }.navigationTitle("Создать").toolbar { Button("Закрыть") { create = false } }
            }.presentationDetents([.medium, .large])
        }
        .sheet(item: $editor) { note in NavigationStack { NoteEditor(note: note) } }
        .alert("Функция ещё не готова", isPresented: $unavailable) { Button("Понятно", role: .cancel) {} } message: { Text("Защищённое хранилище и сканер запланированы. Секретные данные вводить и сохранять нельзя.") }
        .alert("Ошибка хранения", isPresented: Binding(get: { store.error != nil }, set: { if !$0 { store.error = nil } })) { Button("Понятно") { store.error = nil } } message: { Text(store.error ?? "") }
    }
    private var navigation: some View {
        HStack(alignment: .center) {
            navItem("Главная", "house.fill", 0)
            navItem("Заметки", "note.text", 1)
            Button {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { create = true }
            } label: {
                Image(systemName: "plus").font(.title2.weight(.medium)).foregroundStyle(.white).frame(width: 52, height: 52).background(Design.gradient, in: Circle())
            }.accessibilityLabel("Создать запись").sensoryFeedback(.impact(weight: .light), trigger: create)
            navItem("Пароли", "key", 3)
            navItem("Поиск", "magnifyingglass", 4)
        }.padding(.horizontal, 12).padding(.vertical, 8).background(Design.surface)
    }
    private func navItem(_ title: String, _ symbol: String, _ value: Int) -> some View {
        Button { tab = value } label: {
            VStack(spacing: 5) { Image(systemName: symbol).font(.title3); Text(title).font(.caption2) }.frame(maxWidth: .infinity, minHeight: 48)
        }.foregroundStyle(tab == value ? Design.accent : .secondary).accessibilityAddTraits(tab == value ? .isSelected : [])
    }
}
