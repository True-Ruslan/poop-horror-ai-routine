# AI Routine: Last Commit

Психологический хоррор от первого лица на **Godot 4.7+** про разработчика, вечернюю рабочую рутину, код-агента и квартиру, которая постепенно начинает выполнять цифровые изменения в физическом пространстве.

## Текущий статус

В `main` находится ранний playable prototype:

```text
стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch
```

Проект переходит к production rebuild.

Целевая версия 1.0:

- 45–60 минут;
- одна детализированная квартира;
- пролог и три акта;
- четыре финала;
- Windows;
- Steam/itch.io preparation;
- RU/EN;
- accessibility settings;
- без combat и традиционного AI-врага.

Главный production design:

```text
docs/superpowers/specs/2026-07-12-production-rebuild-design.md
```

## Что уже есть

- Godot project.
- First-person movement, sprint и crouch.
- Flashlight.
- Interaction raycast.
- HUD.
- Objective и one-shot horror event managers.
- Greybox `DeveloperApartment.tscn`.
- Interactable note, door, switch, terminal и Smart Speaker.
- Prototype event route до HUD objective glitch.
- Procedural placeholder notification и lamp click.
- Scenario, narrative, interaction, audio и asset documentation.

Текущие models, materials, UI и audio являются prototype placeholders и не отражают release quality.

## Быстрый старт prototype

1. Установить Godot 4.7 или совместимую более новую версию.
2. Открыть корень проекта в Godot.
3. Запустить `game/scenes/Main.tscn`.
4. Проверить Output на ошибки.

## Управление prototype

| Действие | Клавиша |
|---|---|
| Движение | WASD |
| Бег | Shift |
| Присесть | Ctrl |
| Взаимодействие | E |
| Фонарик | F |
| Закрыть сообщение / пауза | Esc |

Управление и HUD будут заменяться в production milestones, но regression route должен сохраняться во время миграции.

## Порядок чтения

1. `docs/AGENT_HANDOFF.md` — актуальный вход для нового агента.
2. `docs/superpowers/specs/2026-07-12-production-rebuild-design.md` — согласованный production design.
3. `docs/PROJECT_STATE.md` — текущее состояние.
4. `docs/TASKS.md` — executable backlog.
5. `docs/ROADMAP.md` — milestones P0–P8.
6. `docs/DECISIONS.md` — ADR.
7. `docs/DOCUMENTATION_RULES.md` — правила синхронизации документов.
8. `AGENTS.md` — правила code agents.

Narrative:

- `docs/SCENARIO.md`;
- `docs/GAME_DESIGN.md`;
- `docs/NARRATIVE_DESIGN.md`;
- `docs/SCENE_BEATS.md`;
- `docs/INTERACTION_MECHANICS.md`.

Art/assets:

- `docs/ASSET_TRANSITION_PLAN.md`;
- `docs/ASSET_SOURCES.md`;
- `docs/LICENSE_CHECKLIST.md`;
- `docs/CREDITS.md`.

Audio:

- `docs/SOUND_DESIGN.md`;
- `docs/CREDITS.md`.

Release:

- `docs/EXPORT_GUIDE.md`;
- `docs/ROADMAP.md`.

## Текущий следующий шаг

После финального review production spec:

```text
создать implementation plan для P1 — Foundation Rebuild
```

Первый code PR:

```text
P1.1 — Bootstrap and Logging
```

Он должен добавить production bootstrap и legacy adapter, не переписывая сразу всю игру.

## Правило каждой итерации

Code/scene/content PR обновляет минимум:

- `docs/TASKS.md`;
- `docs/CHANGELOG.md`;
- `docs/PROJECT_STATE.md`.

Architecture, narrative, audio и assets требуют обновления соответствующих source-of-truth документов.

## Ассеты и лицензии

- Код проекта: MIT.
- Внешний ресурс добавляется только после проверки commercial-use rights.
- CC0 предпочтителен.
- CC BY требует attribution.
- CC BY-NC, CC BY-ND, unknown и ripped assets запрещены без отдельного решения.
- Каждый внешний ресурс фиксируется в `docs/CREDITS.md` и будущем license manifest.

## Важное ограничение проверки

Изменения, созданные через GitHub-агента без локального Godot runtime, нельзя считать проверенными в Editor или exported build. Manual test route и локальная проверка обязательны.