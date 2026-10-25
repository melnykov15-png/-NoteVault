import Foundation

@MainActor
protocol NotesRepository {
    func load() throws -> [Note]?
    func save(_ notes: [Note]) throws
}

@MainActor
final class LocalNotesRepository: NotesRepository {
    private let url: URL
    init(url: URL? = nil) {
        self.url = url ?? URL.applicationSupportDirectory.appending(path: "NoteVault/notes-v1.json")
    }
    func load() throws -> [Note]? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder().decode([Note].self, from: Data(contentsOf: url))
    }
    func save(_ notes: [Note]) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(notes).write(to: url, options: [.atomic, .completeFileProtection])
    }
}
