# ASSET_TRANSITION_PLAN.md

Дата обновления: 2026-07-12

## Назначение

Документ описывает переход от текущего `BoxMesh` greybox к release-quality окружению в стиле grounded stylized realism.

Полный production design:

```text
docs/superpowers/specs/2026-07-12-production-rebuild-design.md
```

## Текущее состояние

В prototype:

- квартира представляет собой прямоугольную комнату;
- архитектура, мебель и устройства собраны из Godot primitives;
- внешние models/textures отсутствуют;
- production material library отсутствует;
- `CREDITS.md` содержит только procedural placeholder audio.

Текущие примитивы являются blockout и не могут оставаться в release-facing контенте.

## Целевой стиль

```text
grounded stylized realism
```

Принципы:

- реалистичные размеры;
- low/mid-poly geometry;
- PBR materials;
- жилая слегка неопрятная квартира;
- техника без брендов;
- умеренная детализация;
- единая палитра и material response;
- цифровые PSX/VHS-искажения только во время events.

Не использовать постоянную pixelation или VHS-фильтр для маскировки слабых models/materials.

## Целевая планировка

Квартира 38–45 м²:

- прихожая;
- smart-lock entrance;
- электрощит;
- короткий коридор;
- основная комната;
- рабочее место;
- зона сна;
- кухня;
- санузел;
- окно или балконная дверь.

Production assets нельзя расставлять до утверждения масштаба и blockout route.

## Asset tiers

### Tier A — Architecture

- стены и проёмы;
- полы;
- потолки;
- дверные коробки;
- окна;
- кухонная и санитарная архитектура;
- плинтусы, наличники, розетки, выключатели.

### Tier B — Critical narrative props

Лучше собственные models или контролируемая единая серия:

- монитор и terminal workstation;
- keyboard/mouse;
- desk lamp;
- smartphone;
- Smart Speaker;
- router;
- smart lock;
- electrical panel;
- final network/power interaction objects.

### Tier C — Major furniture

- desk;
- chair;
- bed;
- wardrobe;
- shelf;
- kitchen cabinets;
- table/stools.

### Tier D — Dressing

- кружки;
- кабели;
- зарядки;
- упаковки;
- одежда;
- бумаги;
- лекарства;
- полотенца;
- посуда;
- обувь;
- бытовой мусор;
- книги без реальных обложек.

### Tier E — Exterior illusion

- city backdrop;
- emissive windows;
- simplified balcony/exterior geometry;
- distant traffic lights;
- non-interactive skyline.

## Texture and material budgets

- 1K — большинство props;
- 2K — крупные архитектурные surfaces и hero props;
- 512 px — небольшие repeated props;
- trim sheets и atlases предпочтительны для architecture/dressing;
- normal/roughness/metallic только там, где дают заметную ценность;
- emissive maps для экранов и индикаторов;
- material instances вместо множества уникальных materials.

4K textures не использовать без профилирования и отдельной причины.

## Material library

Минимальный набор:

- painted plaster;
- dirty painted wall;
- dark laminate;
- corridor floor covering;
- kitchen/bathroom tile;
- dark veneer;
- black coated metal;
- generic dark plastic;
- translucent glass;
- fabric;
- paper/cardboard;
- rubber/cable;
- screen glass/emissive display.

Материалы должны иметь controlled variation, а не случайный mix из разных packs.

## Palette

- стены — холодный серо-бежевый;
- пол — выцветшее тёмное дерево;
- мебель — чёрный металл и тёмный шпон;
- monitor glow — зелёно-голубой;
- desk lamp — тёплый янтарный;
- exterior — холодный синий и грязно-оранжевый;
- красный — редкий late-game accent.

## Sources

Приоритет:

1. собственные Blender models;
2. Poly Haven CC0;
3. ambientCG CC0;
4. Kenney CC0, если визуально подходит;
5. OpenGameArt CC0/CC BY после проверки;
6. коммерческие asset packs с понятными redistribution terms;
7. generated assets только при ясных commercial rights.

Каждый конкретный ресурс проверяется отдельно. Название платформы не гарантирует лицензию конкретного файла.

## Запрещено

- ripped assets;
- assets из чужих игр;
- CC BY-NC;
- CC BY-ND;
- unknown license;
- editorial-only;
- реальные логотипы и UI брендов;
- случайный mix photorealistic, cartoon и low-poly packs;
- model с готовой collision, которая мешает movement;
- использование render preview как game texture;
- распространение third-party source files, если license это запрещает.

## Import pipeline

Для каждого 3D asset:

1. зафиксировать source, author, license и дату;
2. сохранить source package отдельно, если license разрешает;
3. проверить scale и orientation;
4. удалить неиспользуемые materials/animations;
5. нормализовать naming;
6. экспортировать GLB/glTF;
7. настроить Godot import;
8. создать reusable scene prefab;
9. создать simplified collision;
10. назначить material instances;
11. проверить shadows, visibility ranges и light response;
12. обновить `docs/CREDITS.md` и license manifest;
13. проверить в exported build.

## Collision rules

- декоративные мелкие props не создают сложную physical collision;
- movement collision отделяется от interaction target;
- двери используют отдельный frame, leaf, handle и interaction shape;
- мебель получает simplified boxes/convex shapes;
- critical small object может иметь enlarged invisible interaction shape;
- collision не должна следовать каждому полигону модели;
- static clutter объединяется только после проверки interaction needs.

## Hero prop requirements

### Workstation

- правдоподобная высота;
- монитор смотрит в игровое пространство;
- screen surface отделена от body;
- есть camera focus point;
- есть audio emitter positions;
- terminal UI не baked в texture;
- cables имеют логичную трассировку.

### Entrance door

- frame и leaf разделены;
- корректный pivot;
- handle/lock читаются;
- smart-lock indicator имеет visual states;
- collision не блокирует проём после открытия;
- есть sound points и saveable state.

### Smart Speaker

- normal/active/corrupted visual states;
- indicator readable without brand logo;
- отдельный audio emitter;
- interaction shape не зависит от точной геометрии.

### Router

- generic design;
- readable LEDs;
- cable/network clue states;
- inspect focus mode;
- secret ending state.

### Electrical panel

- normal and opened states;
- hold interaction;
- breaker animation;
- power sequence hooks;
- safe collision and camera focus.

## Lighting compatibility

Assets проверяются минимум в состояниях:

- normal night;
- desk lamp only;
- kitchen light;
- emergency/blackout;
- monitor glow;
- corrupted exposure.

Материал, который выглядит хорошо только в preview HDRI, не считается готовым.

## Optimization budgets

- ограничить количество unique materials;
- использовать static shadows только там, где нужно;
- мелкие props группировать по room section;
- применять visibility ranges;
- не использовать прозрачность для непрозрачных материалов;
- city backdrop делать simplified;
- учитывать texture memory;
- измерять draw calls после каждого environment pass.

## Replacement order

### P2 — Vertical Slice

1. production blockout architecture;
2. entrance door;
3. workstation;
4. desk lamp;
5. one room material set;
6. critical interaction shapes.

### P3 — Environment Production

1. full architecture;
2. kitchen and bathroom modules;
3. major furniture;
4. router, phone, speaker, electrical panel;
5. dressing;
6. exterior illusion;
7. optimization.

## Definition of Done для asset

- source и license записаны;
- scale проверен относительно игрока;
- pivot и orientation корректны;
- prefab имеет понятную структуру;
- collision не мешает navigation;
- materials соответствуют art direction;
- interaction point читается;
- asset проверен в нескольких lighting states;
- отсутствуют реальные logos;
- asset не вызывает заметного performance regression;
- `docs/CREDITS.md` обновлён.

## Definition of Done для environment production

- release route не показывает `BoxMesh` placeholders;
- квартира узнаваема и бытово правдоподобна;
- normal layout запоминается до transformations;
- critical props имеют visual/audio/save states;
- все third-party assets имеют provenance;
- performance соответствует roadmap quality gate.