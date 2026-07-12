# AGENT_HANDOFF.md

Дата обновления: 2026-07-12

## Проект

`AI Routine: Last Commit` — Godot 4.7+, typed GDScript.

Repository: `True-Ruslan/poop-horror-ai-routine`.

## Обязательное чтение

1. `docs/superpowers/specs/2026-07-12-production-rebuild-design.md`.
2. `docs/superpowers/plans/2026-07-12-p1-foundation-rebuild.md`.
3. `docs/PROJECT_STATE.md`.
4. `docs/TASKS.md`.
5. `docs/DECISIONS.md`.
6. `docs/DOCUMENTATION_RULES.md`.

## Текущий этап

```text
P1.1 — Bootstrap and Logging
```

Ветка реализации:

```text
agent/p1-bootstrap-logging
```

Она основана на `agent/production-rebuild-design`, поэтому PR должен быть stacked до merge PR #13.

## Реализовано в P1.1

- `game/scripts/core/GameLog.gd`;
- `game/scripts/core/LegacyProgressionAdapter.gd`;
- `game/scripts/core/GameBootstrap.gd`;
- structured diagnostics в `HorrorEventManager.gd`;
- autoload registration в `project.godot`;
- dependency-free tests в `tests/unit` и `tests/smoke`.

## Неподвижные ограничения

- Не удалять `GameState`, `ObjectiveManager` или `HorrorEventManager`.
- Не менять regression route:

```text
стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch
```

- `LegacyProgressionAdapter` только наблюдает event IDs.
- `GameBootstrap` не содержит narrative logic.
- P1.1 не включает settings, saves, menus, новую квартиру, assets, endings, CI или export.

## Обязательная проверка перед merge

На машине с Godot 4.7+:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script tests/unit/TestGameLog.gd
godot --headless --path . --script tests/unit/TestLegacyProgressionAdapter.gd
godot --headless --path . --script tests/unit/TestHorrorEventManager.gd
godot --headless --path . --script tests/smoke/TestBootstrapSmoke.gd
```

Затем вручную пройти regression route и проверить:

- нет parse/runtime errors;
- события срабатывают один раз;
- adapter наблюдает existing event IDs;
- `GameBootstrap.get_health_report()` возвращает `true` для всех required services;
- gameplay и objective order не изменились.

## Известный blocker среды чата

Container не смог разрешить `github.com`, а Godot CLI недоступен. Поэтому код прошёл static review, но runtime validation не выполнен. Не отмечать PR ready и не merge до выполнения команд выше.

## Следующий этап

После merge P1.1 создать отдельную ветку для `P1.2 — Settings Foundation`. Не добавлять P1.2 в текущий PR.
