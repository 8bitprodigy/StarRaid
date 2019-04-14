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
