# Godot Atmospheric Horror Template

Шаблон короткой атмосферной хоррор-игры на **Godot 4.7+**.

Цель репозитория — дать понятный стартовый скелет для игр в духе коротких психологических хорроров: walking simulator, VHS/PSX-атмосфера, простые интерактивные объекты, записки, двери, фонарик, задачи и scripted horror events.

Шаблон рассчитан на два сценария работы:

1. **Самостоятельная разработка** — человек открывает проект в Godot, запускает демо-сцену и постепенно заменяет шаблонные элементы своими.
2. **Разработка с ИИ-агентом** — Codex/Cursor/другой агент читает `AGENTS.md`, `docs/CONTEXT.md`, `docs/TASKS.md` и выполняет задачи строго итерационно.

## Что уже есть

- Минимальный Godot-проект.
- Игрок от первого лица.
- Камера и mouse look.
- Ходьба, бег, приседание.
- Фонарик с зарядом.
- Interaction raycast.
- Интерактивные двери.
- Интерактивные записки.
- Интерактивный выключатель света.
- Objective system.
- Horror event manager.
- HUD с подсказками, задачами и сообщениями.
- Демо-комната, которую можно сразу запустить.
- Документация для человека и ИИ-агента.
- Шаблоны сценария, задач, changelog, credits и архитектурных решений.

## Быстрый старт

1. Установи Godot 4.7 или новее.
2. Склонируй репозиторий:

```bash
git clone https://github.com/your-name/godot-atmospheric-horror-template.git
cd godot-atmospheric-horror-template
```

3. Открой папку проекта в Godot.
4. Запусти сцену:

```text
game/scenes/Main.tscn
```

5. Проверь управление:

| Действие | Клавиша |
|---|---|
| Движение | WASD |
| Бег | Shift |
| Присесть | Ctrl |
| Взаимодействие | E |
| Фонарик | F |
| Выйти/освободить мышь | Esc |

## Структура проекта

```text
.
├── AGENTS.md
├── README.md
├── LICENSE
├── project.godot
├── game
│   ├── scenes
│   │   ├── Main.tscn
│   │   ├── levels
│   │   │   └── TemplateLevel.tscn
│   │   ├── objects
│   │   │   ├── InteractableDoor.tscn
│   │   │   ├── InteractableNote.tscn
│   │   │   └── LightSwitch.tscn
│   │   ├── player
│   │   │   └── Player.tscn
│   │   └── ui
│   │       └── HUD.tscn
│   └── scripts
│       ├── core
│       ├── interaction
│       ├── objects
│       ├── player
│       └── ui
└── docs
    ├── CONTEXT.md
    ├── TASKS.md
    ├── SCENARIO_TEMPLATE.md
    ├── DECISIONS.md
    ├── CHANGELOG.md
    ├── CREDITS.md
    ├── LICENSE_CHECKLIST.md
    ├── DESIGN_GUIDE.md
    ├── EXPORT_GUIDE.md
    └── prompts
```

## Как использовать как GitHub Template

1. Создай новый репозиторий на GitHub.
2. Загрузи этот проект.
3. В настройках репозитория включи:

```text
Settings → General → Template repository
```

4. Теперь другие пользователи смогут нажать **Use this template** и создать свою игру на основе шаблона.

## Как работать с ИИ-агентом

Перед первой задачей дай агенту прочитать:

```text
AGENTS.md
docs/CONTEXT.md
docs/TASKS.md
docs/DECISIONS.md
```

После этого используй промпты из:

```text
docs/prompts/
```

Главное правило: **агент не должен генерировать всю игру целиком**. Каждая итерация должна оставлять проект запускаемым.

## Рекомендуемый путь разработки

1. Запустить базовый шаблон.
2. Переименовать проект под свою игру.
3. Заполнить `docs/SCENARIO.md` на основе `docs/SCENARIO_TEMPLATE.md`.
4. Описать первую локацию.
5. Добавить одну комнату.
6. Добавить одну задачу.
7. Добавить один интерактивный предмет.
8. Добавить один scripted horror event.
9. Только потом расширять локацию, сюжет и визуальные эффекты.

## Лицензия

Код шаблона распространяется под MIT License. Перед добавлением сторонних ассетов, шаблонов, шейдеров или звуков обязательно фиксируй источник и лицензию в `docs/CREDITS.md`.
