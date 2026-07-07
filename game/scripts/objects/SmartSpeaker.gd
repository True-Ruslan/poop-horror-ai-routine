extends StaticBody3D

@export var interaction_text_normal: String = "E — проверить колонку"
@export var interaction_text_after_trigger: String = "E — прислушаться к колонке"
@export var speaker_title: String = "Умная колонка"
@export var required_event_id: String = "terminal_first_ai_reply"
@export var horror_event_id_after_first_use: String = "speaker_wrong_name"
@export var objective_after_first_strange_use: String = "Вернуться к рабочему терминалу."
@export_multiline var normal_body: String = "Индикатор не горит.\n\nКолонка сухо щёлкает и отвечает слишком обычным голосом:\n\nКоманда не распознана."
@export_multiline var strange_body: String = "Индикатор загорается сам.\n\nКоманда не распознана.\n\nПауза.\n\nРаспознана команда: продолжать.\n\nРежим сна отклонён."
@export_multiline var repeat_body: String = "Индикатор больше не мигает.\n\nРежим сна отклонён."

var was_strange_used: bool = false

func get_interaction_text() -> String:
    if HorrorEventManager.has_played(required_event_id):
        return interaction_text_after_trigger
    return interaction_text_normal

func interact(_actor: Node = null) -> void:
    if not HorrorEventManager.has_played(required_event_id):
        GameState.show_message(speaker_title, normal_body)
        return

    if was_strange_used:
        GameState.show_message(speaker_title, repeat_body)
        return

    was_strange_used = true
    GameState.show_message(speaker_title, strange_body)

    if objective_after_first_strange_use.strip_edges() != "":
        ObjectiveManager.complete_current_objective(objective_after_first_strange_use)

    if horror_event_id_after_first_use.strip_edges() != "":
        HorrorEventManager.play_once(horror_event_id_after_first_use, _play_speaker_horror_event)

func _play_speaker_horror_event() -> void:
    print("Horror event triggered: ", horror_event_id_after_first_use)
