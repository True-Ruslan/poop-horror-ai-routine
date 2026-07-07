extends Node3D

const SAMPLE_RATE: int = 22050
const TAU_VALUE: float = PI * 2.0
const SMART_SPEAKER_SCRIPT: String = "res://game/scripts/objects/SmartSpeaker.gd"

@export var terminal_path: NodePath = NodePath("ComputerTerminal")
@export var desk_lamp_path: NodePath = NodePath("DeskLamp")
@export var smart_speaker_path: NodePath = NodePath("SmartSpeaker")
@export var lamp_blink_event_id: String = "terminal_first_ai_reply"
@export var objective_after_lamp_event: String = "Проверить, почему лампа щёлкнула сама."
@export var blink_count: int = 3
@export var blink_interval_seconds: float = 0.18
@export var delay_before_blink_seconds: float = 0.7
@export var terminal_notification_volume_db: float = -17.0
@export var lamp_click_volume_db: float = -12.0

var _lamp_event_started: bool = false
var _terminal_notification_stream: AudioStreamWAV
var _lamp_click_stream: AudioStreamWAV

func _ready() -> void:
    _terminal_notification_stream = _make_terminal_notification_stream()
    _lamp_click_stream = _make_lamp_click_stream()
    _setup_smart_speaker()
    HorrorEventManager.horror_event_started.connect(_on_horror_event_started)

func _setup_smart_speaker() -> void:
    var smart_speaker := get_node_or_null(smart_speaker_path)
    if smart_speaker == null or smart_speaker.has_method("interact"):
        return

    var speaker_script := load(SMART_SPEAKER_SCRIPT)
    if speaker_script != null:
        smart_speaker.set_script(speaker_script)

func _on_horror_event_started(event_id: String) -> void:
    if event_id != lamp_blink_event_id or _lamp_event_started:
        return

    _lamp_event_started = true
    _play_sound_at(_terminal_notification_stream, terminal_path, terminal_notification_volume_db)
    call_deferred("_blink_desk_lamp")

func _blink_desk_lamp() -> void:
    await get_tree().create_timer(delay_before_blink_seconds).timeout

    var lamp := get_node_or_null(desk_lamp_path)
    if not (lamp is Light3D):
        return

    _play_sound_at(_lamp_click_stream, desk_lamp_path, lamp_click_volume_db)

    var light := lamp as Light3D
    var original_visible := light.visible
    var original_energy := light.light_energy

    for _i in range(maxi(1, blink_count)):
        light.visible = false
        await get_tree().create_timer(blink_interval_seconds).timeout
        light.visible = true
        light.light_energy = original_energy * 1.35
        await get_tree().create_timer(blink_interval_seconds).timeout
        light.light_energy = original_energy

    light.visible = original_visible
    light.light_energy = original_energy

    if objective_after_lamp_event.strip_edges() != "":
        ObjectiveManager.complete_current_objective(objective_after_lamp_event)

func _play_sound_at(stream: AudioStream, source_path: NodePath, volume_db: float) -> void:
    if stream == null:
        return

    var player := AudioStreamPlayer3D.new()
    player.stream = stream
    player.volume_db = volume_db
    player.max_distance = 8.0
    player.unit_size = 1.6

    var source := get_node_or_null(source_path)
    if source is Node3D:
        var source_3d := source as Node3D
        player.global_position = source_3d.global_position
    else:
        player.global_position = global_position

    add_child(player)
    player.finished.connect(player.queue_free)
    player.play()

func _make_terminal_notification_stream() -> AudioStreamWAV:
    return _make_tone_stream(880.0, 0.09, 0.45)

func _make_lamp_click_stream() -> AudioStreamWAV:
    var data := PackedByteArray()
    var sample_count := int(SAMPLE_RATE * 0.055)

    for i in range(sample_count):
        var progress := float(i) / float(sample_count)
        var envelope := pow(1.0 - progress, 5.0)
        var pulse := sin(float(i) * 0.91) + sin(float(i) * 0.37)
        var sample := int(clampf(128.0 + pulse * 42.0 * envelope, 0.0, 255.0))
        data.append(sample)

    return _make_wav_stream(data)

func _make_tone_stream(frequency: float, duration_seconds: float, amplitude: float) -> AudioStreamWAV:
    var data := PackedByteArray()
    var sample_count := int(SAMPLE_RATE * duration_seconds)

    for i in range(sample_count):
        var progress := float(i) / float(sample_count)
        var envelope := sin(progress * PI)
        var wave := sin(TAU_VALUE * frequency * float(i) / float(SAMPLE_RATE))
        var sample := int(clampf(128.0 + wave * 127.0 * amplitude * envelope, 0.0, 255.0))
        data.append(sample)

    return _make_wav_stream(data)

func _make_wav_stream(data: PackedByteArray) -> AudioStreamWAV:
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_8_BITS
    stream.mix_rate = SAMPLE_RATE
    stream.stereo = false
    stream.data = data
    return stream
