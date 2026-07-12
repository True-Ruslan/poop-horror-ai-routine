# AGENT_HANDOFF.md

Дата обновления: 2026-07-12

## Проект

```text
AI Routine: Last Commit
```

Repository:

```text
True-Ruslan/poop-horror-ai-routine
```

Base branch:

```text
main
```

Godot 4.7+, GDScript.

## Текущий этап

Проект завершил ранний playable prototype и находится на этапе:

```text
P0 — Design Lock
```

Согласованный целевой продукт:

- psychological horror от первого лица;
- 45–60 минут;
- одна квартира 38–45 м²;
- пролог и три акта;
- четыре финала: `MERGE`, `REVERT`, `BLACKOUT`, `CLEAN BUILD`;
- Windows release;
- Steam/itch.io preparation;
- RU/EN;
- accessibility settings;
- без combat и традиционного AI-врага.

Главный production spec:

```text
docs/superpowers/specs/2026-07-12-production-rebuild-design.md
```

Перед любыми production-изменениями этот документ обязателен к прочтению.

## Порядок чтения

1. `docs/AGENT_HANDOFF.md`.
2. `docs/superpowers/specs/2026-07-12-production-rebuild-design.md`.
3. `docs/PROJECT_STATE.md`.
4. `docs/TASKS.md`.
5. `docs/ROADMAP.md`.
6. `docs/DECISIONS.md`.
7. `docs/DOCUMENTATION_RULES.md`.
8. `README.md`.

Для narrative work дополнительно:

- `docs/SCENARIO.md`;
- `docs/NARRATIVE_DESIGN.md`;
- `docs/SCENE_BEATS.md`;
- `docs/INTERACTION_MECHANICS.md`.

Для assets:

- `docs/ASSET_SOURCES.md`;
- `docs/ASSET_TRANSITION_PLAN.md`;
- `docs/CREDITS.md`;
- `docs/LICENSE_CHECKLIST.md`.

Для audio:

- `docs/SOUND_DESIGN.md`;
- `docs/CREDITS.md`.

## Что находится в main

Основная prototype scene:

```text
game/scenes/Main.tscn
```

Она загружает:

```text
game/scenes/levels/DeveloperApartment.tscn
game/scenes/ui/HUD.tscn
```

Prototype route:

```text
стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch
```

Implemented event IDs:

```text
task_sticker_read
terminal_first_ai_reply
smart_lock_denied
speaker_wrong_name
terminal_device_list
hud_objective_corrupt
```

Prototype systems:

- `GameState`;
- `ObjectiveManager`;
- `HorrorEventManager`;
- `ApartmentEventController`;
- `PlayerController`;
- `InteractionRaycast`;
- `FlashlightController`;
- `HUD`.

Prototype objects:

- `InteractableNote`;
- `InteractableDoor`;
- `LightSwitch`;
- `ComputerTerminal`;
- `SmartSpeaker`.

## Что нельзя считать production-ready

- `DeveloperApartment.tscn` — rectangular greybox с `BoxMesh`.
- Дверь, записка, выключатель, монитор, мебель и колонка — placeholders.
- Narrative progression встроен в object scripts и строковые event IDs.
- `HorrorEventManager` не выполняет полноценные async sequences.
- Сохранения, checkpoints и migrations отсутствуют.
- Меню, settings, localization и accessibility отсутствуют.
- Audio buses и production SFX отсутствуют.
- Tests, CI и export presets отсутствуют.
- Большинство prototype changes не были локально проверены в Godot после merge.

## Согласованная production-архитектура

Core services:

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

Narrative и objectives переносятся в Godot Resources.

Новые интерактивные объекты строятся как component-based actors:

```text
InteractiveActor
InteractionComponent
VisualStateComponent
AudioEmitterComponent
HighlightComponent
SaveableComponent
```

## Правила миграции

1. Не переписывать всю игру одним PR.
2. Не удалять legacy route до regression-equivalent реализации.
3. Сначала добавить production core рядом со старыми managers.
4. Использовать legacy adapters.
5. Переносить объекты по одному типу.
6. Сохранять запускаемый `main`.
7. Любое новое состояние должно быть восстанавливаемым из checkpoint.
8. Любой внешний asset должен иметь provenance и license record.

## Текущая задача

Written production spec создан и проходит review.

До его подтверждения нельзя начинать реализацию.

После подтверждения следующий обязательный шаг:

```text
Создать implementation plan для P1 — Foundation Rebuild.
```

Первый implementation PR должен ограничиваться:

- `GameBootstrap`;
- production main scene;
- typed logging;
- `SettingsManager` foundation;
- legacy adapter для текущей квартиры;
- минимальным tests/CI skeleton;
- документацией.

В него нельзя одновременно включать:

- новую production-квартиру;
- внешние models/textures/audio;
- финалы;
- полную narrative migration;
- переписывание всех objects;
- Steam SDK.

## Документационный минимум PR

Каждый code/scene/content PR обновляет:

- `docs/TASKS.md`;
- `docs/CHANGELOG.md`;
- `docs/PROJECT_STATE.md`.

Дополнительно:

- architecture → `docs/DECISIONS.md`;
- roadmap/scope → `docs/ROADMAP.md`;
- narrative → `docs/SCENARIO.md` или `docs/SCENE_BEATS.md`;
- mechanics → `docs/INTERACTION_MECHANICS.md`;
- audio → `docs/SOUND_DESIGN.md`;
- assets → `docs/CREDITS.md` и asset/license documents;
- major handoff change → `docs/AGENT_HANDOFF.md`.

## Definition of Done для production PR

- scope соответствует milestone;
- main scene запускается;
- regression route не сломан;
- relevant automated checks добавлены или пройдены;
- manual test route описан;
- документация обновлена;
- новые assets имеют лицензии;
- известные ограничения перечислены;
- агент не утверждает, что Godot проверен локально, если он не запускался.