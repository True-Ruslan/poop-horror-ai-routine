# PRODUCTION_ROADMAP.md

Дата: 2026-07-12
Источник требований: `docs/superpowers/specs/2026-07-12-production-game-design.md`

## Цель

Перевести `AI Routine: Last Commit` из раннего greybox playable slice в законченную коммерчески публикуемую игру продолжительностью 45–60 минут.

## Milestone P0 — Production Foundation

- Новый `GameBootstrap` и управляемый scene flow.
- Версионирование проекта и build channels.
- `SettingsManager` и сохранение настроек.
- `SaveGameManager` с checkpoint, backup и schema version.
- Базовый `NarrativeDirector` и typed narrative flags.
- `EventSequenceRunner` с асинхронным завершением.
- Debug overlay и структурированное логирование.
- Headless project validation в CI.

Quality gate: проект запускается, старый playable slice доступен через адаптер, checkpoint сохраняется и загружается.

## Milestone P1 — Apartment Vertical Slice

- Новая планировка квартиры 38–45 м².
- Прихожая, коридор, основная комната, кухня и санузел.
- Production-prefab двери, терминала, лампы, телефона, колонки и электрощита.
- Базовый material library и lighting pass.
- Современный player feel и interaction components.
- Минимальный HUD, terminal focus mode и pause menu.

Quality gate: 10–15 минут игрового процесса без BoxMesh-мебели в критических зонах.

## Milestone P2 — Act I: Routine

- Полный пролог и первый акт.
- Правдоподобная бытовая рутина.
- Первые subtle-события.
- Surface footsteps и полноценный room tone.
- Русская и английская локализация текущего контента.

Quality gate: Act I проходится от новой игры до checkpoint без progression blockers.

## Milestone P3 — Act II: Observation

- Телефон, роутер и умный дом как narrative actors.
- Confirmed spatial changes.
- Dynamic audio snapshots.
- Fallback-подсказки и narrative validation.
- Условия секретного финала 1–3.

Quality gate: игрок понимает направление без внешних объяснений; загрузка checkpoint восстанавливает мир.

## Milestone P4 — Act III and Endings

- Impossible spatial transformations.
- Финальная терминальная последовательность.
- `MERGE`, `REVERT`, `BLACKOUT`, `CLEAN BUILD`.
- Checkpoint перед выбором.
- Ending gallery и chapter select после прохождения.

Quality gate: все четыре финала доступны по корректным условиям и проходят из экспортированной сборки.

## Milestone P5 — Content Complete

- Финальные модели, материалы, decals и prop dressing.
- Полный audio pass, voice/TTS и субтитры.
- Accessibility settings.
- Credits и asset/license manifest.
- Полная RU/EN редактура.

Quality gate: placeholders отсутствуют, лицензии подтверждены, контент заморожен.

## Milestone P6 — Release Candidate

- Windows export presets.
- Development, Playtest и Release configurations.
- Regression suite.
- Performance profiling и quality presets.
- Тестирование вне Godot Editor.
- Store metadata и release checklist.

Quality gate: версия `1.0.0` соответствует Definition of Done из production-спецификации.

## Правило реализации

Каждый milestone разбивается на небольшие PR. `main` должен оставаться запускаемым. Legacy-системы удаляются только после переноса их поведения и успешного regression check.