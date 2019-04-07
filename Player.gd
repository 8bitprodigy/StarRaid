extends Spatial

var speed = 20 # Pretty fast -- this is about 100 mph
var pitch_add = 1
var roll_add = 1
var yaw_add = 0

onready var projectile = preload("res://Bullet.tscn")

var fire_delay = 0 # in seconds
var next_is_right = true

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("speed_up"):
		speed += 1
	if Input.is_action_pressed("speed_down"):
		speed -= 1
	if Input.is_action_pressed("pitch_up"):
		rotate_object_local(Vector3(1,0,0), pitch_add * delta)
	if Input.is_action_pressed("pitch_down"):
		rotate_object_local(Vector3(1,0,0), -pitch_add * delta)
	if Input.is_action_pressed("roll_right"):
		rotate_object_local(Vector3(0,0,1), -roll_add * delta)
	if Input.is_action_pressed("roll_left"):
		rotate_object_local(Vector3(0,0,1), roll_add * delta)
	
	# Move
	translate_object_local(Vector3(0, 0, -speed * delta))
	
	if Input.is_action_pressed("fire"):
		if fire_delay <= 0:
			var target
			if next_is_right:
				target = $Right.translation
			else:
				target = $Left.translation
			next_is_right = !next_is_right
		
			var bullet = projectile.instance()
			bullet.translation = to_global(target)
			bullet.rotation = rotation
			bullet.velocity = to_global(Vector3(0, 0, -1))

			$"..".add_child(bullet)
			
			fire_delay = 0.2 # .2 seconds // the default
		else:
			fire_delay -= delta
