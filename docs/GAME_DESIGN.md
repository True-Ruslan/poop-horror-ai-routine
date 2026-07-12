# GAME_DESIGN.md

Дата обновления: 2026-07-12

## Цель игры

`AI Routine: Last Commit` — законченный first-person psychological horror продолжительностью 45–60 минут про разработчика, который постепенно теряет контроль над код-агентом, устройствами умного дома и самой квартирой.

Полный production design:

```text
docs/superpowers/specs/2026-07-12-production-rebuild-design.md
```

## Главная эмоция

```text
Я понимаю, что нужно сделать, но не хочу снова смотреть на монитор.
```

## Product pillars

### 1. Бытовая достоверность

Квартира сначала ощущается жилой и безопасной. Игрок знакомится с устройствами через нормальные вечерние задачи до их хоррор-использования.

### 2. Понятная цель, страшное выполнение

Игрок не должен теряться. Напряжение возникает из-за нежелания идти к знакомому объекту, а не из-за отсутствия направления.

### 3. Маленькое нарушение раньше большого

Каждый event начинается с небольшого несоответствия и только затем разрушает рациональное объяснение.

### 4. Звук важнее скримера

Позиционный звук, тишина, неправильный источник и задержка важнее громкого музыкального удара.

### 5. Квартира — главный антагонист

Традиционный монстр отсутствует. Угроза проявляется через свет, устройства, отражения, двери, сообщения и изменение расстояний.

### 6. Цифровое становится физическим

Каждый акт усиливает связь между терминалом и квартирой:

```text
рабочий текст → реакция устройства → наблюдение пространства → изменение пространства
```

### 7. Деталь важнее масштаба

Одна правдоподобная квартира с высокой плотностью деталей предпочтительнее нескольких пустых локаций.

## Игровая структура

- Пролог — Normal State.
- Акт I — Routine.
- Акт II — Observation.
- Акт III — Last Commit.
- Финалы — `MERGE`, `REVERT`, `BLACKOUT`, `CLEAN BUILD`.

См. `docs/SCENARIO.md`.

## Core loop

```text
получить бытовую задачу
→ взаимодействовать с предметом
→ увидеть системный ответ
→ услышать или заметить реакцию квартиры
→ проверить знакомую зону
→ получить новый narrative state
```

## Player verbs

Обязательные:

- ходить;
- осматриваться;
- приседать;
- взаимодействовать;
- удерживать действие;
- осматривать предмет;
- входить в terminal focus mode;
- использовать телефон;
- управлять светом и устройствами;
- делать narrative choice.

Не добавлять без отдельного ADR:

- jump;
- combat;
- свободный physics grab;
- сложный inventory;
- crafting;
- stealth AI;
- open-world navigation.

## Player feel

- мягкое ускорение и торможение;
- умеренная camera inertia;
- настраиваемый head bob;
- crouch с проверкой свободного пространства;
- step-up;
- physical flashlight sway;
- режимы normal, inspect, terminal, phone и scripted lock.

Комфорт важнее агрессивной симуляции камеры.

## Interaction design

Типы:

- Press;
- Hold;
- Toggle;
- Inspect;
- Focus;
- Choice.

Интерактивный объект обязан сообщать:

- доступность;
- localization key подсказки;
- тип взаимодействия;
- duration;
- block reason;
- priority;
- focus point.

В новых системах нельзя использовать проверку `has_method("interact")` как основной production contract.

## HUD

Постоянно:

- crosshair;
- contextual prompt.

Временно:

- новый objective;
- subtitle;
- sound caption;
- interaction progress.

Не показывать постоянно:

- проценты батареи;
- большой список задач;
- debug state;
- технические панели.

## Terminal design

Терминал — отдельный mode, а не message popup.

Команды:

```text
RUN
RETRY
DISCONNECT
MERGE
REVERT
```

Игрок не вводит настоящий код. Важны timing, самопечатающиеся строки и физические события в комнате за спиной.

## Phone design

Телефон содержит:

- рабочий чат;
- личные сообщения;
- smart-home notifications;
- системное время;
- изменяющуюся историю сообщений.

Телефон также является естественным fallback channel.

## Flashlight design

Батарейки не являются collectible resource.

Состояния:

```text
normal → unstable → emergency → disabled
```

Состояние меняется narrative events и сохраняется.

## Horror escalation

### Act I

Только объяснимые нарушения.

### Act II

Наблюдение и подтверждённые несоответствия.

### Act III

Невозможные spatial contradictions.

Нельзя показывать impossible geometry в начале, иначе исчезнет ценность знакомой планировки.

## Scare rules

- не более двух явных скримеров;
- одинаковый scare не повторяется;
- большинство событий не требуют смотреть строго в одну точку;
- важное последствие остаётся достаточно долго;
- после сильного события есть пауза;
- громкость не заменяет постановку;
- horror effect не должен ломать реальное управление или меню.

## Difficulty and guidance

Классических уровней сложности не требуется.

Guidance escalation:

1. positional sound;
2. objective reminder;
3. subtle visual accent;
4. in-world phone/terminal hint.

Accessibility settings могут усиливать prompts и highlights без изменения narrative conditions.

## Replay value

- checkpoint перед финальным выбором;
- chapter select после прохождения;
- endings gallery/status;
- optional clues;
- secret `CLEAN BUILD` route.

Полное повторное прохождение не требуется для выбора обычных альтернативных финалов.

## Production quality bar

Release content обязан иметь:

- production model или осознанный stylized asset;
- корректный scale;
- collision и interaction shape;
- material provenance;
- audio state;
- saveable state, если объект сюжетный;
- localization keys;
- manual test route;
- отсутствие placeholder text.

## Non-goals 1.0

- multiplayer;
- Steam Workshop;
- Steam SDK gameplay features;
- procedural level generation;
- real AI integration;
- voiced protagonist with long dialogues;
- combat;
- enemy AI;
- multiple large locations;
- mobile/console release.

## Sources of truth

- `docs/superpowers/specs/2026-07-12-production-rebuild-design.md` — полный production design;
- `docs/SCENARIO.md` — история и акты;
- `docs/NARRATIVE_DESIGN.md` — тон и формула хоррора;
- `docs/INTERACTION_MECHANICS.md` — mechanics details;
- `docs/SOUND_DESIGN.md` — audio rules;
- `docs/ROADMAP.md` — milestones;
- `docs/TASKS.md` — executable backlog.