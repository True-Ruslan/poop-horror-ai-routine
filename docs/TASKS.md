# TASKS.md

## Статусы

- `[ ]` — не начато.
- `[~]` — в работе.
- `[x]` — завершено.

## Prototype history

Завершены Iteration 0–3.9. Regression route сохраняется:

```text
стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch
```

## P0 — Design Lock

- [x] Согласовать production scope, architecture, art, UX, audio, testing и release strategy.
- [x] Создать production spec.
- [x] Создать P1 implementation plan.
- [x] Получить подтверждение пользователя.

## P1 — Foundation Rebuild

### P1.1 — Bootstrap and Logging

- [x] Добавить dependency-free test assertions.
- [x] Добавить тесты `GameLog`, legacy adapter, legacy event behavior и bootstrap health.
- [x] Создать typed `GameLog` с категориями `GAME`, `NARRATIVE`, `SAVE`, `INTERACTION`, `AUDIO`, `UI`, `ASSET`, `PERFORMANCE`.
- [x] Создать `LegacyProgressionAdapter` без изменения progression.
- [x] Создать `GameBootstrap` с health report.
- [x] Добавить structured diagnostics в `HorrorEventManager`, сохранив его API и синхронное поведение.
- [x] Зарегистрировать новые autoload после обязательных legacy services.
- [x] Обновить документацию.
- [ ] Выполнить Godot 4.7+ parse/unit/smoke tests.
- [ ] Пройти regression route вручную.

Runtime validation остаётся обязательным merge gate: среда чата не имеет доступного Godot CLI и не может клонировать GitHub через container network.

### P1.2 — Settings Foundation

- [ ] `GameSettings`, `SettingsStore`, `SettingsManager`.
- [ ] JSON round-trip и invalid-file recovery tests.

### P1.3 — Checkpoint Save Foundation

- [ ] `SaveSnapshot`, `SaveStore`, `SaveGameManager`.
- [ ] Primary/backup/corruption recovery tests.

### P1.4 — Headless Validation and CI

- [ ] Unified test runner.
- [ ] Local validation script.
- [ ] GitHub Actions Godot validation.

### P1.5 — Versioning and Windows Export

- [ ] Build metadata.
- [ ] Windows development export preset.
- [ ] Manual CI artifact build.

## P2–P8

Дальнейшие milestones определены в `docs/ROADMAP.md` и production spec. P1.1 не включает settings, saves, scene flow, новую квартиру, external assets, endings или narrative migration.
