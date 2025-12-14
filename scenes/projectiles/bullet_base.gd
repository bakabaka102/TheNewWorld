extends Area2D

@export var speed := 300.0
var direction := Vector2.RIGHT

@export var damage := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# đảm bảo signal được connect
	body_entered.connect(_on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * speed * delta
	pass

func _on_body_entered(body: Node):
	if body.is_in_group("enemy"):
		print_debug("body.hit()")
		body.hit(damage)
		queue_free()   # 💥 huỷ đạn
		#explode()
		
