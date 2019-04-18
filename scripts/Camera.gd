extends Camera

const SENSITIVITY = 0.25
const ZOOM_FOV = 35
onready var DEFAULT_FOV = fov
var yaw = 0
var pitch = 0

func _ready():
	set_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_pressed("zoom"): # right mouse = zoom in
		fov = lerp(fov, ZOOM_FOV, delta * 10)
	else:
		if fov != DEFAULT_FOV:
			fov = lerp(fov, DEFAULT_FOV, delta * 10)

func _input(event):
	if event is InputEventMouseMotion:
		yaw = max(min(yaw - event.relative.x * SENSITIVITY, 80), -80)
		pitch = max(min(pitch - event.relative.y * SENSITIVITY, 85), -85)
		$"..".set_rotation(Vector3(0, deg2rad(yaw), 0))
		set_rotation(Vector3(deg2rad(pitch), 0, 0))

func shake(length, magnitude):
	var time = 0
	var camera_pos = translation
	while time < length:
		time += get_process_delta_time()
		
		var offset = Vector3()
		offset.x = rand_range(-magnitude, magnitude)
		offset.y = rand_range(-magnitude, magnitude)
		offset.z = 0
		
		var new_camera_pos = camera_pos
		new_camera_pos += offset
		translation = new_camera_pos
		
		yield(get_tree(), "idle_frame")
	translation = camera_pos
