# ROADMAP.md

Дата обновления: 2026-07-12

## Цель roadmap

Проект переходит от раннего 15–25-минутного prototype к законченной production-игре продолжительностью 45–60 минут.

Полный дизайн:

```text
docs/superpowers/specs/2026-07-12-production-rebuild-design.md
```

## Исторический prototype

Завершено:

- Godot template foundation;
- first-person movement и flashlight;
- interaction raycast и HUD;
- greybox `DeveloperApartment`;
- task sticker;
- first terminal reply;
- lamp response;
- door refusal;
- Smart Speaker;
- terminal device list;
- HUD objective glitch;
- procedural placeholder sounds;
- базовая design-документация.

Prototype остаётся regression route во время production rebuild.

## Целевой продукт 1.0

- Windows release;
- Steam и itch.io preparation;
- 45–60 минут;
- пролог и три акта;
- одна квартира 38–45 м²;
- grounded stylized realism;
- четыре финала;
- RU/EN;
- accessibility settings;
- checkpoint/autosave;
- без combat и традиционного AI-врага.

## P0 — Design Lock

Статус: в работе.

Результат:

- согласован production scope;
- создан единый production design spec;
- обновлены sources of truth;
- определён безопасный первый implementation scope.

Quality gate:

- письменный spec подтверждён;
- нет `TBD`, противоречий и скрытого расширения scope;
- implementation ещё не начат.

## P1 — Foundation Rebuild

Статус: следующий milestone.

Результат:

- `GameBootstrap`;
- production main scene;
- `SceneFlowManager`;
- `SettingsManager`;
- `SaveGameManager`;
- typed logging;
- development/release modes;
- test skeleton;
- CI skeleton;
- legacy adapter для текущего playable slice.

Quality gate:

- текущая квартира запускается через production bootstrap;
- настройки сохраняются;
- save round-trip проходит tests;
- smoke test запускается headless;
- main остаётся играбельным.

## P2 — Apartment Vertical Slice

Результат:

- production blockout квартиры;
- прихожая, коридор, комната, кухня, санузел;
- modern player feel;
- component-based interactions;
- terminal focus mode;
- AudioDirector foundation;
- один data-driven beat от начала до checkpoint;
- initial accessibility support.

Quality gate:

- один маршрут демонстрирует целевой quality bar;
- no progression blockers;
- 1080p performance измерена;
- нет зависимости от legacy objective chaining внутри новых объектов.

## P3 — Environment Production

Результат:

- финальная архитектурная геометрия;
- PBR material library;
- production critical props;
- lighting pass;
- room tones и spatial SFX;
- prop dressing;
- optimization pass;
- отсутствие release-facing greybox placeholders.

Quality gate:

- квартира выглядит жилой и стилистически цельной;
- все новые ассеты имеют подтверждённые лицензии;
- важные объекты читаются без агрессивного outline;
- производительность соответствует budget.

## P4 — Prologue and Act I: Routine

Результат:

- вечерняя бытовая рутина;
- первый personal terminal reply;
- lamp response;
- smart-lock failure;
- phone foundation;
- full menu/settings shell;
- RU/EN localization pipeline;
- required accessibility options.

Quality gate:

- игрок понимает квартиру и цели без объяснений разработчика;
- невозможные spatial events ещё не появляются;
- Act I восстанавливается из checkpoint.

## P5 — Act II: Observation

Результат:

- terminal device observation;
- phone history changes;
- speaker pre-response;
- subtle и confirmed spatial changes;
- secret ending prerequisites;
- expanded narrative and audio events.

Quality gate:

- игрок замечает escalation;
- обязательный путь не зависит от optional clues;
- `CLEAN BUILD` conditions корректно сохраняются.

## P6 — Act III and Endings

Результат:

- impossible spatial transformations;
- final terminal sequence;
- `MERGE`;
- `REVERT`;
- `BLACKOUT`;
- `CLEAN BUILD`;
- checkpoint перед финальным выбором.

Quality gate:

- все финалы достижимы;
- checkpoint позволяет повторить выбор;
- ending conditions покрыты tests;
- ни один финал не требует полного повторного прохождения.

## P7 — Content Complete

Результат:

- все главы играбельны;
- placeholder assets/sounds/texts удалены;
- subtitles и sound captions завершены;
- RU/EN proofreading;
- credits и license manifest;
- accessibility pass;
- полный audio mix.

Quality gate:

- content lock;
- отсутствуют известные progression blockers;
- все обязательные assets имеют provenance.

## P8 — Release Candidate

Результат:

- `export_presets.cfg`;
- Windows development/playtest/release builds;
- compatibility testing;
- performance stabilization;
- final license audit;
- store metadata и media;
- release checklist.

Quality gate:

- сборка проверена вне Godot Editor;
- release build не содержит debug overlay;
- save migration и backup recovery проверены;
- достигнут Definition of Done 1.0.

## Версионирование production-линейки

```text
0.1.x — production architecture foundation
0.2.x — apartment vertical slice
0.3.x — Act I
0.4.x — Act II
0.5.x — Act III and endings
0.8.x — content complete
0.9.x — release candidates
1.0.0 — public release
```

Исторические prototype-версии остаются в `docs/CHANGELOG.md`.