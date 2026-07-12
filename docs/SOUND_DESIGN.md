# SOUND_DESIGN.md

Дата обновления: 2026-07-12

## Назначение

Звук — главный инструмент напряжения в `AI Routine: Last Commit`.

Production audio должен создавать страх через:

- тишину;
- позиционный бытовой звук;
- неправильный источник;
- задержку;
- изменение знакомого room tone;
- редкий синтетический голос;
- обрыв ожидаемого звукового слоя.

Полный production design:

```text
docs/superpowers/specs/2026-07-12-production-rebuild-design.md
```

## Главная формула

```text
нормальная акустика
→ маленький знакомый звук
→ неправильный timing или source
→ короткая пауза
→ физическая реакция квартиры
```

## Audio buses

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

Каждая шина должна поддерживать пользовательскую громкость. `Master`, `Ambience`, `SFX`, `Voice`, `UI` обязательны в settings 1.0.

## Audio snapshots

`AudioDirector` управляет состояниями:

```text
normal
uneasy
observed
corrupted
blackout
ending
```

Snapshot может менять:

- bus volumes;
- low-pass/high-pass;
- room tone layers;
- exterior presence;
- reverb send;
- stereo width;
- device hum;
- dynamic range.

Переходы должны быть плавными, кроме осознанных событий `silence_cut` и `power_drop`.

## Звуковая идентичность зон

### Рабочее место

- PC fans;
- keyboard;
- mouse clicks;
- monitor electric hum;
- coil-like high-frequency detail;
- notification sounds.

### Прихожая

- сухой smart-lock relay;
- distant building ambience;
- elevator or stairwell noise;
- короткие отражения звука.

### Коридор

- directionality важнее громкости;
- шаги и щелчки должны помогать ориентироваться;
- late-game reflections могут становиться неправильными.

### Кухня

- refrigerator;
- pipes;
- kettle;
- water;
- dishes;
- соседские бытовые шумы.

### Санузел

- ventilation;
- drops;
- tile reflections;
- water and pipe resonance;
- short reverb distinct from the room.

### Зона сна

- приглушённый exterior city tone;
- fabric movement;
- distant phone vibration;
- quieter PC presence.

## Production sound categories

### Ambience

- `amb_room_main_night`;
- `amb_kitchen_refrigerator`;
- `amb_bathroom_vent`;
- `amb_hall_building`;
- `amb_city_window`;
- `amb_blackout_silence`.

### Player

- footsteps per surface;
- crouch movement;
- cloth movement;
- flashlight switch;
- focus enter/exit;
- interaction hold progress.

### Devices

- monitor hum;
- PC fans;
- keyboard single/burst;
- smart-lock relay/error;
- speaker wake;
- router ticks;
- phone vibration;
- electrical panel;
- breaker switch;
- power drop.

### UI

- menu navigation;
- confirm/cancel;
- objective reveal;
- terminal command;
- phone notification.

UI sounds должны отличаться от diegetic device sounds. Сюжет может намеренно перепутать их только в конкретном event.

### Voice

- normal personal messages;
- neutral smart-speaker TTS;
- corrupted speaker variant.

Голос используется редко. Все voice lines имеют subtitles.

### Horror

- low-frequency event accents;
- wrong notification;
- spatial duplication;
- reversed or delayed household sound;
- silence cut;
- corrupted terminal pulse.

`Horror` bus не должен использоваться как постоянная громкая музыка.

## Footstep system

Поверхности:

```text
laminate
tile_kitchen
tile_bathroom
carpet
hall_floor
```

Система учитывает:

- speed;
- crouch;
- stride timing;
- start/stop;
- surface;
- optional narrative modifier.

В normal state шаги всегда физически достоверны. Нарушенные delayed/duplicated footsteps запускаются только через narrative event, а не случайно.

## Diegetic source rule

Каждый важный звук должен иметь объяснимый source node:

- дверь;
- колонка;
- телефон;
- keyboard;
- monitor;
- router;
- electrical panel;
- вентиляция.

Fullscreen/non-positional sound допускается для:

- menu UI;
- objective UI;
- controlled final accent;
- accessibility captions.

Нельзя запускать door/speaker/keyboard sound из HUD.

## Music

Постоянный soundtrack во время исследования не используется.

Музыка допустима:

- main menu;
- opening title;
- act transition;
- ending;
- credits.

В квартире музыкальный ритм создают бытовые layers: fans, hum, keyboard, relay, refrigerator и pipes.

## Voice and TTS

Типы:

1. короткие normal voice messages;
2. neutral synthetic smart-speaker voice;
3. corrupted variant в поздней игре.

Примеры допустимой длины:

```text
Команда не распознана.
Команда уже выполнена.
Пользователь подтверждён.
```

Не использовать длинные монологи, объясняющие природу угрозы.

## Subtitles and sound captions

Обязательные настройки:

- subtitles on/off;
- text size;
- speaker label;
- sound captions on/off;
- caption background opacity.

Примеры captions:

```text
[щелчок замка у входной двери]
[клавиатура печатает за спиной]
[гул холодильника обрывается]
```

Caption должен описывать сюжетно значимый звук, но не раскрывать невидимый источник раньше игрока без необходимости.

## Dynamic range

Presets:

- Full;
- Night;
- Reduced.

`Night` уменьшает пики и сохраняет читаемость тихих событий. `Reduced` предназначен для небольших speakers и accessibility.

Нельзя делать progression зависимым от ультратихого звука без visual/fallback alternative.

## Prototype sounds

Текущий `ApartmentEventController.gd` генерирует:

- `ui_notification_soft`;
- `desk_lamp_click`.

Это procedural placeholders для regression route. Они должны быть удалены из production content после подключения AudioDirector и финальных assets.

До удаления требуется сохранить эквивалентный event timing.

## Required production sound list

### P1/P2 foundation

- menu confirm/cancel;
- interaction press/hold;
- one laminate footstep set;
- flashlight switch;
- terminal focus enter/exit;
- monitor hum;
- one room tone;
- smart-lock click/error.

### P3 environment

- room tones всех зон;
- exterior city;
- refrigerator;
- ventilation;
- pipes;
- doors and handles;
- light switches;
- PC fans;
- chair movement;
- prop interactions.

### P4–P6 narrative

- normal/wrong notifications;
- keyboard single/burst;
- phone vibration;
- speaker wake;
- TTS lines;
- router ticks;
- delayed footsteps;
- spatial duplicates;
- electrical panel;
- breaker;
- power drop;
- ending-specific layers.

## File formats

- short one-shots: WAV или OGG;
- loops: OGG с проверенным loop point;
- 3D point sources: mono;
- ambience beds: stereo при необходимости;
- source masters могут храниться вне game import folder, если license позволяет.

Naming:

```text
sfx_<object>_<action>_<variant>.ogg
amb_<zone>_<state>_<variant>.ogg
vo_<speaker>_<line_id>_<locale>.ogg
ui_<context>_<action>.ogg
```

## Asset sources

Приоритет:

1. собственная запись;
2. собственная обработка;
3. CC0 libraries;
4. CC BY с корректной attribution;
5. generated audio при ясных commercial rights;
6. коммерческие libraries с разрешением использования в игре.

Не использовать:

- звуки из игр, фильмов и роликов;
- YouTube/TikTok extraction;
- unknown license;
- CC BY-NC;
- assets с Content ID risk без проверки;
- голос реального человека без согласия.

Каждый external sound записывается в `docs/CREDITS.md` и license manifest.

## Processing rules

Разрешено:

- trim;
- normalize;
- fades;
- pitch shift;
- EQ;
- low/high-pass;
- light compression;
- layering;
- mono conversion;
- noise cleanup.

Не злоупотреблять длинной cinematic reverb. Маленькая квартира должна звучать близко и сухо.

## Event integration

Narrative event не хранит raw audio path в object script. Он вызывает semantic action или AudioDirector cue.

Пример:

```text
play_audio_cue("device.smart_lock.error")
set_audio_snapshot("uneasy")
```

Audio cue определяет:

- stream variations;
- bus;
- spatial mode;
- volume range;
- pitch range;
- concurrency;
- captions;
- cooldown.

## Concurrency rules

- не проигрывать несколько одинаковых device clicks одновременно;
- room tone имеет один owner на zone;
- voice не перекрывается без отдельной постановочной причины;
- notification variants имеют cooldown;
- ending snapshot может duck ambience, но не subtitles/UI feedback.

## Testing

Каждый sound PR проверяет:

- source position;
- perceived loudness;
- loop seams;
- duplicate prevention;
- captions;
- settings bus;
- snapshot transition;
- exported build import;
- license record.

Manual test выполняется минимум в headphones и ordinary speakers.

## Definition of Done для audio cue

- semantic ID определён;
- asset provenance записан;
- stream import корректен;
- bus назначен;
- 2D/3D mode обоснован;
- volume/pitch variation настроены;
- concurrency определена;
- caption добавлен, если звук сюжетно значим;
- cue проверен в нужном narrative event;
- release build не использует procedural placeholder вместо финального cue.