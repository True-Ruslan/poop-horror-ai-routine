# PROJECT_STATE.md

Дата обновления: 2026-07-07

## Текущий статус

Проект находится на стадии первого playable slice по сценарию.

Это ранний playable slice:

- есть Godot-проект;
- есть игрок от первого лица;
- есть первая квартира разработчика;
- есть базовые интерактивные объекты;
- есть сценарий и план развития;
- есть первый реальный scripted event со светом;
- есть первые procedural sounds для терминала и лампы;
- рабочая зона перенесена от двери в отдельный угол комнаты;
- есть интерактивный Smart Speaker;
- есть handoff-документ для нового чата/агента;
- есть план перехода от greybox к lo-fi / PSX ассетам;
- нет полноценного финала.

## Рабочее название

```text
AI Routine: Last Commit
```

## Главная идея

Короткий хоррор про разработчика, который пытается закрыть вечернюю задачу. Рабочий стол, монитор, стикер, лампа, дверь и умная колонка постепенно становятся источниками тревоги.

## Текущая основная сцена

```text
game/scenes/Main.tscn
```

Она загружает:

```text
game/scenes/levels/DeveloperApartment.tscn
game/scenes/ui/HUD.tscn
```

## Что уже реализовано

### Системы

- Игрок от первого лица.
- Движение, бег, приседание.
- Фонарик.
- Interaction raycast.
- HUD.
- ObjectiveManager.
- HorrorEventManager.
- GameState.
- ApartmentEventController.
- Runtime procedural SFX внутри `ApartmentEventController`.
- Runtime-подключение `SmartSpeaker.gd` к объекту `SmartSpeaker` в сцене.

### Объекты

- `InteractableDoor`.
- `InteractableNote`.
- `LightSwitch`.
- `ComputerTerminal`.
- `SmartSpeaker`.

### Локации

- `TemplateLevel.tscn` — старый шаблонный уровень.
- `DeveloperApartment.tscn` — первая основная локация игры.

### Сценарные events

- `task_sticker_read` — чтение стикера.
- `terminal_first_ai_reply` — первый странный ответ терминала.
- `terminal_first_ai_reply` запускает procedural notification sound и мигание `DeskLamp` через `ApartmentEventController`.
- Перед миганием лампы проигрывается procedural `desk_lamp_click`.
- `speaker_wrong_name` — Smart Speaker странно отвечает после первого терминального event.

### Layout

- Рабочий стол перенесён к правой стене, а не к входной двери.
- Монитор развёрнут внутрь комнаты.
- Стул опущен на пол.
- Лампа, клавиатура и стикер находятся в рабочей зоне.
- Smart Speaker вынесен на полку в другой части комнаты.

### Handoff-документация

Для нового пустого чата или код-агента создан документ:

```text
docs/AGENT_HANDOFF.md
```

С него можно начать работу, чтобы понять проект, статус, ближайшие задачи и правила документации.

## Что ещё не реализовано

- Локальная проверка новой планировки в Godot.
- Локальная проверка громкости procedural sounds в Godot.
- Локальная проверка Smart Speaker в Godot.
- Фазовые сообщения входной двери.
- Нормальные внешние/собственные lo-fi ассеты вместо greybox-примитивов.
- Главное меню.
- Финальный выбор эпизода.
- Export preset для Windows.

## Ближайшая задача

Следующий PR:

```text
Добавить Door Refusal: фазовые сообщения двери и event smart_lock_denied.
```

Минимальные файлы для следующей задачи:

- `docs/AGENT_HANDOFF.md`;
- `docs/SCENE_BEATS.md`;
- `docs/INTERACTION_MECHANICS.md`;
- `game/scripts/objects/InteractableDoor.gd`;
- `game/scenes/levels/DeveloperApartment.tscn`;
- `docs/TASKS.md`;
- `docs/CHANGELOG.md`;
- `docs/PROJECT_STATE.md`.

## Asset transition

План перехода к нормальным ассетам описан в:

```text
docs/ASSET_TRANSITION_PLAN.md
```

Первый приоритет:

1. Стул.
2. Стол + монитор.
3. Дверь со smart-lock индикатором.
4. Кабели, кружка, роутер и мелкие бытовые props.

## Риски

- Текущие сцены нужно проверить в Godot локально.
- Procedural sounds могут потребовать настройки громкости.
- Smart Speaker подключается к существующему node через `ApartmentEventController`, это нужно проверить в Godot.
- Внешние ассеты пока не добавлялись.
- Новые asset packs нельзя добавлять без проверки лицензии и записи в `docs/CREDITS.md`.
- Документация не должна расходиться с фактической реализацией.
