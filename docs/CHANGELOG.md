# CHANGELOG.md

Формат основан на Keep a Changelog. Полная детализация ранних prototype-итераций доступна в git history.

## [0.4.1] — 2026-07-12

### Added

- `GameLog` с typed levels и категориями `GAME`, `NARRATIVE`, `SAVE`, `INTERACTION`, `AUDIO`, `UI`, `ASSET`, `PERFORMANCE`.
- `LegacyProgressionAdapter` для наблюдения за существующими event IDs без управления progression.
- `GameBootstrap` с health report обязательных autoload.
- Dependency-free unit/smoke test scripts для logging, adapter, legacy event compatibility и bootstrap.

### Changed

- `HorrorEventManager` пишет structured diagnostics, сохраняя существующие signals, callback order и one-shot semantics.
- Новые services зарегистрированы в `project.godot` рядом с legacy autoload.
- Project documentation переведена на P1.1.

### Validation

- Выполнены spec/API, scope и autoload-order reviews.
- Godot CLI tests и manual regression route не выполнялись в среде чата и остаются обязательным merge gate.

## [0.4.0-design] — 2026-07-12

- Добавлены production design spec и P1 implementation plan.
- Зафиксированы scope 45–60 минут, одна квартира, три акта, четыре финала и milestones P0–P8.
- Обновлены architecture, scenario, art, audio, roadmap и handoff.

## Prototype history — 2026-07-07

- `0.3.6`: HUD objective corruption после terminal device list.
- `0.3.5`: terminal device list.
- `0.3.4`: smart-lock refusal.
- `0.3.3`: Smart Speaker event.
- `0.3.2`: apartment layout and asset transition plan.
- `0.3.1`: first procedural sound pass.
- `0.3.0`: apartment event controller and lamp response.
- `0.2.4`: narrative, interaction, sound and scene-beat documents.
- `0.2.3`: mouse camera fix.
- `0.2.0`: game concept and developer apartment.
- `0.1.0`: initial Godot template and prototype systems.
