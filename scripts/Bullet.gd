extends KinematicBody

const SPEED = 3

var life = 5 # in seconds
var velocity: Vector3

func _ready():
	set_process(true)
	set_physics_process(true)

func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()

func _physics_process(delta):
	var collision = move_and_collide(velocity * SPEED)
	if collision != null:
		# send "hit by this bullet" message to receiver
		# produce effect
		# consider ricocheting
		if rad2deg(velocity.angle_to(collision.normal)) < 100:
			velocity = velocity.bounce(collision.normal) / 2
			# update rotation
			# look_at(velocity, Vector3(0, 1, 0)) TODO: make this work
		print("Bullet traveled")
