# CONTEXT.md

## Назначение проекта

Этот репозиторий теперь развивается как конкретная короткая хоррор-игра на Godot 4.7+:

```text
AI Routine: Last Commit
```

Исходный шаблон остаётся внутри проекта как база: first-person player, фонарик, interaction raycast, двери, записки, выключатель света, HUD, ObjectiveManager и HorrorEventManager.

## Жанровая цель

Короткий first-person psychological horror про разработчика, вечернюю рабочую рутину, монитор, странные сообщения и квартиру, которая постепенно становится тревожной.

Ключевой тон:

- бытовой хоррор;
- тревожное ожидание;
- редкая сухая ирония;
- scripted events вместо сложного AI-врага;
- маленький playable slice вместо большой незавершённой игры.

## Главный принцип

Игрок должен почти всегда понимать бытовую цель:

```text
прочитать стикер → открыть монитор → проверить лампу → проверить дверь → вернуться к рабочему месту
```

Но атмосфера должна создавать ощущение, что простая задача закончится не так, как ожидается.

## Текущая основная сцена

```text
game/scenes/Main.tscn
```

Загружает:

```text
game/scenes/levels/DeveloperApartment.tscn
game/scenes/ui/HUD.tscn
```

## Текущая игровая локация

```text
game/scenes/levels/DeveloperApartment.tscn
```

В сцене есть:

- закрытая квартира;
- игрок;
- рабочий стол;
- монитор/терминал;
- стикер с задачами;
- выключатель света;
- закрытая входная дверь;
- кровать, полка, стул, колонка как окружение.

## Текущие системы

### PlayerController

Файл:

```text
game/scripts/player/PlayerController.gd
```

Отвечает за:

- ходьбу;
- бег;
- приседание;
- mouse look;
- гравитацию;
- движение от первого лица.

### FlashlightController

Файл:

```text
game/scripts/player/FlashlightController.gd
```

Отвечает за:

- включение/выключение фонарика;
- заряд батареи;
- разряд при использовании;
- сигнал в HUD.

### InteractionRaycast

Файл:

```text
game/scripts/interaction/InteractionRaycast.gd
```

Отвечает за:

- определение объекта перед игроком;
- вывод подсказки;
- вызов `interact()` у объекта.

Интерактивный объект должен иметь методы:

```gdscript
func get_interaction_text() -> String:
    return "E — взаимодействовать"

func interact(actor: Node = null) -> void:
    pass
```

### ObjectiveManager

Файл:

```text
game/scripts/core/ObjectiveManager.gd
```

Отвечает за текущую задачу игрока.

### HorrorEventManager

Файл:

```text
game/scripts/core/HorrorEventManager.gd
```

Отвечает за scripted horror events, которые должны срабатывать один раз.

Пример:

```gdscript
HorrorEventManager.play_once("first_event", Callable(self, "_play_event"))
```

### GameState

Файл:

```text
game/scripts/core/GameState.gd
```

Глобальные сигналы и состояние:

- подсказки взаимодействия;
- сообщения/записки;
- батарея фонарика;
- пауза;
- input map.

### ComputerTerminal

Файлы:

```text
game/scenes/objects/ComputerTerminal.tscn
game/scripts/objects/ComputerTerminal.gd
```

Отвечает за:

- интерактивный монитор;
- показ текстового сообщения;
- смену задачи после первого использования;
- запуск первого scripted event через `HorrorEventManager`.

## Правила развития проекта

1. Сначала делаем playable slice, потом расширяем.
2. Новая механика добавляется через минимальный тестовый пример.
3. Любой интерактивный объект должен быть самодостаточной сценой в `game/scenes/objects/`.
4. Любой scripted event должен иметь уникальный `event_id`.
5. Нельзя добавлять внешние ассеты без записи в `docs/CREDITS.md`.
6. Нельзя добавлять внешние зависимости без записи в `docs/DECISIONS.md`.
7. Нельзя менять жанр без отдельного решения.
8. Не подключать реальные внешние сервисы в MVP.

## Документы проекта

- `docs/SCENARIO.md` — сценарий игры.
- `docs/GAME_DESIGN.md` — дизайн-правила.
- `docs/ASSET_SOURCES.md` — источники ассетов и лицензии.
- `docs/TASKS.md` — план итераций.
- `docs/DECISIONS.md` — журнал решений.
