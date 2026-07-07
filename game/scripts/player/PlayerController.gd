extends CharacterBody3D

@export var walk_speed: float = 4.0
@export var sprint_speed: float = 6.5
@export var crouch_speed: float = 2.0
@export var acceleration: float = 12.0
@export var gravity: float = 18.0
@export var mouse_sensitivity: float = 0.0025
@export var standing_height: float = 1.6
@export var crouching_height: float = 1.0

@onready var camera_pivot: Node3D = $CameraPivot

var look_x: float = 0.0

func _unhandled_input(event: InputEvent) -> void:
    if GameState.is_reading_message or get_tree().paused:
        return

    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        look_x = clampf(look_x - event.relative.y * mouse_sensitivity, deg_to_rad(-82.0), deg_to_rad(82.0))
        camera_pivot.rotation.x = look_x

func _physics_process(delta: float) -> void:
    if GameState.is_reading_message or get_tree().paused:
        return

    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction := (global_transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

    var target_speed := walk_speed
    if Input.is_action_pressed("sprint") and not Input.is_action_pressed("crouch"):
        target_speed = sprint_speed
    elif Input.is_action_pressed("crouch"):
        target_speed = crouch_speed

    var target_velocity := direction * target_speed
    velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = -0.1

    _update_crouch(delta)
    move_and_slide()

func _update_crouch(delta: float) -> void:
    var target_y := crouching_height if Input.is_action_pressed("crouch") else standing_height
    camera_pivot.position.y = lerpf(camera_pivot.position.y, target_y, minf(1.0, delta * 12.0))
