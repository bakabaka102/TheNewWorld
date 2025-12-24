extends CharacterBody2D


var player

func _ready():
	#player = get_node("/root/HomeWasd/Player")
	player = get_tree().get_first_node_in_group("player")
	
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
