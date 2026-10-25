import SwiftUI
import UniformTypeIdentifiers

struct NotesExport: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}
struct SettingsView: View {
    @EnvironmentObject private var store: NotesViewModel
    @AppStorage("appearance") private var appearance = "dark"
    @State private var exporting = false
    @State private var export: NotesExport?
    @State private var error: String?
    var body: some View {
        Form {
            Section("Безопасность") { DemoNotice(); Text("Face ID · следующий этап"); Text("Мастер-пароль · следующий этап"); Text("Приложение скрывается при потере активности") }
            Section("Данные") {
                Text("Обычные заметки хранятся локально без шифрования хранилищем NoteVault.").font(.footnote)
                Button("Экспорт обычных заметок в JSON") { do { export = NotesExport(data: try JSONEncoder().encode(store.notes)); exporting = true } catch { self.error = "Не удалось подготовить экспорт" } }
                NavigationLink("Корзина") { TrashView() }
                Text("Импорт и резервная копия хранилища · следующие этапы").foregroundStyle(.secondary)
            }
            Section("Оформление") { Picker("Тема", selection: $appearance) { Text("Системная").tag("system"); Text("Тёмная").tag("dark"); Text("Светлая").tag("light") } }
            Section("Приложение") { LabeledContent("Версия", value: "0.1.0 · разработка"); LabeledContent("Язык", value: "Русский"); Text("Без регистрации, рекламы и облачных сервисов"); Text("AutoFill и синхронизация не реализованы").foregroundStyle(.secondary) }
            if let error { Text(error).foregroundStyle(.red) }
        }.navigationTitle("Настройки")
            .fileExporter(isPresented: $exporting, document: export, contentType: .json, defaultFilename: "NoteVault-notes") { result in if case .failure = result { error = "Экспорт не завершён" } }
    }
}
