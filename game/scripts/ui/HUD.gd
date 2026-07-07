extends CanvasLayer

@onready var prompt_label: Label = $Root/PromptLabel
@onready var objective_label: Label = $Root/ObjectiveLabel
@onready var battery_label: Label = $Root/BatteryLabel
@onready var message_panel: Panel = $Root/MessagePanel
@onready var message_title: Label = $Root/MessagePanel/MarginContainer/VBoxContainer/MessageTitle
@onready var message_body: RichTextLabel = $Root/MessagePanel/MarginContainer/VBoxContainer/MessageBody
@onready var pause_label: Label = $Root/PauseLabel

func _ready() -> void:
    GameState.interaction_prompt_changed.connect(_on_interaction_prompt_changed)
    GameState.message_requested.connect(_on_message_requested)
    GameState.message_closed.connect(_on_message_closed)
    GameState.flashlight_battery_changed.connect(_on_flashlight_battery_changed)
    GameState.game_paused_changed.connect(_on_game_paused_changed)
    ObjectiveManager.objective_changed.connect(_on_objective_changed)

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

func _on_game_paused_changed(is_paused: bool) -> void:
    pause_label.visible = is_paused
