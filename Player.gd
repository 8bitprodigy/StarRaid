extends Spatial

var speed = 20 # Pretty fast -- this is about 100 mph
var pitch_add = 1
var roll_add = 1
var yaw_add = 0

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
