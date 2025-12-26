extends Area2D

# References
@onready var shooting_point = %ShootingPoint
# Timer node không cần nữa - dùng manual timer

# Export variables (điều chỉnh trong Inspector)
@export var rotation_speed = 10.0        # Tốc độ xoay (rad/s)
@export var detection_radius = 800.0    # Bán kính phát hiện
@export var shoot_cooldown = 0.05       # FIXED: Bắn mỗi 0.05s (20 phát/giây)
@export var orbit_distance = 50.0       # FIX 1: Khoảng cách từ Player

# Biến nội bộ
var current_target: Node2D = null
var can_shoot = true
var shoot_timer = 0.0  # FIXED: Dùng biến timer thay vì Timer node

const BULLET: Resource = preload("res://scenes/projectiles/fire_bullet.tscn")

func _ready() -> void:
	# Đặt súng cách Player một khoảng
	position = Vector2(orbit_distance, 0)
	
	print("🔫 Turret ready!")
	print("   Fire rate: ", 1.0 / shoot_cooldown, " shots/second")
	print("   Detection radius: ", detection_radius)

func _process(_delta: float) -> void:
	queue_redraw()  # Cập nhật vẽ mỗi frame

func _physics_process(delta: float) -> void:
	# FIXED: Cập nhật timer thủ công
	shoot_timer += delta
	
	# Lấy danh sách enemy trong vùng
	var enemies_in_range = get_overlapping_bodies()
	
	# FIXED: Dùng "enemy" (số ít) như code gốc của bạn
	enemies_in_range = enemies_in_range.filter(func(body):
		return body.is_in_group("enemy")
	)
	
	if enemies_in_range.size() > 0:
		# Tìm enemy gần nhất
		current_target = get_nearest_enemy(enemies_in_range)
		
		if current_target and is_instance_valid(current_target):
			# Xoay súng hướng về enemy
			rotate_towards_target(current_target, delta)
			
			# Cập nhật vị trí súng quanh Player
			update_orbit_position()
			
			## FIXED: Bắn khi đủ thời gian cooldown
			if shoot_timer >= shoot_cooldown:
				shoot()
				shoot_timer = 0.0  # Reset timer
	else:
		# Không có enemy, reset target
		current_target = null

# FIX 5: Hàm mới - Cập nhật vị trí súng quanh Player
func update_orbit_position() -> void:
	# Đặt súng ở khoảng cách cố định từ Player theo hướng rotation
	var offset = Vector2(orbit_distance, 0).rotated(rotation)
	position = offset

# FIX 6: Sửa lại hàm shoot() - Loại bỏ code trùng lặp
func shoot() -> void:
	# Kiểm tra target hợp lệ
	if not current_target or not is_instance_valid(current_target):
		return
	
	# Kiểm tra shooting point
	if not shooting_point:
		push_warning("⚠️ ShootingPoint not found!")
		return
	
	# Tạo đạn
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shooting_point.global_position
	new_bullet.global_rotation = shooting_point.global_rotation
	
	# FIX 7: Add vào scene chính (KHÔNG add vào shooting_point)
	get_tree().current_scene.add_child(new_bullet)
	
	print("💥 Turret fired at ", current_target.name)

# Xoay súng hướng về mục tiêu
func rotate_towards_target(target: Node2D, delta: float) -> void:
	# FIX 9: Tính góc từ Player đến Enemy (không phải từ Gun)
	var player_pos = get_parent().global_position if get_parent() else global_position
	var target_angle = player_pos.angle_to_point(target.global_position)
	
	# Xoay mượt từ góc hiện tại đến góc mục tiêu
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	# other way
	# rotation = rotate_toward(rotation, target_angle, rotation_speed * delta)

# Tìm enemy gần nhất
func get_nearest_enemy(enemies: Array) -> Node2D:
	if enemies.is_empty():
		return null
	
	# FIX 10: Tính khoảng cách từ Player (không phải từ Gun)
	var player_pos = get_parent().global_position if get_parent() else global_position
	var nearest_enemy: Node2D = null
	var nearest_distance = INF
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = player_pos.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	
	return nearest_enemy

# Debug - Vẽ vùng phát hiện
func _draw() -> void:
	# FIX 11: Vẽ thêm orbit (quỹ đạo xoay)
	if get_parent():
		var parent_pos = to_local(get_parent().global_position)
		draw_arc(parent_pos, orbit_distance, 0, TAU, 32, Color(0, 1, 1, 0.3), 2.0)
	
	# Vẽ hình tròn phát hiện (màu xanh dương trong suốt)
	draw_circle(Vector2.ZERO, detection_radius, Color(0.231, 0.574, 0.747, 0.1))
	
	# Vẽ đường viền
	draw_arc(Vector2.ZERO, detection_radius, 0, TAU, 32, Color(0.107, 0.569, 0.827, 0.3), 2.0)
	
	# Vẽ đường ngắm (màu xanh lá)
	if current_target and is_instance_valid(current_target):
		var target_local = to_local(current_target.global_position)
		draw_line(Vector2.ZERO, target_local.normalized() * 50, Color.GREEN, 2.0)
