extends CanvasLayer

@export var terminal_device_list_event_id: String = "terminal_device_list"
@export var hud_objective_glitch_event_id: String = "hud_objective_corrupt"
@export var objective_glitch_delay_seconds: float = 0.55
@export var objective_after_glitch: String = "Дождаться подтверждения."

@onready var prompt_label: Label = $Root/PromptLabel
@onready var objective_label: Label = $Root/ObjectiveLabel
@onready var battery_label: Label = $Root/BatteryLabel
@onready var message_panel: Panel = $Root/MessagePanel
@onready var message_title: Label = $Root/MessagePanel/MarginContainer/VBoxContainer/MessageTitle
@onready var message_body: RichTextLabel = $Root/MessagePanel/MarginContainer/VBoxContainer/MessageBody
@onready var pause_label: Label = $Root/PauseLabel

var _objective_glitch_pending: bool = false
var _objective_glitch_started: bool = false

func _ready() -> void:
    GameState.interaction_prompt_changed.connect(_on_interaction_prompt_changed)
    GameState.message_requested.connect(_on_message_requested)
    GameState.message_closed.connect(_on_message_closed)
    GameState.flashlight_battery_changed.connect(_on_flashlight_battery_changed)
    GameState.game_paused_changed.connect(_on_game_paused_changed)
    ObjectiveManager.objective_changed.connect(_on_objective_changed)
    HorrorEventManager.horror_event_started.connect(_on_horror_event_started)

    message_panel.visible = false
    pause_label.visible = false
    prompt_label.text = ""
    objective_label.text = "Задача: " + ObjectiveManager.current_objective

func _on_interaction_prompt_changed(text: String) -> void:
    prompt_label.text = text

func _on_objective_changed(text: String) -> void:
    objective_label.text = "Задача: " + text

func _on_flashlight_battery_changed(value: float) -> void:
    battery_label.text = "Фонарик: %d%%" % int(value)

func _on_message_requested(title: String, body: String) -> void:
    message_title.text = title
    message_body.text = body + "\n\n[Esc] закрыть"
    message_panel.visible = true

func _on_message_closed() -> void:
    message_panel.visible = false

    if _objective_glitch_pending:
        call_deferred("_start_objective_glitch")

func _on_game_paused_changed(is_paused: bool) -> void:
    pause_label.visible = is_paused

func _on_horror_event_started(event_id: String) -> void:
    if event_id != terminal_device_list_event_id or _objective_glitch_started:
        return

    _objective_glitch_pending = true

    if not GameState.is_reading_message:
        call_deferred("_start_objective_glitch")

func _start_objective_glitch() -> void:
    if _objective_glitch_started:
        return

    _objective_glitch_started = true
    _objective_glitch_pending = false

    await get_tree().create_timer(objective_glitch_delay_seconds).timeout
    HorrorEventManager.play_once(hud_objective_glitch_event_id, _apply_objective_glitch)

func _apply_objective_glitch() -> void:
    if objective_after_glitch.strip_edges() != "":
        ObjectiveManager.set_objective(objective_after_glitch)
