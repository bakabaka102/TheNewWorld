extends Node2D

@export var enemy_bee_scene: PackedScene
@export var max_enemy := 10

var current_enemy := 0
@export var spawn_delay := 3.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Physics/Movement/Input → _physics_process()
# Visuals/UI/Animation → _process()

#_physics_process(delta)
#Chạy với tốc độ cố định (mặc định 60 FPS)
#Được đồng bộ với physics engine
#delta luôn ổn định và có thể dự đoán được
#Thích hợp cho: vật lý, di chuyển nhân vật, va chạm, input xử lý
#
#_process(delta)
#Chạy mỗi frame (tốc độ thay đổi tùy FPS)
#delta thay đổi theo hiệu năng máy
#Không đồng bộ với physics
#Thích hợp cho: animation, UI, hiệu ứng visual, camera
func _process(_delta: float) -> void:
	pass


func _on_fire_button_pressed() -> void:
	$player.shoot()
	pass # Replace with function body.


func _on_fire_button_2_pressed() -> void:
	$player.shoot_base_bullet()

func _ready():
	randomize()
	spawn_loop()

func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_delay).timeout
		spawn_enemy()

func spawn_enemy():
	if current_enemy >= max_enemy:
		return
		
	var enemy = enemy_bee_scene.instantiate()
	# 🔥 RANDOM VỊ TRÍ TRONG MÀN HÌNH
	var screen_size = get_viewport_rect().size
	var x = randf_range(0, screen_size.x)
	var y = randf_range(0, screen_size.y * 0.6) # tránh UI dưới

	enemy.global_position = Vector2(x, y)

	enemy.tree_exited.connect(func(): current_enemy -= 1)
	current_enemy += 1
	add_child(enemy)
