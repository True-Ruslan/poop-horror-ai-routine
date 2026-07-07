# AGENT_HANDOFF.md

## Назначение

Этот документ нужен для нового пустого чата с ChatGPT или другим код-агентом.

Если агент ничего не знает о проекте, начинать нужно отсюда. Документ кратко объясняет:

- что мы разрабатываем;
- какой сейчас статус;
- какие документы читать дальше;
- что уже сделано;
- какие правила нельзя нарушать;
- какой следующий шаг.

## Проект

```text
AI Routine: Last Commit
```

Короткий first-person psychological horror на Godot 4.7+.

Игрок — уставший разработчик, который поздно вечером пытается закрыть рабочую задачу. В квартире начинают странно реагировать монитор, лампа, дверь, умная колонка, HUD и другие бытовые объекты.

Главный вайб:

```text
я просто хотел закрыть задачу, но теперь боюсь нажимать Enter
```

## Репозиторий

```text
True-Ruslan/poop-horror-ai-routine
```

Базовая ветка:

```text
main
```

Проект основан на upstream-шаблоне:

```text
True-Ruslan/godot-simple-tamplate
```

Сверка с шаблоном описана в `docs/UPSTREAM_TEMPLATE_SYNC.md`.

## Что читать в новом чате

Минимальный порядок:

1. `docs/AGENT_HANDOFF.md`.
2. `docs/PROJECT_STATE.md`.
3. `docs/TASKS.md`.
4. `docs/SCENE_BEATS.md`.
5. `docs/INTERACTION_MECHANICS.md`.
6. `docs/SOUND_DESIGN.md`.
7. `docs/ASSET_TRANSITION_PLAN.md`.
8. `docs/DOCUMENTATION_RULES.md`.
9. `README.md`.

Если задача про ассеты, обязательно читать:

- `docs/ASSET_SOURCES.md`;
- `docs/ASSET_TRANSITION_PLAN.md`;
- `docs/CREDITS.md`.

Если задача про сюжет, обязательно читать:

- `docs/SCENARIO.md`;
- `docs/NARRATIVE_DESIGN.md`;
- `docs/SCENE_BEATS.md`.

## Текущий playable slice

Основная сцена:

```text
game/scenes/Main.tscn
```

Она загружает:

```text
game/scenes/levels/DeveloperApartment.tscn
game/scenes/ui/HUD.tscn
```

Текущая локация — квартира разработчика.

В ней есть:

- рабочий стол;
- монитор / терминал;
- клавиатура;
- стикер с задачами;
- лампа;
- входная дверь;
- кровать;
- полка;
- Smart Speaker;
- HUD с текущей задачей.

## Уже реализовано

### Foundation

- Godot-проект.
- First-person player controller.
- Mouse look.
- Movement / sprint / crouch.
- Flashlight.
- Interaction raycast.
- HUD.
- GameState.
- ObjectiveManager.
- HorrorEventManager.

### Scenario objects

- `InteractableNote`.
- `InteractableDoor`.
- `LightSwitch`.
- `ComputerTerminal`.
- `SmartSpeaker`.

### Implemented beats

#### Beat 1 — Task sticker

Игрок читает стикер на рабочем столе.

Стикер ведёт к терминалу.

#### Beat 2 — First terminal reply

Игрок открывает терминал.

Терминал показывает странный текст от код-агента и запускает event:

```text
terminal_first_ai_reply
```

#### Beat 3 — Lamp answers terminal

`ApartmentEventController` слушает `terminal_first_ai_reply`.

После короткой задержки:

- играет procedural terminal notification;
- играет procedural lamp click;
- `DeskLamp` мигает;
- цель обновляется.

#### Beat 5 — Smart Speaker wakes up

`SmartSpeaker` становится интерактивным объектом.

До `terminal_first_ai_reply` он отвечает обычной фразой.

После `terminal_first_ai_reply` он показывает странный текст:

```text
Распознана команда: продолжать.
Режим сна отклонён.
```

И запускает event:

```text
speaker_wrong_name
```

## Текущая архитектура events

`HorrorEventManager` хранит одноразовые события.

Пример:

```gdscript
HorrorEventManager.play_once("terminal_first_ai_reply", callback)
```

Если event уже был сыгран, повтор не запускается.

`ApartmentEventController` — контроллер событий текущей квартиры. Он сейчас отвечает за:

- procedural notification sound;
- procedural lamp click;
- мигание лампы;
- runtime-подключение `SmartSpeaker.gd` к объекту SmartSpeaker в сцене.

## Текущие event IDs

```text
task_sticker_read
terminal_first_ai_reply
speaker_wrong_name
```

Планируемые:

```text
smart_lock_denied
keyboard_without_hands
hud_objective_corrupt
final_power_drop
```

## Стиль разработки

Игра развивается маленькими PR.

Каждый PR должен:

- делать небольшой законченный шаг;
- не ломать playable slice;
- обновлять документацию;
- содержать manual check;
- не добавлять внешние ассеты без лицензии;
- не подключать реальные AI API в MVP.

## Документация обязательна

Если меняется код, сцена, сценарий, механика, ассет или архитектура, обновлять минимум:

- `docs/TASKS.md`;
- `docs/PROJECT_STATE.md`;
- `docs/CHANGELOG.md`.

Дополнительно:

- сюжетный beat → `docs/SCENE_BEATS.md`;
- механика → `docs/INTERACTION_MECHANICS.md`;
- звук → `docs/SOUND_DESIGN.md`;
- ассеты → `docs/ASSET_TRANSITION_PLAN.md`, `docs/ASSET_SOURCES.md`, `docs/CREDITS.md`;
- новый процесс → `docs/DOCUMENTATION_RULES.md`.

## Asset rules

Текущий проект пока в greybox.

Переход к нормальным ассетам описан в:

```text
docs/ASSET_TRANSITION_PLAN.md
```

Целевой стиль:

- lo-fi;
- PSX-inspired;
- бытовой хоррор;
- простые силуэты;
- тёмные материалы;
- грязноватая квартира;
- без фотореалистичного микса;
- без реальных брендов.

Нельзя добавлять:

- ассеты без лицензии;
- CC BY-NC;
- CC BY-ND;
- модели из чужих игр;
- реальные логотипы;
- UI реальных сервисов.

## Sound rules

Первые звуки процедурные и генерируются кодом.

Файл:

```text
game/scripts/core/ApartmentEventController.gd
```

Текущие sounds:

```text
ui_notification_soft
desk_lamp_click
```

Внешние звуки можно добавлять только после проверки лицензии и записи в `docs/CREDITS.md`.

## Что не делать

- Не добавлять реальные AI API в MVP.
- Не делать сложный programming simulator.
- Не добавлять monster/combat без отдельного решения.
- Не расширять локацию, пока текущая квартира не стала читаемой.
- Не добавлять случайные ассеты из разных visual styles.
- Не использовать реальные бренды и логотипы.
- Не пропускать обновление документации.

## Ближайшие задачи

Текущий следующий шаг после Smart Speaker:

```text
Beat 4 / Door refuses или Audio Expansion для Smart Speaker.
```

Приоритеты:

1. Проверить Smart Speaker в Godot.
2. Добавить door refusal phases и event `smart_lock_denied`.
3. Добавить звук `speaker_wake` или `door_lock_error`.
4. Начать замену первого greybox prop: стул или стол/монитор.

## Manual check после текущей итерации

1. Запустить `game/scenes/Main.tscn`.
2. Прочитать стикер.
3. Открыть терминал.
4. Убедиться, что лампа мигает.
5. Подойти к Smart Speaker на полке.
6. Нажать `E`.
7. Проверить, что после терминального event колонка выдаёт странный текст.
8. Повторно нажать `E` и проверить repeat-текст.
9. Проверить, что objective ведёт обратно к терминалу.
