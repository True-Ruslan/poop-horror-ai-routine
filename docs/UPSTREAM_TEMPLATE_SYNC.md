# UPSTREAM_TEMPLATE_SYNC.md

## Назначение

Проект основан на upstream-шаблоне:

```text
True-Ruslan/godot-simple-tamplate
```

Шаблон развивается отдельно, поэтому этот проект нужно периодически сверять с ним.

## Когда проверять шаблон

Проверять upstream стоит:

- перед крупной новой итерацией;
- перед изменением архитектуры;
- перед изменением документации;
- перед подготовкой релиза;
- если человек просит проверить актуальность шаблона.

## Что проверять

Минимальный список:

- последние merge-коммиты;
- новые PR;
- изменения в `AGENTS.md`;
- изменения в `README.md`;
- новые файлы в `docs/`;
- новые prompt/checklist-документы;
- новые scene/script-паттерны;
- новые правила по ассетам и лицензиям.

## Что не переносить автоматически

Не переносить без отдельного решения:

- изменения, которые ломают текущую игру;
- generic-сцены вместо `DeveloperApartment.tscn`;
- generic-сценарий вместо `docs/SCENARIO.md`;
- новые зависимости;
- ассеты без проверки лицензии.

## Как фиксировать проверку

После сверки обновлять блок:

```md
## Last upstream check

Дата: YYYY-MM-DD
Repo: True-Ruslan/godot-simple-tamplate
Checked commit: commit_sha
Вывод: кратко.
```

## Last upstream check

Дата: 2026-07-07
Repo: `True-Ruslan/godot-simple-tamplate`
Checked commit: `9cf6dbdd674048fdbacaefcde1808f6d58362c7e`

Найдено:

- свежий merge PR #8: `pr-checklists`;
- свежий merge PR #7: `pr-project-conversion-prompts`;
- свежий merge PR #6: `pr-starter-game-example`;
- свежий merge PR #5: `pr-template-usage-release`.

Вывод:

- код автоматически не переносить;
- позже отдельно проверить checklist/prompt-документы;
- правило сверки добавить в работу агента.
