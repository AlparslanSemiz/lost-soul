extends Node

@export var min_wait: float = 5.0
@export var max_wait: float = 15.0
@export var min_blackout: float = 3.0
@export var max_blackout: float = 5.0
@export var fade_duration: float = 0.6
@export var blackout_modulate_color: Color = Color(0.03, 0.03, 0.05, 1.0)

@onready var _overlay: ColorRect = $BlackoutLayer/Overlay
@onready var _world_modulate: CanvasModulate = get_parent().get_node_or_null("CanvasModulate") as CanvasModulate

var _mat: ShaderMaterial
var _is_blackout := false
var _normal_modulate_color := Color(1.0, 1.0, 1.0, 1.0)


func _ready() -> void:
	if _world_modulate:
		_normal_modulate_color = _world_modulate.color

	if _overlay:
		_overlay.visible = false
		_mat = _overlay.material as ShaderMaterial
		if _mat:
			var vp_size := get_viewport().get_visible_rect().size
			_mat.set_shader_parameter("aspect", vp_size.x / vp_size.y)
			_mat.set_shader_parameter("blackout_alpha", 0.0)
			_mat.set_shader_parameter("light_on", false)

	_loop()


func _loop() -> void:
	while true:
		await get_tree().create_timer(randf_range(min_wait, max_wait)).timeout
		_is_blackout = true
		await _fade_to_blackout(true)
		await get_tree().create_timer(randf_range(min_blackout, max_blackout)).timeout
		await _fade_to_blackout(false)
		_is_blackout = false


func _fade_to_blackout(to_blackout: bool) -> void:
	if _world_modulate:
		var target_color := blackout_modulate_color if to_blackout else _normal_modulate_color
		await _fade_modulate(target_color)
		return

	if _mat:
		await _fade_overlay(1.0 if to_blackout else 0.0)


func _fade_modulate(target: Color) -> void:
	var start := _world_modulate.color
	var elapsed := 0.0
	while elapsed < fade_duration:
		elapsed += get_process_delta_time()
		_world_modulate.color = start.lerp(target, minf(elapsed / fade_duration, 1.0))
		await get_tree().process_frame
	_world_modulate.color = target


func _fade_overlay(target: float) -> void:
	var start: float = _mat.get_shader_parameter("blackout_alpha")
	var elapsed := 0.0
	while elapsed < fade_duration:
		elapsed += get_process_delta_time()
		_mat.set_shader_parameter("blackout_alpha", lerpf(start, target, minf(elapsed / fade_duration, 1.0)))
		await get_tree().process_frame
	_mat.set_shader_parameter("blackout_alpha", target)
