extends CharacterBody2D

@export var speed: float = 90.0
@export var patrol_speed: float = 50.0
@export var jump_velocity: float = -380.0
@export var vision_range: float = 150.0
@export var vision_angle_degrees: float = 30.0
@export var stop_chase_range: float = 400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var vision_cone: Polygon2D = $VisionCone
@onready var wall_check_low: RayCast2D = $WallCheckLow
@onready var wall_check_high: RayCast2D = $WallCheckHigh
@onready var ledge_check: RayCast2D = $LedgeCheck

var player: Node2D = null
var is_chasing: bool = false
var facing_direction: int = 1


func _ready() -> void:
	# Sadece CharacterBody2D olan player'i kabul et (yanlislikla group'a
	# baska bir Sprite/Node eklenirse onu yok say)
	for n in get_tree().get_nodes_in_group("player"):
		if n is CharacterBody2D:
			player = n
			break
	if player == null:
		push_warning("[Enemy] 'player' group'unda CharacterBody2D yok — kovalama çalismaz!")
	raycast.add_exception(self)
	raycast.collide_with_areas = false
	raycast.collide_with_bodies = true

	# Wall/ledge raycast'leri kendini ve player'i engel olarak gormesin
	# (yoksa kovalarken player'in üstünden ziplar, hasar veremez)
	for rc in [wall_check_low, wall_check_high, ledge_check]:
		rc.add_exception(self)
		if player:
			rc.add_exception(player)

	build_vision_cone()


func _physics_process(delta: float) -> void:
	# Yer çekimi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Player tespiti
	var in_cone := is_player_in_cone()
	var los := has_line_of_sight()

	if in_cone and los:
		is_chasing = true
	elif player and global_position.distance_to(player.global_position) > stop_chase_range:
		is_chasing = false

	if is_chasing and player:
		# KOVALAMA → saldiri animasyonu
		var dir: float = sign(player.global_position.x - global_position.x)
		if dir != 0:
			facing_direction = int(dir)

		# Önündeki 1 blok engeli zipla (2 blok varsa zaten gecemez ama dönmeyiz,
		# yine de duvara dayanip ittirmeye devam eder; player asilinda inebilir)
		if wall_check_low.is_colliding() and is_on_floor():
			velocity.y = jump_velocity

		velocity.x = facing_direction * speed
		animated_sprite.play("attack")
	else:
		# DEVRİYE → normal yürüme animasyonu
		var low_blocked: bool = wall_check_low.is_colliding()
		var high_blocked: bool = wall_check_high.is_colliding()
		var ledge: bool = not ledge_check.is_colliding()

		if high_blocked:
			# 2+ blok duvar → dön
			facing_direction *= -1
		elif low_blocked and is_on_floor():
			# 1 blok duvar → zıpla
			velocity.y = jump_velocity
		elif ledge and is_on_floor():
			# Uçurum kenarı → dön
			facing_direction *= -1

		velocity.x = facing_direction * patrol_speed
		animated_sprite.play("default")

	# Sprite ve raycast yönlerini güncelle
	animated_sprite.flip_h = facing_direction < 0
	update_raycast_directions()

	move_and_slide()


func update_raycast_directions() -> void:
	wall_check_low.target_position.x = abs(wall_check_low.target_position.x) * facing_direction
	wall_check_high.target_position.x = abs(wall_check_high.target_position.x) * facing_direction
	ledge_check.position.x = abs(ledge_check.position.x) * facing_direction
	vision_cone.scale.x = facing_direction


func is_player_in_cone() -> bool:
	if player == null:
		return false
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() > vision_range:
		return false
	var forward: Vector2 = Vector2(facing_direction, 0)
	var angle_to_player: float = rad_to_deg(forward.angle_to(to_player))
	return abs(angle_to_player) <= vision_angle_degrees / 2.0


func has_line_of_sight() -> bool:
	if player == null:
		return false
	var target: Vector2 = player.global_position + Vector2(0, -16)
	raycast.target_position = target - raycast.global_position
	raycast.force_raycast_update()
	if raycast.is_colliding():
		return raycast.get_collider() == player
	return true


func build_vision_cone() -> void:
	var points: PackedVector2Array = []
	points.append(Vector2.ZERO)
	var half_angle: float = deg_to_rad(vision_angle_degrees / 2.0)
	var segments: int = 16
	for i in range(segments + 1):
		var t: float = float(i) / float(segments)
		var angle: float = -half_angle + t * (2.0 * half_angle)
		points.append(Vector2(cos(angle), sin(angle)) * vision_range)
	vision_cone.polygon = points
	vision_cone.color = Color(1.0, 0.0, 0.0, 0.25)
