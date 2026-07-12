# DECISIONS.md

Журнал архитектурных и продуктовых решений. Детальные ранние формулировки доступны в git history и production spec.

## Сводка действующих решений

- ADR-0001: Godot 4.7+ и typed GDScript.
- ADR-0002: horror строится на scripted events, а не на традиционном AI-враге.
- ADR-0003: интерактивные объекты оформляются отдельными сценами.
- ADR-0004: репозиторий развивается как `AI Routine: Last Commit`.
- ADR-0005: первая локация — квартира разработчика.
- ADR-0006: внешние assets допускаются только с commercial-use лицензией и credits.
- ADR-0007: upstream template синхронизируется только осознанно.
- ADR-0008: production scope — 45–60 минут, пролог, три акта, четыре финала.
- ADR-0009: одна production-квартира 38–45 м².
- ADR-0010: grounded stylized realism; PSX/VHS только как сюжетный эффект.
- ADR-0011: data-driven narrative через Godot Resources.
- ADR-0012: `NarrativeDirector` и async `EventSequenceRunner`.
- ADR-0013: component-based interactive actors.
- ADR-0014: autosave/checkpoints/backup без ручного save menu.
- ADR-0015: минимальный HUD и отдельные terminal/phone/inspect modes.
- ADR-0016: production rebuild выполняется через legacy adapters.
- ADR-0017: RU/EN и accessibility входят в 1.0.
- ADR-0018: CI, narrative validation и Development/Playtest/Release channels.

## ADR-0019 — P1.1 services coexist with legacy autoloads

Дата: 2026-07-12

Решение:

- `GameLog`, `LegacyProgressionAdapter` и `GameBootstrap` добавляются рядом с `GameState`, `ObjectiveManager` и `HorrorEventManager`.
- `GameLog` загружается до `HorrorEventManager`, чтобы ранняя диагностика была доступна безопасно.
- `LegacyProgressionAdapter` только наблюдает `horror_event_started` и не меняет objective или event flow.
- `GameBootstrap` загружается последним и проверяет наличие обязательных services.
- Public API и синхронное поведение `HorrorEventManager` в P1.1 не меняются.

Причина:

- production foundation нужно вводить без big-bang rewrite;
- существующий playable route должен оставаться regression baseline;
- bootstrap health и structured logs нужны до settings, saves и narrative migration;
- service ordering должен быть явным и проверяемым.

Последствия:

- в проекте временно сосуществуют legacy и production services;
- adapter state не является authoritative progression state;
- удаление legacy managers возможно только после будущей data-driven migration;
- Godot parse/smoke/regression verification обязателен перед merge P1.1.
