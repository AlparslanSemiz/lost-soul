extends Area2D

# Karakter bu alana girdiginde sonraki sahneye geçer.
#
# Inspector'da ayarla:
#   - next_scene_path: Geçilecek sahnenin yolu, ör. "res://scenes/levels/level2.tscn"
#   - story_lines: Geçis sirasinda gösterilecek hikaye satirlari (bos birakilabilir)
#   - story_image_paths: Geçis sirasinda gösterilecek cutscene görselleri (bos birakilabilir)
#   - trigger_group: Tetikleyici grup (varsayilan "player")
#
# Tek seferlik tetiklenir — üzerine tekrar girilse de bir daha çalismaz.

@export_file("*.tscn") var next_scene_path: String = ""
@export var story_lines: PackedStringArray = PackedStringArray()
@export var story_image_paths: PackedStringArray = PackedStringArray()
@export var trigger_group: String = "player"

var _triggered: bool = false


func _ready() -> void:
	# Editor'da yanlislikla collision_layer/mask sifir kalmasin diye guard:
	# Bu Area2D player'i tespit etmeli — layer 1 ve 2 ikisini de kapsa.
	if collision_mask == 0:
		collision_mask = 3

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _triggered:
		return
	if not body.is_in_group(trigger_group):
		return
	if next_scene_path.is_empty():
		push_warning("[LevelExit] next_scene_path bos — geçis yapilamaz (%s)" % name)
		return

	_triggered = true

	# SceneTransition autoload'i kayitliysa onu kullan, degilse direkt sahne degistir
	var st := get_node_or_null("/root/SceneTransition")
	if st != null and st.has_method("transition_to"):
		st.transition_to(next_scene_path, story_lines, story_image_paths)
	else:
		push_warning("[LevelExit] SceneTransition autoload bulunamadi — direkt geçis yapiliyor")
		Engine.time_scale = 1.0
		get_tree().change_scene_to_file(next_scene_path)
