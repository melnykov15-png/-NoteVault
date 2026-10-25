import XCTest
@testable import NoteVault

@MainActor
final class NotesTests: XCTestCase {
    final class MemoryRepository: NotesRepository {
        var values: [Note]? = []
        var fail = false
        func load() throws -> [Note]? { values }
        func save(_ notes: [Note]) throws { if fail { throw CocoaError(.fileWriteOutOfSpace) }; values = notes }
    }
    func testCreateEditSearchTrashRestoreAndReload() {
        let repo = MemoryRepository()
        let store = NotesViewModel(repository: repo)
        var note = Note(title: "Тест", body: "Локальный текст", category: "Проекты", tags: "swift")
        XCTAssertTrue(store.update(note))
        note.body = "Изменённый текст"
        XCTAssertTrue(store.update(note))
        XCTAssertEqual(store.matching("swift").count, 1)
        XCTAssertEqual(store.matching("изменённый").first?.body, note.body)
        XCTAssertEqual(store.matching("нет").count, 0)
        store.trash(note)
        XCTAssertTrue(store.active.isEmpty)
        store.restore(note)
        XCTAssertEqual(NotesViewModel(repository: repo).active.count, 1)
    }
    func testSaveFailurePreservesPreviousState() {
        let repo = MemoryRepository(); let store = NotesViewModel(repository: repo)
        repo.fail = true
        XCTAssertFalse(store.update(Note(title: "Тест", body: "")))
        XCTAssertTrue(store.notes.isEmpty)
        XCTAssertNotNil(store.error)
    }
    func testDiskRoundTrip() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let repo = LocalNotesRepository(url: directory.appending(path: "notes.json"))
        let notes = [Note(title: "Тест", body: "Данные")]
        try repo.save(notes)
        XCTAssertEqual(try repo.load(), notes)
    }
    func testCorruptedFileIsNotOverwritten() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "notes.json")
        let corrupted = Data("broken".utf8); try corrupted.write(to: url)
        let store = NotesViewModel(repository: LocalNotesRepository(url: url))
        XCTAssertFalse(store.update(Note(title: "Тест", body: "")))
        XCTAssertEqual(try Data(contentsOf: url), corrupted)
    }
}
final class GeneratorTests: XCTestCase {
    func testLengthsAndSelectedClasses() throws {
        for length in [8, 18, 64] {
            let result = try PasswordGenerator.generate(length: length, uppercase: true, lowercase: true, digits: true, symbols: true, excludeAmbiguous: true)
            XCTAssertEqual(result.count, length)
            XCTAssertTrue(result.contains { $0.isUppercase })
            XCTAssertTrue(result.contains { $0.isLowercase })
            XCTAssertTrue(result.contains { $0.isNumber })
            XCTAssertTrue(result.contains { !$0.isLetter && !$0.isNumber })
            XCTAssertFalse(result.contains { "Il1O0o".contains($0) })
        }
    }
    func testInvalidOptions() {
        XCTAssertThrowsError(try PasswordGenerator.generate(length: 7, uppercase: true, lowercase: true, digits: true, symbols: true, excludeAmbiguous: false))
        XCTAssertThrowsError(try PasswordGenerator.generate(length: 18, uppercase: false, lowercase: false, digits: false, symbols: false, excludeAmbiguous: false))
    }
}
