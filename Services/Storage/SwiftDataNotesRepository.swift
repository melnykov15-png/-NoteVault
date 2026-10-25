import Foundation
import SwiftData

@Model
final class NoteRecord {
    @Attribute(.unique) var id: UUID
    var payload: Data
    init(id: UUID, payload: Data) { self.id = id; self.payload = payload }
}

@MainActor
final class SwiftDataNotesRepository: NotesRepository {
    private let container: ModelContainer
    init(inMemory: Bool = false) throws {
        let schema = Schema([NoteRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        container = try ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.autosaveEnabled = false
    }
    func load() throws -> [Note]? {
        let records = try container.mainContext.fetch(FetchDescriptor<NoteRecord>())
        guard !records.isEmpty else { return nil }
        return try records.map { try JSONDecoder().decode(Note.self, from: $0.payload) }
    }
    func save(_ notes: [Note]) throws {
        let context = container.mainContext
        do {
            let records = try context.fetch(FetchDescriptor<NoteRecord>())
            let existing = Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0) })
            let ids = Set(notes.map(\.id))
            for record in records where !ids.contains(record.id) { context.delete(record) }
            for note in notes {
                let payload = try JSONEncoder().encode(note)
                if let record = existing[note.id] { record.payload = payload }
                else { context.insert(NoteRecord(id: note.id, payload: payload)) }
            }
            try context.save()
        } catch { context.rollback(); throw error }
    }
}

@MainActor
private final class UnavailableRepository: NotesRepository {
    func load() throws -> [Note]? { throw CocoaError(.fileReadUnknown) }
    func save(_ notes: [Note]) throws { throw CocoaError(.fileWriteUnknown) }
}
@MainActor
enum AppDependencies {
    static func notes() -> NotesViewModel {
        do { return NotesViewModel(repository: try SwiftDataNotesRepository()) }
        catch { return NotesViewModel(repository: UnavailableRepository()) }
    }
}
