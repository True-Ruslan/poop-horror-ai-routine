extends StaticBody3D

@export var interaction_text: String = "E — открыть терминал"
@export var interaction_text_after_speaker: String = "E — проверить список устройств"
@export var terminal_title: String = "Терминал"
@export_multiline var terminal_body: String = "Сборка завершилась с ошибкой."
@export var objective_after_first_use: String = "Проверить квартиру."
@export var horror_event_id_after_first_use: String = "terminal_first_use"
@export var device_list_required_event_id: String = "speaker_wrong_name"
@export var horror_event_id_after_device_list: String = "terminal_device_list"
@export var objective_after_device_list: String = "Отключить рабочий компьютер."
@export_multiline var device_list_body: String = "Detected devices:\n\n- desk_lamp: unstable\n- smart_lock: waiting\n- speaker: listening\n\nLast command source: local apartment network\nManual override: unavailable\n\nКурсор ждёт, будто список должен быть длиннее."
@export_multiline var device_list_repeat_body: String = "Detected devices:\n\n- desk_lamp: unstable\n- smart_lock: waiting\n- speaker: listening\n\nManual override: unavailable"

var was_used: bool = false
var was_device_list_shown: bool = false

func get_interaction_text() -> String:
    if _should_show_device_list():
        return interaction_text_after_speaker
    return interaction_text

func interact(_actor: Node = null) -> void:
    if _should_show_device_list():
        _show_device_list()
        return

    GameState.show_message(terminal_title, terminal_body)

    if not was_used:
        was_used = true
        if objective_after_first_use.strip_edges() != "":
            ObjectiveManager.complete_current_objective(objective_after_first_use)
        if horror_event_id_after_first_use.strip_edges() != "":
            HorrorEventManager.play_once(horror_event_id_after_first_use, _play_terminal_horror_event)

func _should_show_device_list() -> bool:
    return device_list_required_event_id.strip_edges() != "" and HorrorEventManager.has_played(device_list_required_event_id)

func _show_device_list() -> void:
    GameState.show_message(terminal_title, device_list_repeat_body if was_device_list_shown else device_list_body)

    if not was_device_list_shown:
        was_device_list_shown = true
        if objective_after_device_list.strip_edges() != "":
            ObjectiveManager.complete_current_objective(objective_after_device_list)
        if horror_event_id_after_device_list.strip_edges() != "":
            HorrorEventManager.play_once(horror_event_id_after_device_list, _play_device_list_horror_event)

func _play_terminal_horror_event() -> void:
    print("Horror event triggered: ", horror_event_id_after_first_use)

func _play_device_list_horror_event() -> void:
    print("Horror event triggered: ", horror_event_id_after_device_list)
