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
- нет полноценного звука и финала.

## Рабочее название

```text
AI Routine: Last Commit
```

## Главная идея

Короткий хоррор про разработчика, который пытается закрыть вечернюю задачу. Рабочий стол, монитор, стикер, лампа и дверь постепенно становятся источниками тревоги.

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

### Объекты

- `InteractableDoor`.
- `InteractableNote`.
- `LightSwitch`.
- `ComputerTerminal`.

### Локации

- `TemplateLevel.tscn` — старый шаблонный уровень.
- `DeveloperApartment.tscn` — первая основная локация игры.

### Сценарные events

- `task_sticker_read` — чтение стикера.
- `terminal_first_ai_reply` — первый странный ответ терминала.
- `terminal_first_ai_reply` теперь запускает мигание `DeskLamp` через `ApartmentEventController`.

## Что ещё не реализовано

- Звуковые эффекты для терминала и лампы.
- Интерактивная колонка или телефон.
- Главное меню.
- Финальный выбор эпизода.
- Export preset для Windows.
- Локальная проверка проекта в Godot после текущего PR.

## Ближайшая задача

Следующий PR:

```text
Добавить first sound pass: уведомление терминала и щелчок лампы.
```

Минимальные файлы для следующей задачи:

- `docs/SOUND_DESIGN.md`;
- `docs/CREDITS.md`;
- `game/scripts/objects/ComputerTerminal.gd`;
- `game/scripts/core/ApartmentEventController.gd`;
- `game/scenes/levels/DeveloperApartment.tscn`;
- `docs/TASKS.md`;
- `docs/CHANGELOG.md`;
- `docs/PROJECT_STATE.md`.

## Риски

- Текущие сцены нужно проверить в Godot локально.
- Внешние ассеты пока не добавлялись.
- Звуки пока не добавлялись.
- Документация не должна расходиться с фактической реализацией.
