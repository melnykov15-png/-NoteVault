import SwiftUI

struct NoteEditor: View {
    @EnvironmentObject private var store: NotesViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var phase
    @State var note: Note
    @State private var delete = false
    @State private var history: [String] = []
    @State private var redo: [String] = []
    @State private var restoring = false
    @State private var saved = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Обычная заметка · без шифрования").font(.caption).foregroundStyle(.secondary)
                TextField("Заголовок", text: $note.title, axis: .vertical).font(.title.bold())
                TextEditor(text: $note.body).frame(minHeight: 340).scrollContentBackground(.hidden).accessibilityLabel("Текст заметки")
                TextField("Папка", text: $note.category).textFieldStyle(.roundedBorder)
                TextField("Теги через запятую", text: $note.tags).textFieldStyle(.roundedBorder)
                Toggle("Избранное", isOn: $note.favorite)
                Toggle("Закрепить", isOn: $note.pinned)
                Text(saved ? "Изменения сохранены на iPhone" : "Есть несохранённые изменения").font(.caption).foregroundStyle(saved ? Color.secondary : Color.orange)
            }.padding()
        }.background(Design.background).navigationTitle("Редактор").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { if let previous = history.popLast() { redo.append(note.body); restoring = true; note.body = previous } } label: { Image(systemName: "arrow.uturn.backward") }.disabled(history.isEmpty).accessibilityLabel("Отменить")
                    Button { if let next = redo.popLast() { history.append(note.body); restoring = true; note.body = next } } label: { Image(systemName: "arrow.uturn.forward") }.disabled(redo.isEmpty).accessibilityLabel("Повторить")
                    Button("Готово") { if store.update(note) { dismiss() } }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Заголовок") { note.body += "\n\n# " }
                    Button { note.body += "\n☐ " } label: { Image(systemName: "checklist") }.accessibilityLabel("Добавить пункт списка")
                    Spacer()
                    Button(role: .destructive) { delete = true } label: { Image(systemName: "trash") }.accessibilityLabel("В корзину")
                }
            }
            .onAppear { saved = store.update(note) }
            .onChange(of: note.body) { old, _ in
                if restoring { restoring = false } else { history.append(old); if history.count > 50 { history.removeFirst() }; redo.removeAll() }
            }
            .onChange(of: note) { _, _ in saved = store.update(note) }
            .onChange(of: phase) { _, value in if value != .active { saved = store.update(note) } }
            .confirmationDialog("Переместить заметку в корзину?", isPresented: $delete, titleVisibility: .visible) { Button("В корзину", role: .destructive) { var n = note; n.deleted = true; if store.update(n) { dismiss() } } }
    }
}

