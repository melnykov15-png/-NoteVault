# Проверки 25.10.2026

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

Структурные проверки не заменяют компиляцию. Нет доступа к Xcode/iOS SDK на этой машине. XCTest написаны, но не запускались. Внешний вид на устройстве не проверен. GitHub Actions workflow подготовлен, но запуск на реальном репозитории не выполнялся. IPA не получен, не подписан и на iPhone не установлен.

Для повторения структурной проверки нужны Node 22+ и служебные npm-пакеты xcode и yaml в NODE_PATH. Эти пакеты не являются зависимостями приложения. Для обычной Xcode-сборки Node и npm не нужны.
