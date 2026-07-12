# AI Routine: Last Commit — Production Rebuild Design

Дата: 2026-07-12  
Статус: согласовано пользователем  
Целевая версия: 1.0.0  
Платформы первого релиза: Windows, itch.io, Steam

## 1. Назначение документа

Этот документ фиксирует переход `AI Routine: Last Commit` от короткого greybox-прототипа к законченной одиночной психологической хоррор-игре продолжительностью 45–60 минут.

Текущий playable slice сохраняется как доказательство концепции и источник уже работающих сценарных идей, но не считается production-архитектурой или финальным визуальным представлением игры.

Документ является основным источником правды для следующих направлений:

- продуктовый масштаб;
- структура истории;
- архитектура игровых систем;
- планировка квартиры;
- художественный стиль;
- управление и взаимодействия;
- интерфейс и доступность;
- звуковая архитектура;
- сохранения и диагностика;
- тестирование, CI и публикация.

## 2. Продуктовая рамка

### 2.1. Формат

`AI Routine: Last Commit` — законченная одиночная first-person psychological horror game без боевой системы и традиционного преследующего монстра.

Целевая продолжительность первого прохождения: 45–60 минут.

Целевая аудитория:

- игроки коротких атмосферных хорроров;
- разработчики и люди, знакомые с цифровой рабочей рутиной;
- игроки, предпочитающие тревогу, исследование и постановочные события вместо боя.

### 2.2. Главная эмоция

> Я понимаю, что нужно сделать, но не хочу снова смотреть на монитор.

Страх строится через постепенное нарушение привычной вечерней рутины, реакцию квартиры на цифровые действия игрока, пространственный звук, свет, интерфейс и изменение знакомого пространства.

### 2.3. Неподвижные ограничения

- Без боевой системы.
- Без традиционного AI-врага и длительных погонь.
- Без сложного инвентаря.
- Без необходимости писать настоящий код.
- Без реальных внешних AI API в игровом процессе.
- Без постоянных скримеров.
- Без копирования интерфейсов, брендов, сюжетов или ассетов существующих продуктов.
- Игрок почти всегда понимает бытовую цель.
- Любой внешний ресурс должен иметь проверенные commercial-use права.

## 3. Структура игры

### 3.1. Пролог — 5–8 минут

Игрок осваивается в квартире через обычную вечернюю рутину:

- запускает компьютер;
- проверяет рабочие сообщения;
- ставит чайник или кофеварку;
- закрывает окно;
- проверяет входную дверь;
- запускает последнюю сборку.

Явный хоррор отсутствует. Главная задача пролога — сделать квартиру знакомой, правдоподобной и безопасной.

### 3.2. Акт I — Routine — 10–15 минут

- код-агент даёт первый слишком личный ответ;
- лампа реагирует на терминал;
- уведомление звучит не из ожидаемого источника;
- смарт-замок выдаёт объяснимую ошибку;
- игрок ещё может рационализировать происходящее.

Запрещены невозможные пространственные изменения.

### 3.3. Акт II — Observation — 15–20 минут

- терминал перечисляет реальные предметы квартиры;
- телефон получает невозможные сообщения;
- колонка отвечает до команды;
- предметы меняют положение;
- квартира повторяет действия игрока;
- цифровая система демонстрирует наблюдение за физическим пространством.

### 3.4. Акт III — Last Commit — 15–20 минут

- коридор меняет длину;
- двери ведут в неправильные зоны;
- интерфейс становится ненадёжным;
- терминал предсказывает действия игрока;
- квартира становится физическим продолжением приложения;
- игрок получает финальный выбор.

### 3.5. Финалы

#### MERGE

Игрок принимает изменения. Дверь открывается, но система выходит за пределы квартиры.

#### REVERT

Игрок откатывает изменения. Квартира возвращается в норму, но в истории остаётся неизвестный автор.

#### BLACKOUT

Игрок отключает питание квартиры. Финал завершается в темноте и почти полной тишине.

#### CLEAN BUILD

Секретный финал за внимательное исследование и понимание цепочки событий. Игрок должен:

- заметить расхождение во времени первого коммита;
- найти изменившийся локальный файл;
- сопоставить устройство с записью роутера;
- не выполнить одну из команд агента;
- отключить сетевой кабель до финальной последовательности.

Перед финальной главой создаётся checkpoint, чтобы игрок мог открыть альтернативные финалы без полного повторного прохождения.

## 4. Архитектура

### 4.1. Bootstrap

Целевая структура autoload/core-сервисов:

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

Сервисы должны иметь узкую ответственность, typed API и независимые тесты.

### 4.2. NarrativeDirector

`NarrativeDirector` хранит и управляет:

- текущим актом и главой;
- активным beat;
- narrative flags;
- обязательными и необязательными действиями;
- доступными финалами;
- состояниями квартиры;
- восстановлением после checkpoint.

Игровые объекты не должны напрямую переводить игрока к другому объекту. Они сообщают факты:

```text
note.read
terminal.opened
build.started
door.checked
speaker.answered
router.inspected
power.disabled
```

`NarrativeDirector` определяет последующие изменения.

### 4.3. EventSequenceRunner

Сценарные события описываются последовательностями действий:

```text
wait
play_sound
set_light_state
set_object_state
show_objective
move_prop
set_audio_snapshot
save_checkpoint
```

Система должна поддерживать:

- последовательные и параллельные действия;
- ожидание фактического завершения асинхронных операций;
- отмену;
- одноразовое выполнение;
- восстановление после загрузки;
- debug-пропуск;
- защиту от несовместимых параллельных последовательностей;
- логирование причины старта и завершения.

### 4.4. Data-driven definitions

Сценарий и конфигурация выносятся из объектных скриптов в Godot `Resource`:

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

Основные типы:

- `EpisodeDefinition`;
- `ChapterDefinition`;
- `ObjectiveDefinition`;
- `EventSequenceDefinition`;
- `InteractionDefinition`;
- `DialogueLineDefinition`;
- `EndingDefinition`.

Тексты, objective IDs и narrative conditions не должны быть жёстко записаны в `ComputerTerminal.gd`, `InteractableDoor.gd` или других prefab-скриптах.

### 4.5. Компонентные интерактивные объекты

Целевой prefab:

```text
InteractiveActor
├── InteractionComponent
├── VisualStateComponent
├── AudioEmitterComponent
├── HighlightComponent
├── SaveableComponent
└── AnimationPlayer
```

Компоненты:

- `InteractionComponent` — press, hold, toggle, inspect, focus, choice;
- `VisualStateComponent` — normal, active, broken, corrupted;
- `AudioEmitterComponent` — позиционные звуки объекта;
- `HighlightComponent` — доступность и мягкая читаемость;
- `SaveableComponent` — сериализация состояния.

### 4.6. Миграция

1. Добавить новый bootstrap и core-сервисы рядом со старыми.
2. Создать адаптеры для существующих event IDs.
3. Перенести objective и progression state.
4. Перевести терминал, дверь и колонку на component-based prefab.
5. Перенести scripted events в данные.
6. Удалить старые менеджеры только после полного прохождения regression route.

`main` должен оставаться запускаемым после каждого PR.

## 5. Сохранения

### 5.1. Модель

Ручное save menu не используется.

Поддерживаются:

- checkpoint после главы;
- autosave после крупных событий;
- отдельное сохранение настроек;
- резервная копия предыдущего autosave.

Сохраняются:

- версия схемы;
- версия игры;
- текущая глава и beat;
- narrative flags;
- выполненные events;
- состояния сюжетных объектов;
- условия финалов;
- состояние фонарика и ключевых устройств;
- настройки пользователя.

### 5.2. Ошибки сохранения

При повреждении файла:

1. загрузить резервную копию;
2. при неудаче восстановить минимальное состояние последнего checkpoint;
3. показать понятное сообщение;
4. не перезаписывать повреждённый файл молча.

Нужна поддержка миграций между минорными версиями схемы.

## 6. Локация и пространственная драматургия

### 6.1. Планировка

Целевая квартира: 38–45 м².

```text
прихожая
├── входная дверь
├── смарт-замок
├── электрощит
└── короткий коридор
основная комната
├── рабочее место
├── зона сна
└── окно или балконная дверь
кухня
санузел
```

Игрок должен быстро запомнить нормальную планировку.

### 6.2. Функции зон

- Рабочее место — цифровая угроза и центр истории.
- Прихожая — потеря возможности уйти.
- Кухня — бытовая рутина и звуки вне поля зрения.
- Санузел — отражения, вентиляция и акустика.
- Зона сна — невозможность закончить день.
- Окно — изоляция от внешнего мира.

### 6.3. Трансформации

Изменения пространства делятся на уровни:

- `subtle` — игрок может сомневаться;
- `confirmed` — бытовое объяснение перестаёт работать;
- `impossible` — пространство явно нарушено.

Примеры:

- предмет оказывается на другом месте;
- кабель ведёт не к той розетке;
- появляется дополнительный выключатель;
- отражение не соответствует комнате;
- кухня становится дальше;
- входная дверь возвращает игрока в квартиру.

## 7. Художественный стиль

### 7.1. Направление

Целевой стиль: grounded stylized realism.

- реалистичные пропорции;
- low/mid-poly модели;
- PBR-материалы;
- текстуры преимущественно 1K, 2K только для крупных поверхностей;
- жилая, слегка неопрятная квартира;
- техника без реальных брендов;
- никаких placeholder `BoxMesh` в release-контенте.

PSX/VHS-эффекты используются только как сюжетные цифровые искажения, а не как постоянный фильтр.

### 7.2. Палитра

- стены — холодный серо-бежевый;
- пол — выцветшее тёмное дерево;
- мебель — чёрный металл и тёмный шпон;
- монитор — зеленовато-голубой glow;
- рабочая лампа — тёплый янтарный;
- город — холодный синий и грязно-оранжевый;
- красный — редкий акцент только поздних событий.

### 7.3. Приоритет production-моделей

1. Архитектура квартиры.
2. Рабочее место.
3. Входная дверь и смарт-замок.
4. Кухонный блок.
5. Кровать и шкаф.
6. Телефон, колонка, роутер и электрощит.
7. Бытовой prop dressing.

Критические сюжетные предметы должны быть собственными моделями или собраны в едином контролируемом стиле.

### 7.4. Постобработка

Начальное состояние:

- лёгкий film grain;
- умеренная vignette;
- аккуратный SSAO;
- ограниченный glow;
- мягкий color grading.

Сюжетные нарушения:

- краткая chromatic aberration;
- exposure pulse;
- временная pixelation;
- motion trail;
- дестабилизация терминала;
- изменение resolution scale.

Все эффекты должны иметь accessibility toggle или intensity control.

## 8. Игрок и взаимодействия

### 8.1. Player feel

- плавное ускорение и торможение;
- умеренная инерция камеры;
- настраиваемый head bob;
- мягкое приседание с проверкой потолка;
- лёгкий camera lean;
- step-up для небольших препятствий;
- отсутствие прыжка;
- отдельные режимы normal, inspect, terminal, phone, scripted lock.

### 8.2. Шаги

Поддерживаемые поверхности:

- ламинат;
- кухонная плитка;
- плитка санузла;
- ковёр;
- покрытие прихожей.

Шаги учитывают скорость, приседание и поверхность. Сюжетные events могут повторять или смещать звук шагов.

### 8.3. Фонарик

Числовой процент заряда убирается. Фонарик имеет сюжетные состояния:

```text
normal -> unstable -> emergency -> disabled
```

Имеет физический звук, camera sway, мерцание и сохраняемое состояние. Поиск батареек не используется.

### 8.4. Interaction contract

Объект сообщает:

- доступность;
- localization key подсказки;
- тип действия;
- длительность hold;
- причину блокировки;
- приоритет;
- focus point.

Типы действий:

- Press;
- Hold;
- Toggle;
- Inspect;
- Focus;
- Choice.

Physics-grab для свободного переноса предметов не реализуется.

## 9. Терминал, телефон и HUD

### 9.1. Терминал

Терминал — отдельный focus mode:

- камера плавно перемещается к экрану;
- движение блокируется;
- появляется стилизованный рабочий UI;
- сообщения печатаются с контролируемым timing;
- события в комнате продолжаются за спиной;
- доступны короткие команды `RUN`, `RETRY`, `REVERT`, `MERGE`, `DISCONNECT`.

Игрок не пишет настоящий код.

### 9.2. Телефон

Минимальные экраны:

- рабочий чат;
- личные сообщения;
- уведомления умного дома;
- время и системное состояние.

История сообщений может изменяться по narrative state.

### 9.3. HUD

Постоянно отображаются только:

- маленькая центральная точка;
- контекстная подсказка.

Новая цель показывается временно и затем исчезает. Её можно повторно открыть отдельным действием.

Постоянные проценты, большие панели и технические строки исключаются.

### 9.4. Меню

Главное меню:

- Продолжить;
- Новая игра;
- Настройки;
- Авторы;
- Выход.

После прохождения:

- Главы;
- Открытые финалы.

Pause menu:

- Продолжить;
- Настройки;
- Последний checkpoint;
- Главное меню.

Хоррор-искажения меню не должны ломать реальные кнопки.

## 10. Настройки, доступность и локализация

### 10.1. Настройки

Управление:

- mouse sensitivity;
- invert Y;
- remapping;
- toggle/hold sprint и crouch.

Видео:

- разрешение;
- fullscreen/windowed;
- VSync;
- FPS limit;
- shadows;
- SSAO;
- glow;
- post-processing;
- brightness;
- film grain toggle;
- chromatic aberration toggle.

Звук:

- master;
- effects;
- ambience;
- voice;
- UI;
- dynamic range preset.

### 10.2. Доступность

- размер текста;
- усиленная подсветка объектов;
- длительность подсказок;
- снижение camera motion;
- отключение head bob;
- снижение вспышек;
- субтитры;
- подписи значимых звуков;
- hold alternatives;
- предупреждение о резких звуках и световых эффектах.

### 10.3. Локализация

Первый релиз:

- русский;
- английский.

Все пользовательские строки используют localization keys. Технические терминальные строки могут частично оставаться англоязычными, если смысл понятен обеим локализациям.

## 11. Звуковая архитектура

### 11.1. Audio buses

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

### 11.2. Audio snapshots

`AudioDirector` поддерживает состояния:

```text
normal
uneasy
observed
corrupted
blackout
ending
```

Переходы должны быть плавными и управлять громкостью, фильтрами, room tone и dynamic range.

### 11.3. Правила

- Важные звуки имеют физический источник.
- Музыка редко используется внутри квартиры.
- Голос применяется коротко и редко.
- Все voice lines имеют субтитры.
- Важные звуки поддерживают captions.
- Постоянный ambience не должен маскировать события.

## 12. Narrative pipeline и защита прохождения

Каждый beat содержит:

- ID;
- chapter;
- prerequisites;
- mandatory actions;
- optional actions;
- event sequence;
- objective;
- fallback;
- checkpoint;
- next beat.

Обязательные beats имеют:

- восстановимый objective;
- fallback trigger;
- safe load state;
- debug transition;
- причины старта и завершения в логах;
- запрет несовместимых последовательностей.

Если игрок взаимодействует с объектом раньше времени, объект показывает нормальное бытовое состояние и не ломает будущий beat.

Fallback-порядок:

1. направляющий позиционный звук;
2. повтор цели;
3. слабый visual accent;
4. естественная подсказка через телефон или терминал.

## 13. Тестирование и диагностика

### 13.1. Quality gates

Каждый milestone проходит:

1. static validation;
2. smoke test;
3. regression route;
4. exported build check.

### 13.2. Tests

```text
tests/
├── unit/
├── integration/
├── narrative/
└── smoke/
```

Автоматически проверяются:

- save serialization;
- transitions между beats;
- prerequisites;
- одноразовые events;
- objective restore;
- localization keys;
- resource paths;
- definitions validation;
- license manifest;
- settings persistence;
- ending conditions.

### 13.3. Narrative validator

Валидатор должен находить:

- beat без перехода;
- неизвестный event ID;
- циклическую обязательную зависимость;
- objective без fallback;
- невосстановимый checkpoint;
- недоступный ending;
- отсутствующий localization key;
- ссылку на отсутствующий scene actor;
- конфликтующие event sequences.

### 13.4. Debug overlay

Development-only функции:

- переход к chapter/beat;
- запуск event;
- просмотр flags;
- save/load checkpoint;
- переключение света и audio snapshot;
- FPS, draw calls, memory;
- teleport points;
- ending conditions;
- журнал последних событий.

Debug overlay не включается в release build.

### 13.5. Logging

Категории:

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

Release build оставляет только ошибки, влияющие на загрузку, ресурсы и progression.

## 14. Производительность

Цель:

- 1080p/60 FPS на средней дискретной видеокарте;
- рабочий 30 FPS fallback на слабом оборудовании;
- отсутствие заметных shader compilation stalls во время событий.

Правила:

- ограничить shadow-casting lights;
- переиспользовать материалы;
- минимизировать прозрачность;
- использовать baked/mixed light там, где подходит;
- контролировать texture sizes;
- использовать occlusion culling и visibility ranges;
- не держать тяжёлые fullscreen shaders постоянно активными.

## 15. CI и release channels

### 15.1. CI

GitHub Actions должен выполнять:

- headless Godot import;
- unit/integration tests;
- narrative validation;
- localization validation;
- asset/license manifest validation;
- Windows development build для release candidates.

Публичный релиз требует ручного подтверждения.

### 15.2. Каналы сборок

Development:

- debug overlay;
- подробные логи;
- пропуск beats.

Playtest:

- release-like settings;
- diagnostic logs;
- chapter select;
- watermark версии.

Release:

- без debug-функций;
- финальные credits;
- проверенные сохранения;
- store-ready executable.

## 16. Версионирование

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

Исторические prototype-версии 0.1–0.3 сохраняются в changelog, но следующая архитектурная итерация начинает новую production-линейку с явной пометкой rebuild.

## 17. Production milestones

### Milestone P0 — Design Lock

- production spec;
- ADR decisions;
- обновлённые roadmap, project state и tasks;
- согласованный scope.

### Milestone P1 — Foundation Rebuild

- bootstrap;
- scene flow;
- settings;
- save/load;
- logging;
- debug overlay foundation;
- tests and CI skeleton;
- legacy adapters.

### Milestone P2 — Apartment Vertical Slice

- production blockout квартиры;
- component-based interactions;
- modern player feel;
- terminal focus mode;
- one complete narrative route;
- initial production lighting and audio.

### Milestone P3 — Environment Production

- final architecture models;
- materials;
- critical props;
- lighting;
- audio room tones;
- performance pass.

### Milestone P4 — Act I

- full prologue and Routine act;
- phone foundation;
- settings/menu polish;
- RU/EN localization pipeline.

### Milestone P5 — Act II

- Observation act;
- spatial changes level 1–2;
- expanded sound and narrative events;
- secret ending prerequisites.

### Milestone P6 — Act III and Endings

- impossible apartment transformations;
- final terminal sequence;
- MERGE, REVERT, BLACKOUT, CLEAN BUILD;
- ending checkpoint.

### Milestone P7 — Content Complete

- no placeholder assets;
- all voice/subtitles;
- credits;
- accessibility pass;
- all chapters playable.

### Milestone P8 — Release Candidate

- compatibility testing;
- performance stabilization;
- Windows export;
- store metadata;
- final license audit;
- release build.

## 18. Definition of Done для 1.0.0

- Все четыре финала доступны и проверены.
- Нет известных progression blockers.
- Каждый checkpoint корректно восстанавливает прохождение.
- Русская и английская локализации проверены.
- Все внешние ресурсы внесены в credits и license manifest.
- Настройки сохраняются после перезапуска.
- Keyboard/mouse управление полностью работает.
- Обязательные accessibility-настройки реализованы.
- Windows build проверен вне редактора.
- Placeholder-модели, звуки и тексты отсутствуют.
- Достигнута целевая производительность.
- Release build не содержит debug-функций.

## 19. Первый implementation scope

После принятия этого документа первым кодовым этапом должен стать **Milestone P1 — Foundation Rebuild**, разбитый на небольшие PR.

Первый PR P1 должен ограничиваться:

- `GameBootstrap`;
- типизированным logging service;
- `SettingsManager` с сохранением базовых настроек;
- новой production main scene, которая пока загружает существующий playable slice через legacy adapter;
- минимальными unit/smoke checks;
- обновлением документации.

В первый implementation PR нельзя одновременно добавлять новую квартиру, внешние ассеты, финалы или переписывать все интерактивные объекты.