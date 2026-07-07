# CHANGELOG.md

Формат основан на Keep a Changelog.

## [0.3.6] — 2026-07-07

### Added

- `HUD.gd` теперь слушает `terminal_device_list`.
- Добавлен event `hud_objective_corrupt`.
- После закрытия сообщения терминала HUD через короткую задержку меняет цель на тревожную формулировку.

### Changed

- `docs/TASKS.md`, `docs/SCENE_BEATS.md` и `docs/INTERACTION_MECHANICS.md` обновлены под Beat 7.

## [0.3.5] — 2026-07-07

### Added

- `ComputerTerminal.gd` теперь имеет post-speaker фазу после `speaker_wrong_name`.
- Добавлен event `terminal_device_list`.
- Терминал после Smart Speaker показывает список объектов квартиры.
- Повторное взаимодействие с терминалом показывает короткий repeat-текст.

### Changed

- После post-speaker фазы терминала objective flow ведёт игрока к следующему действию у рабочего места.
- `docs/TASKS.md`, `docs/SCENE_BEATS.md` и `docs/INTERACTION_MECHANICS.md` обновлены под Beat 6.

## [0.3.4] — 2026-07-07

### Added

- `InteractableDoor.gd` теперь поддерживает фазовые locked-сообщения.
- Добавлен event `smart_lock_denied` при первой проверке запертой двери.
- Дверь теперь ведёт игрока к Smart Speaker после первого отказа.

### Changed

- `ApartmentEventController.gd` теперь направляет objective flow после события лампы к входной двери.
- `docs/TASKS.md`, `docs/PROJECT_STATE.md`, `docs/SCENE_BEATS.md`, `docs/INTERACTION_MECHANICS.md` и `docs/AGENT_HANDOFF.md` обновлены под Beat 4.

## [0.3.3] — 2026-07-07

### Added

- Добавлен `game/scripts/objects/SmartSpeaker.gd`.
- Smart Speaker теперь имеет нормальное и странное состояние.
- После `terminal_first_ai_reply` Smart Speaker запускает event `speaker_wrong_name`.
- Добавлен `docs/AGENT_HANDOFF.md` для быстрого старта нового чата или код-агента.

### Changed

- `ApartmentEventController.gd` теперь подключает `SmartSpeaker.gd` к существующему объекту `SmartSpeaker` в сцене.
- `docs/TASKS.md`, `docs/PROJECT_STATE.md`, `docs/SCENE_BEATS.md` и `docs/INTERACTION_MECHANICS.md` обновлены под Beat 5.

## [0.3.2] — 2026-07-07

### Added

- Добавлен `docs/ASSET_TRANSITION_PLAN.md` с планом перехода от greybox к lo-fi / PSX ассетам.

### Changed

- Переработана планировка `DeveloperApartment.tscn`: рабочее место перенесено от двери к правой стене.
- Монитор развёрнут внутрь комнаты.
- Стул опущен на пол и поставлен перед рабочим местом.
- Лампа, клавиатура и стикер перенесены в новую рабочую зону.
- Smart Speaker перенесён на полку отдельно от рабочего места.
- `docs/TASKS.md` и `docs/PROJECT_STATE.md` обновлены под room layout pass.

## [0.3.1] — 2026-07-07

### Added

- Добавлены первые procedural sounds без внешних аудиофайлов.
- `terminal_first_ai_reply` теперь проигрывает короткое уведомление терминала.
- Перед миганием `DeskLamp` теперь проигрывается короткий щелчок лампы.
- В `docs/CREDITS.md` добавлена запись о runtime-generated SFX.

### Changed

- `docs/TASKS.md` и `docs/PROJECT_STATE.md` обновлены под First Sound Pass.

## [0.3.0] — 2026-07-07

### Added

- Добавлен `ApartmentEventController.gd` для событий уровня квартиры.
- `DeveloperApartment.tscn` теперь подключает event controller.
- Первый странный ответ терминала `terminal_first_ai_reply` запускает мигание `DeskLamp`.

### Changed

- `docs/TASKS.md` и `docs/PROJECT_STATE.md` обновлены под завершение Beat 2 → Beat 3.

## [0.2.4] — 2026-07-07

### Added

- Добавлен `docs/NARRATIVE_DESIGN.md` с правилами вайба, темпа и микродеталей.
- Добавлен `docs/INTERACTION_MECHANICS.md` с каталогом механик компьютера, комнаты, HUD и звука.
- Добавлен `docs/SOUND_DESIGN.md` с правилами звука, источниками, лицензиями и sound backlog.
- Добавлен `docs/SCENE_BEATS.md` с beat map первого эпизода.

### Changed

- Обновлены `README.md`, `docs/GAME_DESIGN.md`, `docs/ASSET_SOURCES.md`, `docs/TASKS.md` и `docs/ROADMAP.md` под новый design-first процесс.

## [0.2.3] — 2026-07-07

### Fixed

- Исправлена обработка поворота камеры мышью: `PlayerController` теперь получает движение мыши через `_input`, а HUD не блокирует mouse motion.

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
