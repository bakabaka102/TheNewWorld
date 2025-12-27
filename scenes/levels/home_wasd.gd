extends Node2D

# ============================================
# ENEMY SPAWNER - TẤT CẢ PHƯƠNG THỨC
# ============================================

# ========== CẤU HÌNH CHUNG ==========
@export var mob_scene: PackedScene      # Kéo Mob.tscn vào đây
@export var max_mobs = 10                # Số lượng mob tối đa
@export var spawn_interval = 0.5        # Thời gian giữa mỗi lần spawn (giây)

# ========== CẤU HÌNH CHO TỪNG PHƯƠNG THỨC ==========
# Method 1: Spawn quanh Player
@export var min_distance_from_player = 250.0
@export var max_distance_from_player = 500.0

# Method 2: Spawn tại các điểm cố định
@export var spawn_points: Array[Node2D] = []  # Kéo các Marker2D vào đây

# Method 3: Spawn theo waves
@export var mobs_per_wave = 3
@export var wave_interval = 10.0

# Method 4: Spawn trong vùng hình chữ nhật
@export var spawn_area_min = Vector2(450, 200)
@export var spawn_area_max = Vector2(1900, 650)

# ========== BIẾN NỘI BỘ ==========
var spawn_timer = 0.0
var wave_timer = 0.0
var current_wave = 0
var current_mobs = []

func _ready() -> void:
	if not mob_scene:
		push_error("❌ Mob scene chưa được gán! Kéo Mob.tscn vào Inspector")
		return
	
	print("✅ Enemy Spawner ready!")
	print("   Max mobs: ", max_mobs)
	print("   Spawn interval: ", spawn_interval, "s")
	queue_redraw()

func _process(delta: float) -> void:
	# Xóa mob đã chết khỏi danh sách
	clean_dead_mobs()
	
	# ============================================
	# CHỌN 1 PHƯƠNG THỨC BÊN DƯỚI ĐỂ TEST
	# ============================================
	
	# METHOD 1: Spawn quanh Player (ĐANG BẬT)
	process_spawn_around_player(delta)
	
	# METHOD 2: Spawn tại điểm cố định (TẮT)
	#process_spawn_at_points(delta)
	
	# METHOD 3: Spawn theo waves (TẮT)
	#process_spawn_waves(delta)
	
	# METHOD 4: Spawn trong vùng ngẫu nhiên (TẮT)
	#process_spawn_random_area(delta)
	
	# METHOD 5: Spawn từ cạnh màn hình (TẮT)
	#process_spawn_from_edges(delta)

# ============================================
# METHOD 1: SPAWN QUANH PLAYER
# ============================================
# Spawn mob xung quanh player, cách player một khoảng nhất định
# + Ưu điểm: Mob luôn gần player, tăng độ khó
# + Nhược điểm: Player có thể chạy xa để tránh
func process_spawn_around_player(delta: float) -> void:
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval and current_mobs.size() < max_mobs:
		spawn_mob_around_player()
		spawn_timer = 0.0

func spawn_mob_around_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("⚠️ Không tìm thấy player! Thêm player vào group 'player'")
		return
	
	# Tạo mob
	var mob = mob_scene.instantiate()
	
	# Tính vị trí spawn xung quanh player
	var angle = randf() * TAU  # Random góc 0-360
	var distance = randf_range(min_distance_from_player, max_distance_from_player)
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
	
	# Giới hạn trong map
	spawn_pos = clamp_position_to_map(spawn_pos)
	
	mob.global_position = spawn_pos
	add_child(mob)
	current_mobs.append(mob)
	
	print("🎯 [Method 1] Spawned mob around player at ", spawn_pos, " | Total: ", current_mobs.size())

# ============================================
# METHOD 2: SPAWN TẠI CÁC ĐIỂM CỐ ĐỊNH
# ============================================
# Spawn tại các Marker2D đã đặt sẵn trong scene
# + Ưu điểm: Kiểm soát chính xác vị trí
# + Nhược điểm: Phải setup thủ công
# Setup: Thêm Marker2D vào scene, kéo vào mảng spawn_points
func process_spawn_at_points(delta: float) -> void:
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval and current_mobs.size() < max_mobs:
		spawn_mob_at_point()
		spawn_timer = 0.0

func spawn_mob_at_point() -> void:
	if spawn_points.is_empty():
		push_warning("⚠️ Chưa có spawn points! Thêm Marker2D vào mảng spawn_points")
		return
	
	# Chọn ngẫu nhiên 1 spawn point
	var spawn_point = spawn_points.pick_random()
	
	var mob = mob_scene.instantiate()
	mob.global_position = spawn_point.global_position
	
	add_child(mob)
	current_mobs.append(mob)
	
	print("📍 [Method 2] Spawned mob at point ", spawn_point.name, " | Total: ", current_mobs.size())

# ============================================
# METHOD 3: SPAWN THEO WAVES (LÀN SÓNG)
# ============================================
# Spawn nhiều mob cùng lúc theo đợt
# + Ưu điểm: Tạo nhịp độ game rõ ràng
# + Nhược điểm: Có thể quá khó nếu spawn nhiều
func process_spawn_waves(delta: float) -> void:
	wave_timer += delta
	
	if wave_timer >= wave_interval and current_mobs.size() < max_mobs:
		spawn_wave()
		wave_timer = 0.0

func spawn_wave() -> void:
	current_wave += 1
	var spawn_count = min(mobs_per_wave, max_mobs - current_mobs.size())
	
	print("🌊 [Method 3] === WAVE ", current_wave, " ===")
	
	for i in range(spawn_count):
		var mob = mob_scene.instantiate()
		
		# Spawn từ các cạnh map
		mob.global_position = get_edge_spawn_position()
		
		add_child(mob)
		current_mobs.append(mob)
	
	print("   Spawned ", spawn_count, " mobs | Total: ", current_mobs.size())

func get_edge_spawn_position() -> Vector2:
	# Spawn từ 4 cạnh của map
	var side = randi() % 4
	match side:
		0: return Vector2(randf_range(spawn_area_min.x, spawn_area_max.x), spawn_area_min.y)  # Trên
		1: return Vector2(randf_range(spawn_area_min.x, spawn_area_max.x), spawn_area_max.y)  # Dưới
		2: return Vector2(spawn_area_min.x, randf_range(spawn_area_min.y, spawn_area_max.y))  # Trái
		_: return Vector2(spawn_area_max.x, randf_range(spawn_area_min.y, spawn_area_max.y))  # Phải

# ============================================
# METHOD 4: SPAWN TRONG VÙNG NGẪU NHIÊN
# ============================================
# Spawn hoàn toàn ngẫu nhiên trong vùng hình chữ nhật
# + Ưu điểm: Đơn giản, không cần setup
# + Nhược điểm: Có thể spawn vào vị trí không mong muốn
func process_spawn_random_area(delta: float) -> void:
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval and current_mobs.size() < max_mobs:
		spawn_mob_random_area()
		spawn_timer = 0.0

func spawn_mob_random_area() -> void:
	var mob = mob_scene.instantiate()
	
	# Random vị trí trong vùng
	var random_x = randf_range(spawn_area_min.x, spawn_area_max.x)
	var random_y = randf_range(spawn_area_min.y, spawn_area_max.y)
	mob.global_position = Vector2(random_x, random_y)
	
	add_child(mob)
	current_mobs.append(mob)
	
	print("🎲 [Method 4] Spawned mob randomly at ", mob.global_position, " | Total: ", current_mobs.size())

# ============================================
# METHOD 5: SPAWN TỪ CẠNH MÀN HÌNH
# ============================================
# Spawn từ ngoài màn hình, mob đi vào
# + Ưu điểm: Player thấy mob xuất hiện tự nhiên
# + Nhược điểm: Cần camera để hoạt động tốt
func process_spawn_from_edges(delta: float) -> void:
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval and current_mobs.size() < max_mobs:
		spawn_mob_from_edge()
		spawn_timer = 0.0

func spawn_mob_from_edge() -> void:
	var camera = get_viewport().get_camera_2d()
	var spawn_pos: Vector2
	
	if camera:
		# Spawn ngoài màn hình camera
		var viewport_size = get_viewport_rect().size
		var camera_pos = camera.global_position
		var offset = 100  # Spawn cách cạnh màn hình 100px
		
		var side = randi() % 4
		match side:
			0: spawn_pos = camera_pos + Vector2(randf_range(0, viewport_size.x), -offset)  # Trên
			1: spawn_pos = camera_pos + Vector2(randf_range(0, viewport_size.x), viewport_size.y + offset)  # Dưới
			2: spawn_pos = camera_pos + Vector2(-offset, randf_range(0, viewport_size.y))  # Trái
			_: spawn_pos = camera_pos + Vector2(viewport_size.x + offset, randf_range(0, viewport_size.y))  # Phải
	else:
		# Fallback: spawn từ cạnh map
		spawn_pos = get_edge_spawn_position()
	
	var mob = mob_scene.instantiate()
	mob.global_position = spawn_pos
	
	add_child(mob)
	current_mobs.append(mob)
	
	print("🚪 [Method 5] Spawned mob from edge at ", spawn_pos, " | Total: ", current_mobs.size())

# ============================================
# HÀM HỖ TRỢ
# ============================================

# Giới hạn vị trí trong map (tùy chỉnh theo map của bạn)
func clamp_position_to_map(pos: Vector2) -> Vector2:
	pos.x = clamp(pos.x, spawn_area_min.x, spawn_area_max.x)
	pos.y = clamp(pos.y, spawn_area_min.y, spawn_area_max.y)
	return pos

# Xóa mob đã bị destroy khỏi danh sách
func clean_dead_mobs() -> void:
	for i in range(current_mobs.size() - 1, -1, -1):
		if not is_instance_valid(current_mobs[i]):
			current_mobs.remove_at(i)

# Kiểm tra vị trí có hợp lệ không (không spawn trong hồ, tường...)
func is_valid_spawn_position(pos: Vector2) -> bool:
	# VD: Kiểm tra không spawn trong hồ ở giữa map
	var lake_center = Vector2(850, 280)
	var lake_radius = 150
	
	if pos.distance_to(lake_center) < lake_radius:
		return false  # Trong hồ
	
	# Có thể thêm kiểm tra khác (raycast, tilemap...)
	return true

# ============================================
# DEBUG - Vẽ vùng spawn
# ============================================
func _draw():
	# Vẽ khung vùng spawn (chỉ hiện trong editor/debug)
	var rect_pos = spawn_area_min
	var rect_size = spawn_area_max - spawn_area_min
	
	draw_rect(
		Rect2(rect_pos, rect_size),
		Color(1, 0, 0, 0.2),  # Đỏ trong suốt
		false,
		3.0
	)
	
	# Vẽ các spawn points
	for point in spawn_points:
		if is_instance_valid(point):
			draw_circle(point.position, 10, Color(0, 1, 0, 0.5))  # Xanh lá
