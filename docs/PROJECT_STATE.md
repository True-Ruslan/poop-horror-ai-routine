# PROJECT_STATE.md

Дата обновления: 2026-07-12

## Текущий статус

Проект завершил этап раннего playable prototype и переходит к production rebuild.

Согласован целевой продукт:

- одиночный first-person psychological horror;
- продолжительность 45–60 минут;
- одна глубоко проработанная квартира площадью примерно 38–45 м²;
- пролог и три акта;
- четыре финала: `MERGE`, `REVERT`, `BLACKOUT`, `CLEAN BUILD`;
- релиз на Windows с подготовкой для Steam и itch.io;
- русский и английский языки;
- обязательные accessibility-настройки;
- без боевой системы и традиционного AI-врага.

Written production spec создан и прошёл self-review:

```text
docs/superpowers/specs/2026-07-12-production-rebuild-design.md
```

Текущий gate: финальное подтверждение written spec пользователем.

## Что существует в main

### Playable prototype

Основная сцена:

```text
game/scenes/Main.tscn
```

Она загружает:

```text
game/scenes/levels/DeveloperApartment.tscn
game/scenes/ui/HUD.tscn
```

Текущий prototype route:

```text
стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch
```

### Системы прототипа

- first-person movement;
- sprint и crouch;
- flashlight;
- interaction raycast;
- `GameState`;
- `ObjectiveManager`;
- `HorrorEventManager`;
- `ApartmentEventController`;
- HUD;
- procedural placeholder sounds.

### Объекты прототипа

- `InteractableNote`;
- `InteractableDoor`;
- `LightSwitch`;
- `ComputerTerminal`;
- `SmartSpeaker`.

### Реализованные prototype events

- `task_sticker_read`;
- `terminal_first_ai_reply`;
- `smart_lock_denied`;
- `speaker_wrong_name`;
- `terminal_device_list`;
- `hud_objective_corrupt`.

## Результаты аудита

Текущий проект является функциональным prototype, но не production-ready игрой.

Критические ограничения:

- квартира и большинство предметов собраны из `BoxMesh`;
- отсутствуют финальные модели, PBR-материалы, texture pipeline и prop dressing;
- progression зависит от строк, встроенных в object scripts;
- нет save/load, chapter state и checkpoint recovery;
- нет settings manager, localization pipeline и accessibility system;
- нет production main menu и pause menu;
- нет полноценного terminal/phone focus mode;
- звук генерируется внутри контроллера уровня;
- нет audio buses и dynamic snapshots;
- нет tests, narrative validation и CI;
- нет `export_presets.cfg` и release pipeline;
- большинство prototype beats не проверялись локально в Godot после merge.

## Согласованная production-архитектура

Целевые core-сервисы:

```text
GameBootstrap
SceneFlowManager
SaveGameManager
SettingsManager
NarrativeDirector
ObjectiveSystem
EventSequenceRunner
AudioDirector
LocalizationManager
AccessibilityManager
```

Сценарий переносится в data-driven Godot Resources. Интерактивные объекты переходят на component-based prefab с отдельными interaction, visual, audio, highlight и saveable components.

Старые системы удаляются только после миграции и regression-проверки существующего playable route.

## Согласованное художественное направление

Целевой стиль: grounded stylized realism.

- реалистичные размеры и планировка;
- low/mid-poly production models;
- PBR-материалы 1K–2K;
- жилая и слегка неопрятная квартира;
- отдельные зоны: прихожая, коридор, комната, кухня, санузел;
- PSX/VHS-эффекты только во время цифровых нарушений;
- никаких placeholder `BoxMesh` в release-контенте;
- только коммерчески безопасные assets с записью в `docs/CREDITS.md`.

## Текущий milestone

```text
P0 — Design Lock
```

Завершено:

- полный аудит;
- согласование scope и разделов дизайна;
- written production spec;
- versioning correction: production line начинается с `0.4.x`;
- согласование первого code scope: P1.1 Bootstrap and Logging;
- обновление основных sources of truth;
- spec self-review.

Ожидается:

- подтверждение written spec пользователем;
- implementation plan для P1.

## Следующий milestone

```text
P1 — Foundation Rebuild
```

Первый code PR:

```text
P1.1 — Bootstrap and Logging
```

Scope:

- `GameBootstrap`;
- production main scene;
- typed logging service;
- development/release flags;
- legacy adapter для текущей квартиры;
- minimal smoke check;
- documentation.

В первый P1.1 PR не входят settings, saves, новая квартира, external assets, endings или полная narrative migration.

## Основные риски

- В среде чата Godot не запускался; все scene/runtime изменения требуют локальной проверки.
- Production rebuild нельзя выполнять одним большим переписыванием.
- Внешние assets нельзя добавлять до проверки лицензии и оформления credits.
- Current prototype event flow должен оставаться проходимым во время миграции.
- Target Godot version 4.7+ нужно подтвердить локальной установленной сборкой перед началом CI/export work.