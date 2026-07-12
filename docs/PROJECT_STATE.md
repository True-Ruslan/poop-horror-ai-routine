# PROJECT_STATE.md

Дата обновления: 2026-07-12

## Текущий статус

Проект находится в `P1 — Foundation Rebuild`, подэтап `P1.1 — Bootstrap and Logging`.

Целевой продукт остаётся без изменений: first-person psychological horror на 45–60 минут, одна квартира 38–45 м², пролог, три акта, четыре финала (`MERGE`, `REVERT`, `BLACKOUT`, `CLEAN BUILD`), Windows, RU/EN и accessibility.

## Текущий prototype

Regression route:

```text
стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch
```

Legacy systems сохраняются:

- `GameState`;
- `ObjectiveManager`;
- `HorrorEventManager`;
- `ApartmentEventController`;
- текущие scenes и event IDs.

## Что добавлено в P1.1

- `GameLog` — typed logging service с level filtering и production-категориями.
- `LegacyProgressionAdapter` — зеркалирует legacy `horror_event_started` в `StringName` state, не управляя progression.
- `GameBootstrap` — проверяет наличие обязательных autoload и выдаёт health report.
- `HorrorEventManager` пишет diagnostics через `GameLog`, не меняя public signals, callback order и one-shot behavior.
- dependency-free unit/smoke test scripts.
- новые autoload зарегистрированы в безопасном порядке: `GameLog` до менеджеров, которые используют diagnostics; `GameBootstrap` последним.

## Scope exclusions P1.1

Не добавлены:

- settings и saves;
- production main scene/menu;
- новая квартира и assets;
- `NarrativeDirector` и `EventSequenceRunner`;
- CI/export;
- изменения игрового narrative route.

## Validation status

Проведены review gates:

- spec/API review;
- autoload ordering review;
- diff scope review;
- TDD test-first commit ordering.

Не выполнены в среде чата:

- Godot parse/import;
- unit/smoke execution;
- manual regression route.

Причина: container network не может клонировать GitHub, Godot CLI недоступен. Эти проверки являются обязательным merge gate и явно перечислены в draft PR.

## Следующий шаг

После успешного Godot 4.7+ validation и review P1.1 можно завершить. P1.2 начинается только отдельной веткой и PR.
