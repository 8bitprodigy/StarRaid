extends KinematicBody

const SPEED = 15

var dead = false
var health = 100
var velocity = Vector3(-1, 0, 0) * SPEED

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	move_and_slide(velocity)

func hit(damage):
	if not dead:
		health -= damage
		if health <= 0:
			# Change texture to "destroyed"
			# Emit particles
			$SmokeParticles.emitting = true
			# Stop moving
			#velocity = Vector3()
			set_physics_process(false)
#			queue_free()
			print("Truck destroyed!")
			dead = true
