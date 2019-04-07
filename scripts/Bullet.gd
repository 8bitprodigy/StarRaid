extends KinematicBody

var life = 5 # in seconds
var velocity = Vector3(0, 0, 0)
const SPEED = 10

func _ready():
	set_process(true)
	set_physics_process(true)

func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()

func _physics_process(delta):
	var collision = move_and_collide(velocity * SPEED)
