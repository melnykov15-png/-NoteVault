import SwiftUI
import UIKit

struct GeneratorView: View {
    @State private var length = 18.0
    @State private var upper = true
    @State private var lower = true
    @State private var digits = true
    @State private var symbols = true
    @State private var exclude = true
    @State private var output = ""
    @State private var error: String?
    var body: some View {
        Form {
            Section { Text(output.isEmpty ? "Нажмите «Сгенерировать»" : output).font(.system(.title3, design: .monospaced)).textSelection(.enabled) }
            Section("Параметры") {
                Slider(value: $length, in: 8...64, step: 1) { Text("Длина") }
                Text("Длина: \(Int(length))")
                Toggle("A–Z · заглавные", isOn: $upper)
                Toggle("a–z · строчные", isOn: $lower)
                Toggle("0–9 · цифры", isOn: $digits)
                Toggle("Специальные символы", isOn: $symbols)
                Toggle("Исключить похожие символы", isOn: $exclude)
            }
            Section {
                Button("Сгенерировать") {
                    do { output = try PasswordGenerator.generate(length: Int(length), uppercase: upper, lowercase: lower, digits: digits, symbols: symbols, excludeAmbiguous: exclude); error = nil }
                    catch { output = ""; self.error = "Выберите хотя бы одну группу символов. Если ошибка повторяется, источник случайности недоступен." }
                }
                Button("Копировать на 30 секунд") { UIPasteboard.general.setItems([[UIPasteboard.typeAutomatic: output]], options: [.localOnly: true, .expirationDate: Date().addingTimeInterval(30)]) }.disabled(output.isEmpty)
                Text("Сохранение в хранилище недоступно").foregroundStyle(.secondary)
            }
            if let error { Text(error).foregroundStyle(.red) }
            Text("Случайный пароль большей длины обычно труднее подобрать. Это не гарантия безопасности: используйте уникальные пароли и двухфакторную аутентификацию.").font(.footnote).foregroundStyle(.secondary)
        }.navigationTitle("Генератор")
    }
}
