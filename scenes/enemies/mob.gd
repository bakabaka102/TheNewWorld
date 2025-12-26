extends CharacterBody2D

@onready var slime = $Slime
@onready var player = get_tree().get_first_node_in_group("player")
@export var hp := 1.0


func _ready():
	add_to_group("enemy")
	slime.play_walk()
	#player = get_node("/root/HomeWasd/Player")
	
	
	if player:
		print("✅ Enemy tìm thấy player!")
	else:
		print("❌ KHÔNG tìm thấy player! Hãy thêm player vào group 'player'")

func _physics_process(_delta: float) -> void:
	# Kiểm tra player có tồn tại không
	if player == null:
		return  # Dừng lại nếu không có player
	
	# Kiểm tra player có bị xóa chưa
	if not is_instance_valid(player):
		player = null
		return
	
	# Bây giờ mới an toàn sử dụng player
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300
	move_and_slide()
	
func take_dame(damage: float):
	hp -= damage
	if hp <= 0.0:
		die()

func die():
	queue_free()
