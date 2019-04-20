extends KinematicBody

const SPEED = 2

var life = 10 # in seconds
var velocity: Vector3

# missile-specific
var target = null # Spatial node with a transform

func _ready():
	set_process(true)
	set_physics_process(true)

func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()

func _physics_process(delta):
	var collision = null
	if target == null:
		collision = move_and_collide(velocity * SPEED)
	else: # lerp the velocity ?
		#print(str(target.global_transform.origin))
		# instantly rotate towards location
		look_at(target.get_node("Center").global_transform.origin, global_transform.basis.y)
		# set new velocity: forward direction
		velocity = -transform.basis.z
		# fly towards location
		collision = move_and_collide(velocity * SPEED)
	
	if collision != null:
		# send "hit by this bullet" message to receiver
		if collision.collider.is_in_group("enemy"):
			collision.collider.hit(50)
		# produce effect
		# consider ricocheting
#		if rad2deg(velocity.angle_to(collision.normal)) < 100:
#			velocity = velocity.bounce(collision.normal) / 2
#			# update rotation
#			# look_at(velocity, Vector3(0, 1, 0)) TODO: make this work
#		else:
#			queue_free()
		queue_free()
		print("Bullet traveled")
