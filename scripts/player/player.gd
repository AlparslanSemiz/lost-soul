extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = _resolve_health_bar()
@onready var dash_bar_ui: DashBarUI = $UI/DashBar
@onready var flashlight_bar_ui: FlashlightBarUI = $UI/FlashlightBar
@onready var dash_stop_timer: Timer = $dash_stop_timer
@onready var dash_cooldown_timer: Timer = $dash_cooldown_timer
@onready var movement_component: Node = $Components/MovementComponent
@onready var jump_component: Node = $Components/JumpComponent
@onready var jump_wall_component: Node = $Components/JumpWallComponent
@onready var dash_component: Node = $Components/DashComponent
@onready var health_component: PlayerHealthComponent = $Components/HealthComponent
@onready var flashlight_component: PlayerFlashlightComponent = $Components/FlashlightComponent

@export var starts_with_dash_skill := true
@export var starts_with_flashlight_skill := false
@export var darkness_damage_enabled := false
@export var use_darkness_mechanics := false

const FLASHLIGHT_ENERGY := 1.35
const FLASHLIGHT_TEXTURE_SCALE := 2.45
const FLASHLIGHT_CONE_HALF_ANGLE_DEG := 28.0

var safe_zones := 0
var double_jump_orbit_overlap_count := 0
var dash_orbit_overlap_count := 0
var has_dash_skill := false
var has_flashlight_skill := false
var _flashlight_light: PointLight2D = null
var _ambient_light: PointLight2D = null
var _lantern_light: PointLight2D = null
var sarmasikta_mi: bool = false


func _resolve_health_bar() -> ProgressBar:
	var direct := get_node_or_null("HealthBar") as ProgressBar
	if direct != null:
		return direct
	return get_node_or_null("UI/HealthBar") as ProgressBar


func _ready() -> void:
	if CheckpointData.has_spawn:
		global_position = CheckpointData.spawn_position

	if health_component == null:
		push_error("HealthComponent bulunamadı: Components/HealthComponent")
		return
	if health_bar == null:
		push_error("HealthBar bulunamadı: HealthBar veya UI/HealthBar")
		return

	health_component.init_health(health_bar)
	has_dash_skill = starts_with_dash_skill
	if not has_dash_skill:
		dash_component.can_dash = false
	dash_bar_ui.init_dash(dash_cooldown_timer.wait_time)
	_update_dash_cooldown_ui()

	has_flashlight_skill = starts_with_flashlight_skill
	if has_flashlight_skill:
		_setup_flashlight()
	else:
		flashlight_bar_ui.set_locked()

	if use_darkness_mechanics:
		_setup_ambient_light()


func _physics_process(delta: float) -> void:
	if not health_component.can_receive_actions():
		velocity += get_gravity() * delta
		move_and_slide()
		return

	if not dash_component.dashing:
		jump_wall_component.apply_gravity(self, delta)
	jump_component.reset_on_floor(self)

	var direction := Input.get_axis("move_left", "move_right")
	var touching_wall: bool = jump_wall_component.apply_wall_slide(self, not dash_component.dashing)

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_component.jump_from_floor(self)
		elif touching_wall and sarmasikta_mi:			
			jump_wall_component.wall_jump(self, jump_component.jump_velocity)
			jump_component.restore_extra_jumps()
		else:
			jump_component.try_extra_jump(self, double_jump_orbit_overlap_count > 0)

	if has_dash_skill and Input.is_action_just_pressed("dash"):
		if dash_orbit_overlap_count > 0:
			dash_component.try_start_dash_forced(dash_stop_timer, dash_cooldown_timer)
		else:
			dash_component.try_start_dash(dash_stop_timer, dash_cooldown_timer)

	movement_component.apply_facing(animated_sprite, direction)

	if dash_component.dashing:
		dash_component.apply_dash_velocity(self, direction, animated_sprite.flip_h)
		dash_component.spawn_dash_trail(self, animated_sprite, delta)
		animated_sprite.play("dash")
	else:
		if not dash_component.apply_recovery_movement(self, direction, movement_component.speed, delta):
			movement_component.apply_horizontal_movement(self, direction)

		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle_torch" if has_flashlight_skill else "idle")
			else:
				animated_sprite.play("run_torch" if has_flashlight_skill else "run")
		elif touching_wall:
			animated_sprite.play("wall_slide")
		else:
			if direction == 0:
				animated_sprite.play("idle_jump")
			else:
				animated_sprite.play("jump")

	dash_component.update_cooldown_display(delta)
	move_and_slide()
	_update_dash_cooldown_ui()

	if has_flashlight_skill:
		flashlight_component.flashlight_update(delta)
		_update_flashlight_direction()


func _update_dash_cooldown_ui() -> void:
	if dash_bar_ui == null:
		return

	if not has_dash_skill:
		dash_bar_ui.set_locked()
		return

	if dash_component.can_dash and dash_component.get_cooldown_remaining() <= 0.0:
		dash_bar_ui.set_ready()
		return

	var remaining: float = max(dash_component.get_cooldown_remaining(), 0.0)
	var cooldown_duration: float = max(dash_component.get_cooldown_duration(), 0.001)
	dash_bar_ui.update_dash(remaining, cooldown_duration)


func take_damage(amount: int) -> void:
	if health_component.apply_damage(health_bar, amount):
		die()


func heal(amount: int) -> void:
	health_component.apply_heal(health_bar, amount)


func die() -> void:
	health_component.mark_dead()
	set_physics_process(false)
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	Engine.time_scale = 0.4
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	await get_tree().create_timer(0.8, true, false, true).timeout
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _on_dash_stop_timer_timeout() -> void:
	dash_component.on_dash_stop_timeout()


func _on_dash_cooldown_timer_timeout() -> void:
	dash_component.on_dash_cooldown_timeout()


func _on_orbit_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("double_jump_orbit"):
		double_jump_orbit_overlap_count += 1
	if area.is_in_group("dash_orbit"):
		dash_orbit_overlap_count += 1


func _on_orbit_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("double_jump_orbit"):
		double_jump_orbit_overlap_count = max(double_jump_orbit_overlap_count - 1, 0)
	if area.is_in_group("dash_orbit"):
		dash_orbit_overlap_count = max(dash_orbit_overlap_count - 1, 0)


func _on_darkness_damage_timer_timeout() -> void:
	if not darkness_damage_enabled:
		return
	if safe_zones == 0 and health_component.can_receive_actions():
		take_damage(5)


func unlock_skill(skill_name: String) -> bool:
	match skill_name:
		"dash":
			return unlock_dash_skill()
		"flashlight":
			return unlock_flashlight_skill()
		_:
			return false


func unlock_dash_skill() -> bool:
	if has_dash_skill:
		return false
	has_dash_skill = true
	dash_component.can_dash = true
	dash_component.cooldown_time_left = 0.0
	_update_dash_cooldown_ui()
	return true


func unlock_flashlight_skill() -> bool:
	if has_flashlight_skill:
		return false
	has_flashlight_skill = true
	_setup_flashlight()
	return true


func _setup_flashlight() -> void:
	_ensure_flashlight_light()
	flashlight_component.init_flashlight(_flashlight_light, null)
	flashlight_component.battery_changed.connect(_on_flashlight_battery_changed)
	flashlight_bar_ui.update_battery(1.0, false)
	if use_darkness_mechanics:
		flashlight_component.flashlight_toggled.connect(_on_flashlight_toggled)
		_setup_lantern_glow()


func _on_flashlight_battery_changed(percent: float) -> void:
	flashlight_bar_ui.update_battery(percent, flashlight_component.is_on)


func _update_flashlight_direction() -> void:
	var pivot := get_node_or_null("FlashlightPivot") as Node2D
	if pivot == null:
		return
	var facing_left := animated_sprite.flip_h
	pivot.scale.x = -1.0 if facing_left else 1.0
	if _lantern_light and is_instance_valid(_lantern_light):
		_lantern_light.position.x = -10.0 if facing_left else 10.0


func _ensure_flashlight_light() -> void:
	if _flashlight_light and is_instance_valid(_flashlight_light):
		return

	var pivot := get_node_or_null("FlashlightPivot") as Node2D
	if pivot == null:
		pivot = Node2D.new()
		pivot.name = "FlashlightPivot"
		pivot.position = Vector2(0, -28)
		add_child(pivot)

	_flashlight_light = PointLight2D.new()
	_flashlight_light.name = "PointLight2D"
	_flashlight_light.position = Vector2(0, 0)
	_flashlight_light.energy = FLASHLIGHT_ENERGY
	_flashlight_light.texture_scale = FLASHLIGHT_TEXTURE_SCALE
	_flashlight_light.range_z_min = -4096
	_flashlight_light.range_z_max = 4096
	_flashlight_light.range_layer_min = -128
	_flashlight_light.range_layer_max = 128
	_flashlight_light.color = Color(0.75, 0.5, 1.0)
	_flashlight_light.enabled = false
	_flashlight_light.shadow_enabled = true
	_flashlight_light.shadow_color = Color(0.0, 0.0, 0.0, 1.0)
	_flashlight_light.texture = _create_cone_texture()

	pivot.add_child(_flashlight_light)


func _setup_ambient_light() -> void:
	var light := PointLight2D.new()
	light.name = "AmbientLight"
	light.position = Vector2(0, -28.5)
	light.color = Color(1.0, 1.0, 1.0)
	light.energy = 3.2
	light.texture_scale = 0.45
	light.range_z_min = -4096
	light.range_z_max = 4096
	light.range_layer_min = -128
	light.range_layer_max = 128
	light.texture = _create_radial_texture(128)
	light.shadow_enabled = true
	light.shadow_color = Color(0.0, 0.0, 0.0, 1.0)
	_ambient_light = light
	add_child(light)


func _setup_lantern_glow() -> void:
	_lantern_light = PointLight2D.new()
	_lantern_light.name = "LanternGlow"
	_lantern_light.position = Vector2(10.0, -40.0)
	_lantern_light.color = Color(1.0, 0.72, 0.2)
	_lantern_light.energy = 1.4
	_lantern_light.texture_scale = 0.22
	_lantern_light.range_z_min = -4096
	_lantern_light.range_z_max = 4096
	_lantern_light.range_layer_min = -128
	_lantern_light.range_layer_max = 128
	_lantern_light.enabled = false
	_lantern_light.texture = _create_radial_texture(128)
	add_child(_lantern_light)


func _on_flashlight_toggled(is_on: bool) -> void:
	if _lantern_light and is_instance_valid(_lantern_light):
		_lantern_light.enabled = is_on





func _create_radial_texture(size: int) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var center := size / 2.0
	var max_dist := center
	for y in range(size):
		for x in range(size):
			var dist := Vector2(float(x) - center, float(y) - center).length()
			if dist < max_dist:
				var t := 1.0 - dist / max_dist
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, t))
	return ImageTexture.create_from_image(img)


func _create_cone_texture() -> ImageTexture:
	var size: int = 256
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var half: int = size >> 1
	var cx: float = float(half)
	var cy: float = float(half)
	var max_dist: float = float(half)
	var half_angle: float = deg_to_rad(FLASHLIGHT_CONE_HALF_ANGLE_DEG)
	for y in range(size):
		for x in range(size):
			var dx: float = float(x) - cx
			var dy: float = float(y) - cy
			if dx <= 0.0:
				continue
			var dist: float = sqrt(dx * dx + dy * dy)
			if dist > max_dist:
				continue
			var angle: float = abs(atan2(dy, dx))
			if angle > half_angle:
				continue
			var dist_falloff: float = 1.0 - dist / max_dist
			var angle_falloff: float = 1.0 - angle / half_angle
			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(dist_falloff * sqrt(angle_falloff), 0.0, 1.0)))
	return ImageTexture.create_from_image(img)
