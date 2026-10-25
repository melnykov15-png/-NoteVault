import XCTest
@testable import NoteVault

@MainActor
final class SwiftDataNotesTests: XCTestCase {
    func testSwiftDataRoundTripAndUpdate() throws {
        let repo = try SwiftDataNotesRepository(inMemory: true)
        XCTAssertNil(try repo.load())
        var note = Note(title: "Тестовая запись", body: "Не секрет")
        try repo.save([note])
        XCTAssertEqual(try repo.load(), [note])
        note.body = "Новая версия"; note.deleted = true
        try repo.save([note])
        XCTAssertEqual(try repo.load(), [note])
        try repo.save([])
        XCTAssertNil(try repo.load())
    }
}
