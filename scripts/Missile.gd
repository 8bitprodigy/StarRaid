extends KinematicBody

const SPEED = 2

var life = 10 # in seconds
var velocity: Vector3

# missile-specific
var target = null # Spatial node with a transform and a lock_on_target value

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
	elif target.lock_on_target != null:
		# instantly rotate towards location
		# Get updated target rotation
		var t = transform.looking_at(target.lock_on_target.get_node("Center").global_transform.origin, global_transform.basis.y)
		# Rotate towards destination
		rotation.x = lerp(rotation.x, t.basis.get_euler().x, delta * 5)
		rotation.y = lerp(rotation.y, t.basis.get_euler().y, delta * 5)
		
		# set new velocity: forward direction
		velocity = -transform.basis.z
		# fly towards location
		collision = move_and_collide(velocity * SPEED)
	else: target = null
	
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
