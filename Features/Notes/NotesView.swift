import SwiftUI

struct NotesView: View {
    @EnvironmentObject private var store: NotesViewModel
    @State private var query = ""
    @State private var category = "Все"
    @State private var grid = true
    @State private var ascending = false
    @State private var editor: Note?
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack { ForEach(["Все"] + store.categories, id: \.self) { item in Button { category = item } label: { Text(item).font(.subheadline).padding(.horizontal, 14).padding(.vertical, 8).background(category == item ? Design.accent : Design.secondary, in: Capsule()).foregroundStyle(category == item ? Color.white : Color.primary) } } }
                }
                let notes = ascending ? store.matching(query, category: category).reversed().map { $0 } : store.matching(query, category: category)
                if notes.isEmpty { ContentUnavailableView("Заметок пока нет", systemImage: "note.text", description: Text("Создайте заметку или измените фильтр.")) }
                LazyVGrid(columns: grid ? [GridItem(.adaptive(minimum: 155), spacing: 12)] : [GridItem(.flexible())], spacing: 12) {
                    ForEach(notes) { note in
                        NavigationLink { NoteEditor(note: note) } label: {
                            if grid {
                                VaultCard {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Image(systemName: note.symbol).font(.largeTitle).foregroundStyle(Design.accent).frame(maxWidth: .infinity, minHeight: 64).background(Design.secondary, in: RoundedRectangle(cornerRadius: 12))
                                        Text(note.title.isEmpty ? "Без названия" : note.title).font(.headline).lineLimit(2)
                                        Text(note.body).font(.caption).foregroundStyle(.secondary).lineLimit(3)
                                        HStack { Text(note.modified, style: .date); Spacer(); if note.favorite { Image(systemName: "star.fill").foregroundStyle(.yellow) } }.font(.caption2).foregroundStyle(.secondary)
                                    }
                                }
                            } else { NoteRow(note: note) }
                        }.buttonStyle(.plain).contextMenu {
                            Button(note.favorite ? "Убрать из избранного" : "В избранное") { var n = note; n.favorite.toggle(); store.update(n) }
                            Button(note.pinned ? "Открепить" : "Закрепить") { var n = note; n.pinned.toggle(); store.update(n) }
                            Button("В корзину", role: .destructive) { store.trash(note) }
                        }
                    }
                }
            }.padding()
        }.background(Design.background).navigationTitle("Заметки").searchable(text: $query, prompt: "Поиск по заметкам")
            .toolbar {
                Button { editor = Note(title: "", body: "") } label: { Image(systemName: "plus") }.accessibilityLabel("Новая заметка")
                Button { grid.toggle() } label: { Image(systemName: grid ? "list.bullet" : "square.grid.2x2") }.accessibilityLabel("Изменить вид")
                Menu { Button("Изменить порядок") { ascending.toggle() }; NavigationLink("Корзина") { TrashView() } } label: { Image(systemName: "ellipsis.circle") }
            }
            .sheet(item: $editor) { note in NavigationStack { NoteEditor(note: note) } }
    }
}
struct TrashView: View {
    @EnvironmentObject private var store: NotesViewModel
    var body: some View {
        List {
            if !store.notes.contains(where: \.deleted) { Text("Корзина пуста").foregroundStyle(.secondary) }
            ForEach(store.notes.filter(\.deleted)) { note in HStack { Text(note.title); Spacer(); Button("Восстановить") { store.restore(note) } } }
        }.navigationTitle("Корзина")
    }
}
