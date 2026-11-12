extends Node2D
# Inspector'dan DarknessBlock sahnenizi buraya sürükleyip bırakacaksınız
@export var darkness_block_scene: PackedScene 

# Bloklarınızın piksel cinsinden boyutu (örneğin 32x32 ise buraya 32 yazın)
@export var grid_size: int = 32 

# Karanlığın ne kadar sürede bir yayılacağı (saniye)
@export var spread_interval: float = 0.2 

# Üst üste blok çıkmaması için dolu olan yerleri kaydedeceğimiz Sözlük (Dictionary)
var occupied_cells: Dictionary = {} 

# Sadece uçtaki (yayılma ihtimali olan) blokları tuttuğumuz liste (Performans için)
var edge_cells: Array[Vector2] = [] 

func _ready():
	randomize() # Rastgeleliği başlat
	
	# Kod ile bir Timer oluşturuyoruz, böylece sahneye manuel eklemenize gerek kalmaz
	var timer = Timer.new()
	timer.wait_time = spread_interval
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	# Oyuna sol alttaki (merkezdeki) ilk bloğu ekleyerek başlıyoruz.
	# Manager'ı sahnede nereye koyarsanız, (0,0) orası kabul edilir.
	add_block(Vector2.ZERO)

func _on_timer_timeout():
	if edge_cells.is_empty():
		return # Eğer yayılacak yer kalmadıysa dur

	# Uçtaki bloklardan rastgele birini seçiyoruz
	var random_index = randi() % edge_cells.size()
	var current_cell = edge_cells[random_index]

	# Godot'ta Y ekseni AŞAĞI doğru artar. 
	# Bu yüzden Yukarı gitmek için Y'yi EKSİLTİRİZ (-1). Sağ için X'i ARTIRIRIZ (+1).
	var possible_moves = [
		Vector2(1, 0),  # Sağ
		Vector2(0, -1), # Yukarı
		Vector2(1, -1)  # Sağ-Yukarı (Çapraz)
	]

	var valid_moves = []
	
	# Gidebileceği yönler boş mu diye kontrol et
	for move in possible_moves:
		var target_cell = current_cell + move
		if not occupied_cells.has(target_cell): # Eğer bu koordinat Dictionary'de YOKSA boş demektir
			valid_moves.append(target_cell)

	if valid_moves.size() > 0:
		# Eğer boş yer varsa, geçerli yerlerden birini rastgele seç ve blok koy
		var chosen_move = valid_moves[randi() % valid_moves.size()]
		add_block(chosen_move)
	else:
		# Eğer bu bloğun Sağ, Yukarı ve Sağ-Yukarı tarafları tamamen dolduysa,
		# artık bu bloktan yayılamayız. Listeden çıkarıyoruz ki bir daha işlem görmesin (Optimizasyon).
		edge_cells.remove_at(random_index)

func add_block(grid_pos: Vector2):
	# Odayı "dolu" olarak işaretle
	occupied_cells[grid_pos] = true
	# Yeni bloğu "yayılabilir uç blok" olarak listeye ekle
	edge_cells.append(grid_pos)

	# Sahneden yeni bir blok üret
	var new_block = darkness_block_scene.instantiate()
	
	# Bloğun pozisyonunu Grid (Izgara) sistemine göre ayarla
	new_block.position = grid_pos * grid_size
	
	# Bloğu Manager'ın bir alt objesi olarak sahneye ekle
	add_child(new_block)
