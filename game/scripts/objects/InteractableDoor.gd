extends StaticBody3D

@export var open_text: String = "E — открыть дверь"
@export var close_text: String = "E — закрыть дверь"
@export var locked_check_text: String = "E — проверить дверь"
@export var locked_repeat_check_text: String = "E — снова проверить замок"
@export var locked_title: String = "Входная дверь"
@export_multiline var locked_text: String = "Смарт-замок не отвечает."
@export_multiline var locked_text_system: String = "Ошибка: пользователь находится внутри."
@export_multiline var locked_text_personal: String = "Выход не требуется до завершения сборки."
@export var is_locked: bool = false
@export var open_angle_degrees: float = 90.0
@export var animation_speed: float = 6.0
@export var objective_after_open: String = "Осмотреть комнату за дверью."
@export var objective_after_locked_first_check: String = "Проверить умную колонку."
@export var horror_event_id_after_locked_first_check: String = "smart_lock_denied"

var is_open: bool = false
var closed_rotation_y: float = 0.0
var target_rotation_y: float = 0.0
var locked_interaction_count: int = 0

func _ready() -> void:
    closed_rotation_y = rotation.y
    target_rotation_y = closed_rotation_y

func _process(delta: float) -> void:
    rotation.y = lerp_angle(rotation.y, target_rotation_y, minf(1.0, animation_speed * delta))

func get_interaction_text() -> String:
    if is_locked:
        return locked_check_text if locked_interaction_count == 0 else locked_repeat_check_text
    return close_text if is_open else open_text

func interact(_actor: Node = null) -> void:
    if is_locked:
        _handle_locked_interaction()
        return

    is_open = not is_open
    target_rotation_y = closed_rotation_y + deg_to_rad(open_angle_degrees if is_open else 0.0)

    if is_open and objective_after_open.strip_edges() != "":
        ObjectiveManager.complete_current_objective(objective_after_open)

func _handle_locked_interaction() -> void:
    GameState.show_message(locked_title, _get_locked_phase_text())

    if locked_interaction_count == 0:
        if objective_after_locked_first_check.strip_edges() != "":
            ObjectiveManager.complete_current_objective(objective_after_locked_first_check)
        if horror_event_id_after_locked_first_check.strip_edges() != "":
            HorrorEventManager.play_once(horror_event_id_after_locked_first_check, _play_locked_horror_event)

    locked_interaction_count += 1

func _get_locked_phase_text() -> String:
    match mini(locked_interaction_count, 2):
        0:
            return locked_text
        1:
            return locked_text_system
        _:
            return locked_text_personal

func _play_locked_horror_event() -> void:
    print("Horror event triggered: ", horror_event_id_after_locked_first_check)
