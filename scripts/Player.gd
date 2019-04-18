extends Spatial

const MAX_SPEED = 100
const ENGINE_VOLUME = -10

var speed = 40 # currently in meters per second
var throttle = 50 # out of 100
var pitch_add = 1
var roll_add = 2
var yaw_add = 0.2

onready var projectile = preload("res://scenes/Bullet.tscn")
onready var gyroscope = get_node("cockpit/gimbal/gyroscope")

var fire_delay = 0 # Do not change this one
var next_is_right = true

#onready var natural_pos = $cockpit/yaw/Camera.global_transform.origin # don't change this one!
#onready var target_pos = natural_pos # change this for "where the camera should go"

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit() # temporary solution
	
	var cam_target_force = Vector3()
	
	if Input.is_action_pressed("speed_up"):
		#speed += 1
		set_throttle(speed + 1)
		cam_target_force.z = 1
	if Input.is_action_pressed("speed_down"):
		#speed -= 1
		set_throttle(speed - 1)
		cam_target_force.z = -1
	if Input.is_action_pressed("pitch_up"):
		rotate_object_local(Vector3(1,0,0), pitch_add * delta)
		gyroscope.rotate(Vector3(1,0,0), -pitch_add * delta)
	if Input.is_action_pressed("pitch_down"):
		rotate_object_local(Vector3(1,0,0), -pitch_add * delta)
		gyroscope.rotate(Vector3(1,0,0), pitch_add * delta)
	if Input.is_action_pressed("roll_right"):
		rotate_object_local(Vector3(0,0,1), -roll_add * delta)
		gyroscope.rotate(Vector3(0,0,1), roll_add * delta)
	if Input.is_action_pressed("roll_left"):
		rotate_object_local(Vector3(0,0,1), roll_add * delta)
		gyroscope.rotate(Vector3(0,0,1), -roll_add * delta)
	if Input.is_action_pressed("yaw_right"):
		rotate_object_local(Vector3(0,1,0), -yaw_add * delta)
		gyroscope.rotate(Vector3(0,1,0), yaw_add * delta)
	if Input.is_action_pressed("yaw_left"):
		rotate_object_local(Vector3(0,1,0), yaw_add * delta)
		gyroscope.rotate(Vector3(0,1,0), -yaw_add * delta)
	
	# Move
	translate_object_local(Vector3(0, 0, -speed * delta))
	
#	target_pos = natural_pos + cam_target_force
#	$cockpit/yaw/Camera.translation = lerp($cockpit/yaw/Camera.translation, target_pos, delta)
	
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
			$"..".add_child(bullet)
			bullet.velocity = -bullet.global_transform.basis.z;
			
			fire_delay = 0.05 # in seconds
		else:
			fire_delay -= delta
		
		if not $GunfireAudio.playing:
			$GunfireAudio.play()
	else:
		if $GunfireAudio.playing:
			$GunfireAudio.stop()
	
	# Update HUD
	$"cockpit/GUI/Speed".text = str(speed) + " m/s"
	# Get object
	var enemy = get_tree().get_nodes_in_group("enemy")[0]
	if not enemy.dead:
		var dot = (enemy.get_node("Center").global_transform.origin - $cockpit/yaw/Camera.global_transform.origin).normalized().dot(-$cockpit/yaw/Camera.global_transform.basis.z)
		if dot > 0:
			$cockpit/GUI.homing_reticle = $cockpit/yaw/Camera.unproject_position(enemy.get_node("Center").global_transform.origin)
	else:
		$cockpit/GUI.homing_reticle = null

func set_throttle(val):
	if val <= 100 and val >= 0:
		speed = val
		$cockpit/throttle.rotation_degrees.x = 60.0 + (-10.0 - 60.0) * (val / 100.0)
		# Volume of engine based on throttle TODO
		#var amt = ENGINE_VOLUME / max(speed / MAX_SPEED, .05)
		# min: -30
		# max: -20
		# dif = 10
#		var amt = 30 + 20 * (val / 100.0)
		#var amt = -20.0 + (-30.0 + 20.0) * (val / 100.0)
#		$CockpitAudio.volume_db = -amt


