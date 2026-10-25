import Foundation
import Combine

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published var error: String?
    private let repository: any NotesRepository
    private var loadFailed = false
    init(repository: any NotesRepository) {
        self.repository = repository
        do { notes = try repository.load() ?? Note.samples }
        catch { loadFailed = true; self.error = "Не удалось прочитать заметки. Файл не перезаписан. Перезапустите приложение после восстановления доступа к данным." }
    }
    var active: [Note] { notes.filter { !$0.deleted }.sorted { $0.pinned != $1.pinned ? $0.pinned : $0.modified > $1.modified } }
    var categories: [String] { Array(Set(["Личные", "Работа", "Проекты"] + notes.map(\.category))).sorted() }
    func matching(_ text: String, category: String = "Все") -> [Note] {
        active.filter { (category == "Все" || $0.category == category) && (text.isEmpty || [$0.title, $0.body, $0.category, $0.tags].joined(separator: " ").localizedCaseInsensitiveContains(text)) }
    }
    @discardableResult func update(_ note: Note) -> Bool {
        guard !loadFailed else { error = "Сохранение отключено: исходные данные не прочитаны."; return false }
        var candidate = notes
        var changed = note; changed.modified = Date()
        if let index = candidate.firstIndex(where: { $0.id == note.id }) { candidate[index] = changed } else { candidate.insert(changed, at: 0) }
        do { try repository.save(candidate); notes = candidate; return true }
        catch { self.error = "Изменения не сохранены. Проверьте свободное место и повторите попытку."; return false }
    }
    func trash(_ note: Note) { var changed = note; changed.deleted = true; update(changed) }
    func restore(_ note: Note) { var changed = note; changed.deleted = false; update(changed) }
}
