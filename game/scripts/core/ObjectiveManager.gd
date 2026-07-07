extends Node

signal objective_changed(text: String)
signal objective_completed(text: String)

var current_objective: String = "Осмотреть помещение."
var completed_objectives: Array[String] = []

func _ready() -> void:
    call_deferred("set_objective", current_objective)

func set_objective(text: String) -> void:
    current_objective = text
    objective_changed.emit(current_objective)

func complete_current_objective(next_objective: String = "") -> void:
    if current_objective.strip_edges() != "":
        completed_objectives.append(current_objective)
        objective_completed.emit(current_objective)

    if next_objective.strip_edges() != "":
        set_objective(next_objective)
