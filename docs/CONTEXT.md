# CONTEXT.md

## Назначение проекта

Этот репозиторий — шаблон короткой атмосферной хоррор-игры на Godot 4.7+.

Шаблон должен быть понятен человеку и ИИ-агенту. Он не является готовой игрой, но содержит минимальный playable example и структуру, которую можно расширять.

## Жанровая цель

Шаблон подходит для игр в духе:

- короткий first-person psychological horror;
- VHS/PSX/retro horror;
- walking simulator;
- liminal horror;
- бытовой хоррор с тревожной атмосферой;
- scripted events вместо сложного AI-врага.

## Главный принцип

Игрок должен почти всегда понимать бытовую цель:

```text
найти записку → открыть дверь → включить свет → проверить кабинет → выйти
```

Но атмосфера должна создавать ощущение, что простая задача закончится не так, как ожидается.

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
HorrorEventManager.play_once("first_note_read", Callable(self, "_play_event"))
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

## Текущая демо-сцена

```text
game/scenes/Main.tscn
```

Загружает:

```text
game/scenes/levels/TemplateLevel.tscn
game/scenes/ui/HUD.tscn
```

В демо есть:

- закрытая комната;
- игрок;
- фонарик;
- дверь;
- записка;
- выключатель;
- учебная цель.

## Правила развития проекта

1. Сначала делаем playable slice, потом расширяем.
2. Новая механика добавляется через минимальный тестовый пример.
3. Любой интерактивный объект должен быть самодостаточной сценой в `game/scenes/objects/`.
4. Любой scripted event должен иметь уникальный `event_id`.
5. Нельзя добавлять внешние ассеты без записи в `docs/CREDITS.md`.
6. Нельзя добавлять внешние зависимости без записи в `docs/DECISIONS.md`.
7. Нельзя менять жанр шаблона без отдельного решения.

## Опциональные интеграции

Шаблон специально не содержит сторонних зависимостей. Их можно подключить позже:

- COGITO — как источник идей для interaction/immersive sim систем.
- GodotRetro — для VHS/CRT/PSX эффектов.
- Maaack Game Template — для расширенного меню и настроек.
- Horror FPS Template — как reference для locked doors, inventory, camcorder.

Перед переносом кода или ассетов обязательно проверить лицензию.
