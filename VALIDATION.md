# Проверки 25.10.2026

## Подтверждённая облачная сборка

Run: https://github.com/melnykov15-png/-NoteVault/actions/runs/40147786994
Commit: 066b8c3a7790e267b2a99f8b715bea27f131ad10
Runner: macos-15; Xcode 16.4.

- 7 XCTest прошли с 0 ошибками: GeneratorTests (2), NotesTests (4), SwiftDataNotesTests (1).
- TEST SUCCEEDED; BUILD SUCCEEDED.
- Device Release собран с CODE_SIGNING_ALLOWED=NO; IPA опубликован как артефакт и скачан на Windows.
- Подпись и установка на iPhone не выполнялись. UI/VoiceOver/Dynamic Type на реальном устройстве не проверены.

## Первоначальная структурная проверка (до запуска CI)

Выполнено на Windows:

- Генератор создал Xcode project.pbxproj и общую схему NoteVault с приложением и XCTest target.
- Независимый OpenStep-парсер пакета xcode успешно прочитал project.pbxproj.
- Все 17 ссылок на Swift-исходники указывают на существующие файлы.
- Схема Xcode успешно разобрана как XML; test target указан.
- Workflow успешно разобран YAML-парсером; проверены runner macos-15, ручной запуск, ограничение публичными репозиториями и срок артефактов 1 день.

Вывод структурной проверки:

    PASS: OpenStep Xcode project parsed; 17 Swift source references exist.
    PASS: workflow YAML parsed; standard macOS runner, manual trigger, public-only budget guard and 1-day artifacts.
    NOT RUN: Swift compiler, XCTest, simulator, device signing or installation.

На момент первоначальной структурной проверки компиляция и XCTest ещё не запускались. Позже они выполнены успешно в GitHub Actions; актуальные результаты приведены в начале этого файла. Подпись и установка по-прежнему не выполнялись.

Для повторения структурной проверки нужны Node 22+ и служебные npm-пакеты xcode и yaml в NODE_PATH. Эти пакеты не являются зависимостями приложения. Для обычной Xcode-сборки Node и npm не нужны.
