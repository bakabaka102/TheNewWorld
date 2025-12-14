extends Node2D

@export var enemy_bee_scene: PackedScene
@export var max_enemy := 10

var current_enemy := 0
@export var spawn_delay := 3.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
