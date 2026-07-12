# AI Routine: Last Commit — Production Rebuild Design

Дата: 2026-07-12  
Статус: разделы согласованы; written spec ожидает финального review  
Целевая версия: 1.0.0  
Целевая платформа первого релиза: Windows  
Целевые storefronts: Steam, itch.io

## 1. Назначение

Документ фиксирует переход `AI Routine: Last Commit` от раннего greybox prototype к законченной одиночной psychological horror game продолжительностью 45–60 минут.

Текущий playable slice сохраняется как regression route и источник уже работающих сценарных идей, но не считается production-архитектурой или финальным визуальным представлением.

Этот документ является основным источником правды для:

- масштаба продукта;
- истории и финалов;
- core architecture;
- квартиры и art direction;
- player experience;
- interaction/UI/accessibility;
- audio;
- saves;
- testing, CI и release.

## 2. Product definition

`AI Routine: Last Commit` — first-person psychological horror без боевой системы, традиционного преследующего монстра и сложного инвентаря.

Целевая продолжительность первого прохождения: 45–60 минут.

Главная эмоция:

> Я понимаю, что нужно сделать, но не хочу снова смотреть на монитор.

Страх строится через нарушение вечерней рабочей рутины, реакцию квартиры на цифровые действия, пространственный звук, свет, интерфейс и изменение знакомого пространства.

### Неподвижные ограничения

- Без combat.
- Без традиционного AI-врага и длительных погонь.
- Без сложного inventory/crafting.
- Без необходимости писать настоящий код.
- Без реальных внешних AI API в gameplay.
- Без постоянных скримеров.
- Без копирования реальных интерфейсов, брендов, сюжетов и ассетов.
- Игрок почти всегда понимает бытовую цель.
- Любой внешний ресурс имеет проверенные commercial-use права.

## 3. Структура игры

### 3.1. Пролог — 5–8 минут

Игрок знакомится с квартирой через обычную вечернюю рутину:

- включает компьютер;
- проверяет рабочие сообщения;
- ставит чайник или кофе;
- закрывает окно;
- проверяет дверь;
- запускает последнюю сборку.

Явный хоррор отсутствует. Квартира должна стать знакомой и безопасной.

### 3.2. Акт I — Routine — 10–15 минут

- агент даёт слишком личный ответ;
- лампа реагирует на терминал;
- уведомление звучит не из ожидаемого устройства;
- smart lock выдаёт объяснимую ошибку;
- Smart Speaker нарушает timing;
- игрок ещё может рационализировать происходящее.

Impossible spatial changes запрещены.

### 3.3. Акт II — Observation — 15–20 минут

- терминал перечисляет реальные предметы квартиры;
- телефон получает невозможные сообщения;
- история сообщений меняется;
- колонка отвечает до команды;
- предметы меняют положение;
- квартира повторяет действия игрока;
- появляются clues секретного финала.

Разрешены `subtle` и `confirmed` spatial changes.

### 3.4. Акт III — Last Commit — 15–20 минут

- коридор меняет длину;
- двери ведут в неправильные зоны;
- интерфейс становится ненадёжным;
- терминал предсказывает действия;
- квартира становится физическим продолжением приложения;
- игрок получает доступ к финальному выбору.

Разрешены `impossible` spatial changes.

### 3.5. Финалы

#### MERGE

Игрок принимает изменения. Дверь открывается, но система выходит за пределы квартиры.

#### REVERT

Игрок откатывает изменения. Квартира возвращается в норму, но в истории остаётся неизвестный автор.

#### BLACKOUT

Игрок отключает питание. Финал завершается в темноте и почти полной тишине.

#### CLEAN BUILD

Секретный финал требует:

- заметить расхождение времени первого коммита;
- найти изменившийся локальный файл;
- сопоставить устройство с записью роутера;
- не выполнить одну команду агента;
- отключить сетевой кабель до final sequence.

Перед финальным выбором создаётся checkpoint. Игрок может открыть обычные альтернативные финалы без полного replay.

## 4. Core architecture

Целевая структура сервисов:

```text
GameBootstrap
├── SceneFlowManager
├── SaveGameManager
├── SettingsManager
├── NarrativeDirector
├── ObjectiveSystem
├── EventSequenceRunner
├── AudioDirector
├── LocalizationManager
└── AccessibilityManager
```

Каждый сервис имеет одну ответственность, typed API и отдельные tests.

### 4.1. GameBootstrap

Отвечает только за:

- определение build mode;
- загрузку settings;
- запуск core services;
- переход к initial scene;
- обработку fatal startup errors.

Bootstrap не содержит narrative logic.

### 4.2. SceneFlowManager

Управляет:

- main menu;
- gameplay scenes;
- loading transitions;
- pause/menu return;
- safe scene replacement;
- development/playtest/release flow.

### 4.3. NarrativeDirector

Хранит и управляет:

- текущим актом, chapter и beat;
- narrative flags;
- mandatory/optional actions;
- состояниями квартиры;
- ending conditions;
- checkpoint restore.

Объекты сообщают факты, а не переводят progression напрямую:

```text
note.read
terminal.opened
build.started
door.checked
speaker.answered
router.inspected
power.disabled
```

### 4.4. ObjectiveSystem

Objectives используют stable IDs и localization keys.

Система поддерживает:

- set/complete/restore;
- temporary reveal;
- fallback reminder;
- save/load;
- debug inspection.

Объектные скрипты не хранят финальный пользовательский текст objective.

### 4.5. EventSequenceRunner

Event sequence actions:

```text
wait
play_audio_cue
set_audio_snapshot
set_light_state
set_object_state
move_prop
show_objective
show_message
save_checkpoint
```

Runner поддерживает:

- последовательные и параллельные actions;
- ожидание реального завершения async action;
- отмену;
- одноразовость;
- восстановление после load;
- debug skip;
- concurrency guards;
- structured logging.

### 4.6. Data-driven definitions

```text
game/data/
├── episodes/
├── chapters/
├── objectives/
├── events/
├── interactions/
├── dialogue/
├── endings/
└── localization/
```

Основные Godot Resources:

- `EpisodeDefinition`;
- `ChapterDefinition`;
- `ObjectiveDefinition`;
- `EventSequenceDefinition`;
- `InteractionDefinition`;
- `DialogueLineDefinition`;
- `EndingDefinition`.

Тексты, conditions и next-object links не хранятся напрямую в `ComputerTerminal.gd`, `InteractableDoor.gd` и других reusable actors.

### 4.7. Component-based interactive actors

```text
InteractiveActor
├── InteractionComponent
├── VisualStateComponent
├── AudioEmitterComponent
├── HighlightComponent
├── SaveableComponent
└── AnimationPlayer
```

- `InteractionComponent` — Press, Hold, Toggle, Inspect, Focus, Choice.
- `VisualStateComponent` — normal, active, broken, corrupted.
- `AudioEmitterComponent` — semantic positional audio cues.
- `HighlightComponent` — subtle/readable/accessibility modes.
- `SaveableComponent` — stable object ID и state serialization.

### 4.8. Migration strategy

1. Добавить production core рядом со старыми managers.
2. Загружать prototype через legacy adapter.
3. Сохранить текущий regression route.
4. Перенести objectives/progression.
5. Перевести terminal, door и speaker по одному типу.
6. Перенести events в Resources.
7. Удалить legacy managers только после regression-equivalent прохождения.

`main` остаётся запускаемым после каждого PR.

## 5. Saves and settings

### 5.1. Save model

Ручное save menu не используется.

Поддерживаются:

- chapter checkpoints;
- autosave после крупных events;
- backup предыдущего autosave;
- отдельный settings file.

Save содержит:

- schema version;
- game version;
- checkpoint ID;
- act/chapter/beat;
- narrative flags;
- completed events;
- saveable object states;
- ending conditions;
- key device states.

### 5.2. Recovery

При повреждении save:

1. загрузить backup;
2. при неудаче восстановить минимальное состояние checkpoint;
3. показать понятное сообщение;
4. не перезаписывать повреждённый файл молча.

Поддерживаются migrations между минорными schema versions.

### 5.3. Settings

Обязательные настройки:

- mouse sensitivity;
- invert Y;
- key remapping;
- toggle/hold sprint и crouch;
- resolution/fullscreen;
- VSync/FPS limit;
- shadows/SSAO/glow/post-processing;
- brightness;
- film grain и chromatic aberration toggles;
- master/SFX/ambience/voice/UI volumes;
- dynamic range preset;
- accessibility options.

## 6. Apartment and spatial design

Целевая квартира: 38–45 м².

```text
прихожая
├── entrance door
├── smart lock
├── electrical panel
└── short corridor
основная комната
├── workstation
├── sleeping zone
└── window/balcony door
кухня
санузел
```

Функции зон:

- workstation — главный цифровой источник;
- entrance — потеря безопасности;
- kitchen — бытовая рутина и off-screen sounds;
- bathroom — reflections и distinct acoustics;
- sleeping zone — невозможность закончить день;
- window — изоляция от внешнего мира.

Игрок запоминает normal layout до spatial transformations.

## 7. Art direction

Целевой стиль:

```text
grounded stylized realism
```

- реалистичные размеры;
- low/mid-poly production models;
- PBR materials;
- 1K textures для большинства props;
- 2K для крупных surfaces и hero props;
- жилая слегка неопрятная квартира;
- generic unbranded technology;
- отсутствие release-facing `BoxMesh` placeholders.

PSX/VHS-эффекты появляются только в цифровых events.

### Palette

- холодный серо-бежевый;
- выцветшее тёмное дерево;
- чёрный металл и тёмный шпон;
- зелёно-голубой monitor glow;
- тёплый янтарный desk light;
- холодный синий и грязно-оранжевый exterior;
- красный только как late-game accent.

### Critical custom/controlled props

- workstation/monitor;
- smart lock;
- Smart Speaker;
- smartphone;
- router;
- electrical panel;
- desk lamp.

### Post-processing

Normal state:

- light film grain;
- restrained vignette;
- SSAO;
- limited glow;
- subtle grading.

Narrative events:

- short chromatic aberration;
- exposure pulses;
- temporary pixelation;
- motion trail;
- terminal instability.

Все motion/flash effects имеют accessibility controls.

## 8. Player experience

### 8.1. Movement

- smooth acceleration/deceleration;
- restrained camera inertia;
- configurable head bob;
- crouch ceiling check;
- slight camera lean;
- step-up;
- no jump;
- states: normal, inspect, terminal, phone, scripted lock.

### 8.2. Footsteps

Surfaces:

```text
laminate
tile_kitchen
tile_bathroom
carpet
hall_floor
```

Footsteps учитывают speed, crouch и surface. Delayed/duplicated footsteps запускаются только narrative events.

### 8.3. Flashlight

Числовой battery HUD удаляется.

```text
normal -> unstable -> emergency -> disabled
```

Фонарик имеет physical switch sound, sway, flicker и saveable state. Battery pickups не используются.

### 8.4. Interaction contract

Объект сообщает:

- availability;
- prompt localization key;
- action type;
- hold duration;
- blocked reason;
- priority;
- focus point.

Свободный physics grab не входит в 1.0.

## 9. Terminal, phone and UI

### 9.1. Terminal focus mode

- camera smoothly focuses screen;
- movement is disabled;
- terminal UI is separate from generic message panels;
- controlled typing timing;
- room events continue behind the player;
- commands: `RUN`, `RETRY`, `DISCONNECT`, `MERGE`, `REVERT`.

Игрок не вводит настоящий код.

### 9.2. Phone mode

Phone screens:

- work chat;
- personal messages;
- smart-home notifications;
- time/system state.

Message history может изменяться по narrative state. Phone также используется для in-world fallback hints.

### 9.3. HUD

Постоянно:

- small crosshair;
- contextual prompt.

Временно:

- objective reveal;
- subtitle;
- sound caption;
- hold progress.

Постоянные battery percentages, task list и debug state отсутствуют.

### 9.4. Menus

Main menu:

- Continue;
- New Game;
- Settings;
- Credits;
- Exit.

После прохождения:

- Chapter Select;
- Endings.

Pause menu:

- Continue;
- Settings;
- Last Checkpoint;
- Main Menu.

Хоррор-искажения не ломают реальные controls.

## 10. Accessibility and localization

Обязательные accessibility options:

- text size;
- stronger interaction highlights;
- prompt duration;
- reduced camera motion;
- head bob off;
- reduced flashes;
- subtitles;
- sound captions;
- hold alternatives;
- warnings for loud sounds/flashes.

First release locales:

- Russian;
- English.

Все пользовательские строки используют localization keys. Технические terminal lines могут оставаться англоязычными, если смысл понятен обеим локализациям.

## 11. Audio architecture

```text
Master
├── Music
├── Ambience
│   ├── Interior
│   └── Exterior
├── SFX
│   ├── Player
│   ├── Environment
│   └── Devices
├── Voice
├── UI
└── Horror
```

Audio snapshots:

```text
normal
uneasy
observed
corrupted
blackout
ending
```

Rules:

- важные sounds имеют physical source;
- music редко используется внутри квартиры;
- voice короткий и редкий;
- voice lines имеют subtitles;
- значимые sounds поддерживают captions;
- постоянный ambience не маскирует narrative cues.

## 12. Narrative safety

Каждый beat содержит:

- stable ID;
- chapter;
- prerequisites;
- mandatory actions;
- optional actions;
- event sequence;
- objective;
- fallback;
- checkpoint;
- next beat.

Mandatory beat имеет:

- recoverable objective;
- fallback trigger;
- safe load state;
- debug transition;
- structured start/finish log;
- incompatible sequence guards.

Early interaction показывает normal state и не ломает будущий beat.

Fallback order:

1. positional sound;
2. objective reminder;
3. subtle visual accent;
4. phone/terminal hint.

## 13. Testing and diagnostics

Quality gates:

1. static validation;
2. smoke test;
3. regression route;
4. exported build check.

```text
tests/
├── unit/
├── integration/
├── narrative/
└── smoke/
```

Автоматически проверяются:

- settings/save serialization;
- beat transitions и prerequisites;
- one-shot events;
- objective restore;
- localization keys;
- resource paths;
- definition validity;
- license manifest;
- ending conditions.

Narrative validator обнаруживает:

- missing next transition;
- unknown event ID;
- mandatory cycles;
- objective без fallback;
- unrecoverable checkpoint;
- unreachable ending;
- missing localization key;
- missing scene actor;
- incompatible concurrent sequences.

Development-only debug overlay:

- chapter/beat transition;
- event trigger;
- flag inspection;
- save/load checkpoint;
- lighting/audio snapshots;
- FPS/draw calls/memory;
- teleport points;
- ending conditions;
- recent event log.

Logging categories:

```text
GAME
NARRATIVE
SAVE
INTERACTION
AUDIO
UI
ASSET
PERFORMANCE
```

Release build сохраняет только ошибки, влияющие на startup, resources, saves и progression.

## 14. Performance

Target:

- 1080p/60 FPS на средней дискретной GPU;
- functional 30 FPS fallback на слабом оборудовании;
- no visible shader compilation stalls during events.

Rules:

- ограничить shadow-casting lights;
- reuse materials;
- minimize transparency;
- baked/mixed lighting where appropriate;
- controlled texture memory;
- occlusion culling и visibility ranges;
- heavy fullscreen effects активны только кратковременно.

## 15. CI and release channels

CI:

- headless Godot import;
- unit/integration tests;
- narrative validation;
- localization validation;
- asset/license manifest validation;
- Windows development build for release candidates.

Публичный release требует ручного подтверждения.

Build channels:

### Development

- debug overlay;
- detailed logs;
- beat skipping.

### Playtest

- release-like settings;
- diagnostic logs;
- chapter select;
- version watermark.

### Release

- no debug tools;
- final credits/licenses;
- verified saves;
- store-ready executable.

## 16. Production milestones

### P0 — Design Lock

- written spec;
- ADRs;
- roadmap/tasks/project state/handoff;
- final written review.

### P1 — Foundation Rebuild

- bootstrap;
- scene flow;
- logging;
- settings;
- saves/checkpoints;
- menu shell;
- tests/CI skeleton;
- legacy adapters.

### P2 — Apartment Vertical Slice

- production apartment blockout;
- component interactions;
- modern player feel;
- terminal focus mode;
- AudioDirector foundation;
- one data-driven route to checkpoint.

### P3 — Environment Production

- final architecture;
- material library;
- critical props;
- lighting;
- room tones;
- dressing;
- optimization.

### P4 — Prologue and Act I

- normal evening routine;
- terminal/lamp/lock/speaker escalation;
- phone foundation;
- menus/settings polish;
- RU/EN pipeline;
- accessibility foundation.

### P5 — Act II

- observation events;
- message history changes;
- subtle/confirmed spatial changes;
- secret ending conditions.

### P6 — Act III and Endings

- impossible spatial changes;
- final terminal sequence;
- four endings;
- final checkpoint.

### P7 — Content Complete

- no placeholders;
- voice/subtitles/captions;
- localization proofreading;
- credits/license manifest;
- accessibility pass;
- all chapters playable.

### P8 — Release Candidate

- export presets;
- compatibility testing;
- performance stabilization;
- final license audit;
- store metadata;
- release build.

## 17. Versioning

Existing prototype history occupies `0.1.0`–`0.3.6`.

Production line:

```text
0.4.x — P1 Foundation Rebuild
0.5.x — P2 Apartment Vertical Slice
0.6.x — P3 Environment + P4 Act I
0.7.x — P5 Act II
0.8.x — P6 Act III and content complete
0.9.x — release candidates
1.0.0 — public release
```

## 18. Definition of Done 1.0.0

- Все четыре endings доступны и проверены.
- Нет известных progression blockers.
- Checkpoints корректно восстанавливают state.
- RU/EN проверены.
- Все external assets имеют credits и license manifest.
- Settings сохраняются после restart.
- Keyboard/mouse controls полностью работают.
- Согласованные accessibility options реализованы.
- Windows build проверен вне Editor.
- Placeholder models/sounds/texts отсутствуют.
- Target performance достигнута.
- Release build не содержит debug tools.

## 19. Первый implementation PR

После финального подтверждения written spec создаётся подробный implementation plan.

Первый code PR — **P1.1 Bootstrap and Logging** — ограничивается:

- `GameBootstrap`;
- production main scene;
- typed logging service;
- development/release mode flags;
- legacy adapter, загружающим текущий playable slice;
- минимальным smoke check;
- документацией.

В первый code PR не входят:

- `SettingsManager`;
- save system;
- новая квартира;
- external assets;
- финалы;
- полная narrative migration;
- переписывание всех interactive objects;
- Steam SDK.