# AGENTS.md

Инструкции для Codex, Cursor, Claude Code и других code agents.

## Роль агента

Ты работаешь с Godot-проектом `AI Routine: Last Commit`.

Текущий `main` содержит ранний playable prototype. Цель проекта — production-игра на 45–60 минут, описанная в:

```text
docs/superpowers/specs/2026-07-12-production-rebuild-design.md
```

Нельзя трактовать prototype architecture, `BoxMesh` окружение и старый beat backlog как финальный design.

## Обязательный порядок чтения

Перед любой production-задачей:

```text
docs/AGENT_HANDOFF.md
docs/superpowers/specs/2026-07-12-production-rebuild-design.md
docs/PROJECT_STATE.md
docs/TASKS.md
docs/ROADMAP.md
docs/DECISIONS.md
docs/DOCUMENTATION_RULES.md
README.md
```

Для narrative:

```text
docs/SCENARIO.md
docs/GAME_DESIGN.md
docs/NARRATIVE_DESIGN.md
docs/SCENE_BEATS.md
docs/INTERACTION_MECHANICS.md
```

Для assets:

```text
docs/ASSET_SOURCES.md
docs/ASSET_TRANSITION_PLAN.md
docs/CREDITS.md
docs/LICENSE_CHECKLIST.md
```

Для audio:

```text
docs/SOUND_DESIGN.md
docs/CREDITS.md
```

Для export/release:

```text
docs/EXPORT_GUIDE.md
docs/ROADMAP.md
```

## Главные правила

1. Не переписывать всю игру одним PR.
2. Не ломать текущий regression route.
3. `main` после каждой итерации должен оставаться запускаемым.
4. Production systems сначала добавляются рядом с legacy systems через adapters.
5. Legacy manager удаляется только после regression-equivalent миграции.
6. Не добавлять external dependency без ADR, license check и credits.
7. Не добавлять asset без provenance и commercial-use rights.
8. Не добавлять combat, enemy AI, multiplayer, crafting или complex inventory без отдельного ADR.
9. Не подключать реальные AI API в gameplay 1.0.
10. Не добавлять Steam SDK до release milestone и отдельного решения.
11. Любая gameplay mechanic должна иметь test scene, automated check или короткий regression route.
12. Любой mandatory narrative beat имеет fallback и recoverable checkpoint state.
13. Пользовательские строки используют localization keys в новых production systems.
14. Motion/flash effects должны поддерживать accessibility control.
15. Если Godot не запускался, нельзя утверждать, что scene/runtime проверены.

## Текущий implementation gate

Written production spec проходит финальное user review.

До подтверждения нельзя начинать implementation.

После подтверждения сначала создаётся detailed implementation plan.

Первый code scope:

```text
P1.1 — Bootstrap and Logging
```

Разрешено:

- `GameBootstrap`;
- production main scene;
- typed logging;
- development/release flags;
- legacy adapter;
- minimal smoke check;
- documentation.

Не входит в P1.1:

- settings;
- saves;
- новая квартира;
- external assets;
- endings;
- полная narrative migration;
- переписывание всех objects;
- Steam SDK.

## Production architecture rules

Целевые services:

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

Principles:

- один service — одна ответственность;
- typed GDScript API;
- data-driven narrative через Godot Resources;
- stable IDs;
- structured logging;
- saveable state;
- no direct object-to-object progression chains in new code;
- async event считается завершённым только после фактического окончания actions.

## Interactive actor rules

Новые production objects строятся из components:

```text
InteractiveActor
InteractionComponent
VisualStateComponent
AudioEmitterComponent
HighlightComponent
SaveableComponent
```

Interaction types:

```text
Press
Hold
Toggle
Inspect
Focus
Choice
```

Нельзя использовать `has_method("interact")` как основной production interface.

## Code style

- Godot 4.7+.
- GDScript.
- Typed variables, parameters и return values для production code.
- `PascalCase.gd` для classes/actors/services.
- Stable IDs используют `StringName`, constants или Resources.
- Сигналы называют событиями: `settings_loaded`, `beat_started`, `checkpoint_saved`.
- Не хранить пользовательский текст в reusable object scripts.
- Не использовать магические NodePath/string links без необходимости.
- Сложную логику делить на небольшие testable units.
- Bootstrap не содержит narrative logic.
- UI не запускает diegetic 3D sounds.

## Assets and licenses

Разрешены после проверки:

- собственные assets;
- CC0;
- CC BY с attribution;
- commercial packs с подходящими redistribution terms.

Запрещены по умолчанию:

- ripped assets;
- unknown license;
- CC BY-NC;
- CC BY-ND;
- real logos/brands;
- assets из игр, фильмов и роликов;
- AI-generated assets без ясных commercial rights.

Каждый external asset обновляет:

```text
docs/CREDITS.md
license manifest
docs/PROJECT_STATE.md
docs/CHANGELOG.md
docs/TASKS.md
```

## Документационный минимум PR

Каждый code/scene/content PR:

```text
docs/TASKS.md
docs/CHANGELOG.md
docs/PROJECT_STATE.md
```

Дополнительно:

- architecture → `docs/DECISIONS.md`;
- roadmap/scope → `docs/ROADMAP.md`;
- narrative → `docs/SCENARIO.md` или `docs/SCENE_BEATS.md`;
- mechanics → `docs/INTERACTION_MECHANICS.md`;
- audio → `docs/SOUND_DESIGN.md`;
- assets → asset/license docs и `docs/CREDITS.md`;
- major workflow/status → `docs/AGENT_HANDOFF.md`;
- launch/controls/docs map → `README.md`.

## Definition of Done

Задача завершена, когда:

- scope соответствует текущему milestone;
- проект импортируется и основная scene запускается либо честно указан runtime blocker;
- current regression route не сломан;
- relevant automated checks добавлены или выполнены;
- manual test route описан;
- save/recovery рассмотрены для stateful feature;
- localization/accessibility рассмотрены для user-facing feature;
- external assets имеют license records;
- документация синхронизирована;
- известные ограничения перечислены.

## PR report

После изменения указать:

- что сделано;
- какие файлы изменены;
- архитектурное влияние;
- как проверить автоматически;
- как проверить вручную;
- что не было проверено;
- риски;
- следующий milestone step.