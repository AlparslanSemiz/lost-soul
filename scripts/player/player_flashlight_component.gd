extends Node
class_name PlayerFlashlightComponent

signal battery_changed(percent: float)
signal flashlight_toggled(is_on: bool)
signal battery_empty

@export var max_battery: float = 100.0
@export var drain_rate: float = 22.0
@export var charge_rate: float = 5.0
@export var flicker_intensity: float = 0.05
@export var stun_interval: float = 0.5

var is_on: bool = false
var battery: float = 100.0

var _light: PointLight2D
var _cone: Area2D
var _stun_timer: float = 0.0


func init_flashlight(light: PointLight2D, cone: Area2D) -> void:
	_light = light
	_cone = cone
	_light.enabled = false


func flashlight_update(delta: float) -> void:
	_handle_input()
	_update_battery(delta)
	_update_visuals()
	_tick_stun(delta)


func _handle_input() -> void:
	if Input.is_action_just_pressed("flashlight"):
		if is_on:
			_turn_off()
		elif battery > 0.0:
			_turn_on()


func _update_battery(delta: float) -> void:
	if is_on:
		battery = max(battery - drain_rate * delta, 0.0)
		if battery == 0.0:
			_turn_off()
			battery_empty.emit()
	else:
		battery = min(battery + charge_rate * delta, max_battery)
	battery_changed.emit(battery / max_battery)


func _update_visuals() -> void:
	if _light == null or not is_on:
		return
	var base_energy := battery / max_battery
	_light.energy = clamp(base_energy + randf_range(-flicker_intensity, flicker_intensity), 0.0, 1.0)


func _tick_stun(delta: float) -> void:
	if not is_on or _cone == null:
		return
	_stun_timer -= delta
	if _stun_timer > 0.0:
		return
	_stun_timer = stun_interval
	for body in _cone.get_overlapping_bodies():
		if body.is_in_group("Enemy") and body.has_method("stun"):
			body.stun()


func _turn_on() -> void:
	is_on = true
	if _light:
		_light.enabled = true
	flashlight_toggled.emit(true)


func _turn_off() -> void:
	is_on = false
	if _light:
		_light.enabled = false
	flashlight_toggled.emit(false)


func get_battery_percent() -> float:
	return battery / max_battery
