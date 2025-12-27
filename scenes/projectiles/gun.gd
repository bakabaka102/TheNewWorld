extends Area2D

# References
@onready var shooting_point = %ShootingPoint

# Export variables (điều chỉnh trong Inspector)
@export var rotation_speed = 10.0        # Tốc độ xoay (rad/s)
@export var detection_radius = 600.0    # Bán kính phát hiện
@export var shoot_cooldown = 0.2        # Bắn mỗi 0.2s
@export var orbit_distance = 26.0       # Khoảng cách từ Player
@export var smooth_rotation = true     # Xoay mượt hay tức thì

# Biến nội bộ
var current_target: Node2D = null
var shoot_timer = 0.0

const BULLET: Resource = preload("res://scenes/projectiles/fire_bullet.tscn")

func _ready() -> void:
	# Đặt súng cách Player một khoảng
	position = Vector2(orbit_distance, 0)
	
	# Tự động set collision radius = detection_radius
	sync_collision_radius()
	
	print("   Fire rate: ", 1.0 / shoot_cooldown, " shots/second")

# Tự động đồng bộ CollisionShape2D radius với detection_radius
func sync_collision_radius() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			var collision_shape = child as CollisionShape2D
			
			if collision_shape.shape is CircleShape2D:
				var circle = collision_shape.shape as CircleShape2D
				circle.radius = detection_radius
				print("   ✅ Set CollisionShape2D radius to: ", detection_radius)
				return
	
	push_warning("⚠️ CollisionShape2D with CircleShape2D not found!")

func _process(_delta: float) -> void:
	queue_redraw()  # Cập nhật vẽ mỗi frame

func _physics_process(delta: float) -> void:
	# PHẦN 1: BẮN LIÊN TỤC (không quan tâm enemy)
	shoot_timer += delta
	
	if shoot_timer >= shoot_cooldown:
		shoot()  # Bắn bất kể có enemy hay không
		shoot_timer = 0.0

	# PHẦN 2: XOAY THEO ENEMY (nếu có)
	var enemies_in_range = get_overlapping_bodies()
	enemies_in_range = enemies_in_range.filter(func(body):
		return body.is_in_group("enemy")
	)

	if enemies_in_range.size() > 0:
		#var target_enemy = enemies_in_range.front()
		#look_at(target_enemy.global_position)
		# Có enemy → Xoay về enemy
		current_target = get_nearest_enemy(enemies_in_range)
		if current_target and is_instance_valid(current_target):
			rotate_towards_target(current_target, delta)
	else:
		# Không có enemy → Giữ nguyên hướng (hoặc xoay về mặc định)
		current_target = null

	# Cập nhật vị trí orbit LUÔN LUÔN
	update_orbit_position()

# Cập nhật vị trí súng quanh Player
func update_orbit_position() -> void:
	var offset = Vector2(orbit_distance, 0).rotated(rotation)
	position = offset

# Bắn đạn (KHÔNG cần kiểm tra enemy)
func shoot() -> void:
	if not shooting_point:
		push_warning("⚠️ ShootingPoint not found!")
		return

	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shooting_point.global_position
	new_bullet.global_rotation = shooting_point.global_rotation

	get_tree().current_scene.add_child(new_bullet)

# Xoay súng hướng về mục tiêu
func rotate_towards_target(target: Node2D, delta: float) -> void:
	var player_pos = get_parent().global_position if get_parent() else global_position
	var target_angle = player_pos.angle_to_point(target.global_position)
	
	if smooth_rotation:
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	else:
		rotation = target_angle  # Xoay tức thì

# Tìm enemy gần nhất
func get_nearest_enemy(enemies: Array) -> Node2D:
	if enemies.is_empty():
		return null
	
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
	# Vẽ orbit (quỹ đạo xoay)
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
