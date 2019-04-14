extends Spatial

const MAX_SPEED = 100
const ENGINE_VOLUME = -10

var speed = 40 # currently in meters per second
var throttle = 50 # out of 100
var pitch_add = 1
var roll_add = 2
var yaw_add = 0.2

onready var projectile = preload("res://scenes/Bullet.tscn")

var fire_delay = 0 # Do not change this one
var next_is_right = true

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit() # temporary solution
	
	if Input.is_action_pressed("speed_up"):
		#speed += 1
		set_throttle(speed + 1)
	if Input.is_action_pressed("speed_down"):
		#speed -= 1
		set_throttle(speed - 1)
	if Input.is_action_pressed("pitch_up"):
		rotate_object_local(Vector3(1,0,0), pitch_add * delta)
	if Input.is_action_pressed("pitch_down"):
		rotate_object_local(Vector3(1,0,0), -pitch_add * delta)
	if Input.is_action_pressed("roll_right"):
		rotate_object_local(Vector3(0,0,1), -roll_add * delta)
	if Input.is_action_pressed("roll_left"):
		rotate_object_local(Vector3(0,0,1), roll_add * delta)
	if Input.is_action_pressed("yaw_right"):
		rotate_object_local(Vector3(0,1,0), -yaw_add * delta)
	if Input.is_action_pressed("yaw_left"):
		rotate_object_local(Vector3(0,1,0), yaw_add * delta)
	
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
	$"cockpit/HUD/GUI/Speed".text = str(speed) + "m/s"

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


