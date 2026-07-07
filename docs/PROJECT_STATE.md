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
- нет полноценного финала.

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
- Runtime procedural SFX внутри `ApartmentEventController`.

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
- `terminal_first_ai_reply` запускает procedural notification sound и мигание `DeskLamp` через `ApartmentEventController`.
- Перед миганием лампы проигрывается procedural `desk_lamp_click`.

## Что ещё не реализовано

- Локальная проверка громкости procedural sounds в Godot.
- Интерактивная колонка или телефон.
- Главное меню.
- Финальный выбор эпизода.
- Export preset для Windows.
- Локальная проверка проекта в Godot после текущего PR.

## Ближайшая задача

Следующий PR:

```text
Добавить Smart Speaker или Phone как второй бытовой объект.
```

Минимальные файлы для следующей задачи:

- `docs/SCENE_BEATS.md`;
- `docs/INTERACTION_MECHANICS.md`;
- `game/scenes/objects/`;
- `game/scripts/objects/`;
- `game/scenes/levels/DeveloperApartment.tscn`;
- `docs/TASKS.md`;
- `docs/CHANGELOG.md`;
- `docs/PROJECT_STATE.md`.

## Риски

- Текущие сцены нужно проверить в Godot локально.
- Procedural sounds могут потребовать настройки громкости.
- Внешние ассеты пока не добавлялись.
- Документация не должна расходиться с фактической реализацией.
