import Foundation

struct Note: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var body: String
    var category: String = "Личные"
    var tags: String = ""
    var favorite = false
    var pinned = false
    var deleted = false
    var modified = Date()
    var symbol: String = "doc.text.fill"
    static let samples: [Note] = [
        Note(title: "Планы на отпуск ✈️", body: "Лето у моря\n\n☑ Забронировать отель\n☐ Купить билеты\n☐ Оформить страховку\n\nБюджет\nАвиабилеты — 120 000 ₽\nОтель — 80 000 ₽", tags: "отпуск, планы", favorite: true, pinned: true, symbol: "sun.max.fill"),
        Note(title: "Идеи для контента", body: "Темы, примеры, референсы.\n\nСнять короткое видео о путешествии.", category: "Работа", symbol: "lightbulb.fill"),
        Note(title: "Покупки", body: "☐ Ноутбук\n☐ Наушники\n☐ Рюкзак", symbol: "cart.fill"),
        Note(title: "Мой сайт", body: "Дизайн главной страницы\nДокументация\nПлан запуска", category: "Проекты", favorite: true, symbol: "laptopcomputer"),
        Note(title: "Книги для чтения", body: "Психология, дизайн и новые истории.", symbol: "books.vertical.fill")
    ]
}
struct DemoAccount: Identifiable {
    let id: String
    let name: String
    let site: String
    let symbol: String
    static let all = [
        DemoAccount(id: "google", name: "Google", site: "https://google.com", symbol: "g.circle.fill"),
        DemoAccount(id: "youtube", name: "YouTube", site: "https://youtube.com", symbol: "play.rectangle.fill"),
        DemoAccount(id: "telegram", name: "Telegram", site: "https://telegram.org", symbol: "paperplane.fill"),
        DemoAccount(id: "apple", name: "Apple", site: "https://apple.com", symbol: "apple.logo"),
        DemoAccount(id: "github", name: "GitHub", site: "https://github.com", symbol: "chevron.left.forwardslash.chevron.right")
    ]
}
