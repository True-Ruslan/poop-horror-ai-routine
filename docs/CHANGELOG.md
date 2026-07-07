# CHANGELOG.md

Формат основан на Keep a Changelog.

## [0.2.2] — 2026-07-07

### Added

- Добавлен `docs/UPSTREAM_TEMPLATE_SYNC.md` для периодической сверки с `True-Ruslan/godot-simple-tamplate`.
- Зафиксирована последняя проверка upstream-шаблона: commit `9cf6dbdd674048fdbacaefcde1808f6d58362c7e`.

## [0.2.1] — 2026-07-07

### Added

- Добавлен документ `docs/DOCUMENTATION_RULES.md`.
- Добавлен документ `docs/PROJECT_STATE.md`.
- Добавлен документ `docs/ROADMAP.md`.
- Добавлен шаблон отчёта `docs/ITERATION_REPORT_TEMPLATE.md`.

### Changed

- Обновлены правила работы код-агента в `AGENTS.md`.
- В `README.md` добавлена карта документации.

## [0.2.0] — 2026-07-07

### Added

- Добавлена концепция игры `AI Routine: Last Commit`.
- Добавлен сценарий `docs/SCENARIO.md`.
- Добавлен дизайн-документ `docs/GAME_DESIGN.md`.
- Добавлен документ по источникам ассетов и лицензиям `docs/ASSET_SOURCES.md`.
- Добавлена первая игровая локация `DeveloperApartment.tscn`.
- Добавлен интерактивный объект `ComputerTerminal.tscn`.
- Добавлен скрипт `ComputerTerminal.gd`.
- Добавлен первый сценарный текст для рабочего монитора.

### Changed

- Проект переименован в `AI Routine: Last Commit`.
- `Main.tscn` теперь запускает `DeveloperApartment.tscn` вместо шаблонного уровня.
- Стартовая цель игрока обновлена под рабочую рутину разработчика.
- `README.md`, `docs/CONTEXT.md`, `docs/TASKS.md` и `docs/DECISIONS.md` обновлены под конкретную игру.

## [0.1.0] — 2026-07-07

### Added

- Создан Godot-проект.
- Добавлена основная сцена `Main.tscn`.
- Добавлен демо-уровень `TemplateLevel.tscn`.
- Добавлен first-person player controller.
- Добавлен фонарик с зарядом.
- Добавлена interaction raycast-система.
- Добавлена интерактивная дверь.
- Добавлена интерактивная записка.
- Добавлен выключатель света.
- Добавлен HUD.
- Добавлен `ObjectiveManager`.
- Добавлен `HorrorEventManager`.
- Добавлен `GameState`.
- Добавлена документация для человека и ИИ-агента.
