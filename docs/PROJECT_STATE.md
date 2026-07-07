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
- есть план перехода от greybox к lo-fi / PSX ассетам;
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

### Layout

- Рабочий стол перенесён к правой стене, а не к входной двери.
- Монитор развёрнут внутрь комнаты.
- Стул опущен на пол.
- Лампа, клавиатура и стикер находятся в рабочей зоне.
- Smart Speaker вынесен на полку в другой части комнаты.

## Что ещё не реализовано

- Локальная проверка новой планировки в Godot.
- Локальная проверка громкости procedural sounds в Godot.
- Интерактивная колонка или телефон.
- Нормальные внешние/собственные lo-fi ассеты вместо greybox-примитивов.
- Главное меню.
- Финальный выбор эпизода.
- Export preset для Windows.

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
- Внешние ассеты пока не добавлялись.
- Новые asset packs нельзя добавлять без проверки лицензии и записи в `docs/CREDITS.md`.
- Документация не должна расходиться с фактической реализацией.
