extends Area2D

@export var skill_name: String = "dash"
@export var pickup_label: String = "Skill alındı"
@export var rotate_speed: float = 1.5
@export var bob_height: float = 4.0
@export var bob_speed: float = 4.0

var _origin_position: Vector2
var _time_accumulator: float = 0.0


func _ready() -> void:
	_origin_position = global_position
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time_accumulator += delta
	rotation += rotate_speed * delta
	global_position.y = _origin_position.y + sin(_time_accumulator * bob_speed) * bob_height


func _on_body_entered(body: Node) -> void:
	if not body.has_method("unlock_skill"):
		return

	var unlocked: bool = body.unlock_skill(skill_name)
	if not unlocked:
		return

	print(pickup_label)
	queue_free()
