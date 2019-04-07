extends KinematicBody

var life = 10 # in seconds
var velocity = Vector3(0, 0, -1)

func _ready():
	set_process(true)
	set_physics_process(true)

func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()

func _physics_process(delta):
	#translate_object_local(velocity * delta)
	var collision = move_and_collide(velocity)
