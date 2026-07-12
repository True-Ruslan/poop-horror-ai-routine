# TASKS.md

## Статусы

- `[ ]` — не начато.
- `[~]` — в работе.
- `[x]` — завершено.

## История prototype-итераций

Завершённые итерации сохранены в git history и `docs/CHANGELOG.md`.

- [x] Iteration 0 — Base Template.
- [x] Iteration 1 — Game Foundation.
- [x] Iteration 1.5 — Narrative and Interaction Design.
- [x] Iteration 2 — First Real Horror Event.
- [x] Iteration 2.5 — First Sound Pass, кроме локальной проверки громкости.
- [x] Iteration 2.75 — Room Layout and Asset Transition.
- [x] Iteration 3 — Smart Speaker.
- [x] Iteration 3.5 — Door Refusal.
- [x] Iteration 3.75 — Terminal Device List.
- [x] Iteration 3.9 — HUD Objective Glitch.

Текущий prototype route:

```text
стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch
```

Production rebuild не должен удалять этот маршрут до появления эквивалентного regression route.

## P0 — Design Lock

Цель: официально зафиксировать переход от короткого greybox prototype к production-игре на 45–60 минут.

- [x] Провести аудит кода, сцен, визуала, звука, документации и release pipeline.
- [x] Выбрать масштаб: одна глубоко проработанная квартира, пролог, три акта, четыре финала.
- [x] Согласовать production-архитектуру.
- [x] Согласовать планировку и grounded stylized realism.
- [x] Согласовать player feel, interaction contract, terminal/phone modes и HUD.
- [x] Согласовать audio architecture и narrative pipeline.
- [x] Согласовать save/checkpoint, testing, CI и release channels.
- [x] Создать `docs/superpowers/specs/2026-07-12-production-rebuild-design.md`.
- [~] Обновить project state, roadmap, decisions, handoff и changelog.
- [ ] Провести final spec self-review.
- [ ] Получить подтверждение written spec.
- [ ] Создать подробный implementation plan для P1.

Definition of Done:

- production scope не содержит `TBD`;
- документы не противоречат выбранному масштабу;
- первый implementation scope ограничен Foundation Rebuild;
- никакой игровой код не изменён до подтверждения written spec.

## P1 — Foundation Rebuild

Цель: создать production core, сохранив возможность запускать текущий prototype.

### P1.1 — Bootstrap and logging

- [ ] Создать `GameBootstrap`.
- [ ] Создать production main scene.
- [ ] Добавить typed logging service с категориями `GAME`, `NARRATIVE`, `SAVE`, `INTERACTION`, `AUDIO`, `UI`, `ASSET`, `PERFORMANCE`.
- [ ] Загружать текущий playable slice через legacy adapter.
- [ ] Добавить development/release feature flags.
- [ ] Обновить документацию.

Definition of Done:

- production main scene запускает текущую квартиру;
- legacy route не удалён;
- bootstrap не содержит narrative logic;
- логи имеют категории и могут отключаться в release mode.

### P1.2 — Settings foundation

- [ ] Создать `SettingsManager`.
- [ ] Сохранять и загружать versioned settings file.
- [ ] Добавить master volume, mouse sensitivity, invert Y, fullscreen и VSync.
- [ ] Применять настройки при старте.
- [ ] Добавить unit tests сериализации.

Definition of Done:

- настройки переживают перезапуск;
- повреждённый settings file восстанавливается значениями по умолчанию;
- текущий player использует sensitivity/invert из manager.

### P1.3 — Save foundation

- [ ] Создать versioned save schema.
- [ ] Создать `SaveGameManager`.
- [ ] Добавить autosave, backup и checkpoint ID.
- [ ] Добавить безопасное восстановление повреждённого save.
- [ ] Добавить unit tests и migration fixture.

Definition of Done:

- save round-trip проходит тест;
- backup не перезаписывается повреждёнными данными;
- prototype route можно восстановить из минимального checkpoint state.

### P1.4 — Scene flow and menu shell

- [ ] Создать `SceneFlowManager`.
- [ ] Создать main menu shell.
- [ ] Создать pause menu shell.
- [ ] Добавить Continue/New Game/Settings/Credits/Exit.
- [ ] Добавить переход в legacy playable slice.
- [ ] Добавить безопасный возврат в меню.

### P1.5 — Tests and CI skeleton

- [ ] Создать `tests/unit`, `tests/integration`, `tests/narrative`, `tests/smoke`.
- [ ] Добавить headless import check.
- [ ] Добавить GitHub Actions workflow.
- [ ] Добавить smoke test production main scene.
- [ ] Добавить проверку отсутствующих localization keys и resource paths.

## P2 — Apartment Vertical Slice

Цель: собрать одну production-зону с финальным quality bar.

- [ ] Создать blockout квартиры 38–45 м²: прихожая, коридор, комната, кухня, санузел.
- [ ] Создать component-based `InteractiveActor`.
- [ ] Перевести одну дверь, один выключатель и терминал на новые компоненты.
- [ ] Переработать player movement и camera feel.
- [ ] Создать terminal focus mode.
- [ ] Создать минимальный AudioDirector и buses.
- [ ] Реализовать один data-driven beat от начала до checkpoint.
- [ ] Провести performance и accessibility check.

## P3 — Environment Production

- [ ] Создать production architecture models.
- [ ] Создать material library.
- [ ] Заменить рабочее место, дверь и ключевые устройства.
- [ ] Добавить prop dressing.
- [ ] Добавить production lighting.
- [ ] Добавить room tones и spatial SFX.
- [ ] Настроить occlusion culling, visibility ranges и shadow budgets.
- [ ] Удалить release-facing `BoxMesh` placeholders.

## P4 — Prologue and Act I

- [ ] Реализовать вечернюю бытовую рутину.
- [ ] Реализовать первый terminal reply.
- [ ] Реализовать lamp response и smart-lock failure.
- [ ] Создать phone foundation.
- [ ] Создать RU/EN localization pipeline.
- [ ] Завершить main/pause/settings UI.
- [ ] Добавить required accessibility settings.

## P5 — Act II: Observation

- [ ] Реализовать device list и наблюдение квартиры.
- [ ] Реализовать изменяющиеся сообщения телефона.
- [ ] Реализовать speaker pre-response.
- [ ] Реализовать subtle/confirmed spatial changes.
- [ ] Добавить secret ending prerequisites.
- [ ] Провести comprehension playtest.

## P6 — Act III and Endings

- [ ] Реализовать impossible spatial changes.
- [ ] Реализовать final terminal sequence.
- [ ] Реализовать `MERGE`.
- [ ] Реализовать `REVERT`.
- [ ] Реализовать `BLACKOUT`.
- [ ] Реализовать `CLEAN BUILD`.
- [ ] Добавить ending checkpoint и replay route.

## P7 — Content Complete

- [ ] Удалить все placeholder assets, texts и sounds.
- [ ] Завершить voice/subtitles/captions.
- [ ] Провести RU/EN proofreading.
- [ ] Завершить credits и license manifest.
- [ ] Провести accessibility pass.
- [ ] Проверить все chapters и endings.

## P8 — Release Candidate

- [ ] Добавить `export_presets.cfg`.
- [ ] Создать Windows playtest и release builds.
- [ ] Провести compatibility matrix.
- [ ] Стабилизировать производительность.
- [ ] Провести финальный license audit.
- [ ] Подготовить Steam/itch.io metadata и media.
- [ ] Проверить сборку вне Godot Editor.

## Текущий следующий шаг

После подтверждения written production spec:

```text
Создать implementation plan для P1 — Foundation Rebuild.
```

Первый code PR не должен включать новую квартиру, внешние ассеты, финалы или полную миграцию narrative systems.