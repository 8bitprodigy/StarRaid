extends Spatial

const MAX_SPEED = 100
const ENGINE_VOLUME = -10

var speed = 40 # currently in meters per second
var throttle = 50 # out of 100
var pitch_add = 1
var roll_add = 2
var yaw_add = 0.2

onready var bullet = preload("res://scenes/Bullet.tscn")
onready var missile = preload("res://scenes/Missile.tscn")
onready var gyroscope = get_node("cockpit/gimbal/gyroscope")

var cannon_delay = 0 # Do not change this one
var missile_delay = 0
var next_is_right = true
var gun = 0 # 0 - 2 is cannon, air-to-surface missile, air-to-air missile
var lock_on_timer = 0
var lock_on_target = null # whoever we are fully locked-onto

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
	
	if Input.is_action_just_pressed("change_gun"):
		if gun < 2: gun += 1
		else: gun = 0
		# Update reticle:
		if gun == 0: # Only draw reticle with cannon
			$cockpit/GUI.draw_reticle = true
		else: $cockpit/GUI.draw_reticle = false
	
	# Update "cooldowns" / delays
	if cannon_delay > 0: cannon_delay -= delta
	if missile_delay > 0: missile_delay -= delta
	
	if Input.is_action_pressed("fire"):
		if gun != 0:
			if missile_delay <= 0:
				var target
				if next_is_right:
					target = $Right.translation
				else:
					target = $Left.translation
				next_is_right = !next_is_right
				
				var m = missile.instance()
				m.translation = to_global(target)
				m.rotation = rotation
				m.velocity = -transform.basis.z
				
				# get target (ACTUALLY NO WAIT REVERSE THIS PROCESS: have the missile request our lockon target)
				m.target = self
				
				$"..".add_child(m)
	
				missile_delay = 0.5 # in seconds
		else:
			if cannon_delay <= 0:
				var b = bullet.instance()
				b.translation = to_global($Rotary.translation)
				b.rotation = rotation
				b.velocity = -transform.basis.z
				$"..".add_child(b)
				
				cannon_delay = 0.05 # in seconds
		
		if not $GunfireAudio.playing:
			$GunfireAudio.play()
	else:
		if $GunfireAudio.playing:
			$GunfireAudio.stop()
	
	# Update HUD
	$"cockpit/GUI/Indicator".text = str(speed / 2) + " m/s\n" + \
		gun_name(gun)
	
	# Get object
	# eventually, you will have to check that the currently homing enemy is the same as last frame for lock-on
	var enemy = null
	for e in get_tree().get_nodes_in_group("enemy"): # get the closest enemy
		# if we are looking in the direction of the enemy vehicle
		if not e.dead and (e.get_node("Center").global_transform.origin - $cockpit/yaw/Camera.global_transform.origin).normalized().dot(-$cockpit/yaw/Camera.global_transform.basis.z) > 0:
			# if no selected enemy OR select nearest enemy
			if enemy == null or e.global_transform.basis.distance_to(global_transform.basis) < enemy.global_transform.basis.distance_to(global_transform.basis):
				enemy = e
	
	if enemy == null:
		$cockpit/GUI.actively_locking_on = false
		$cockpit/GUI.homing_reticle = null # no target found
		lock_on_timer = 0
	else: # enemy found
		$cockpit/GUI.actively_locking_on = true
		
		# Set close-up camera position to in front of enemy
		$cockpit/Viewport/Camera.global_transform.origin = Vector3(-10, 5, 0) + enemy.global_transform.origin + enemy.global_transform.basis.x
		$cockpit/Viewport/Camera.set_global_transform($cockpit/Viewport/Camera.global_transform.looking_at(enemy.global_transform.origin, $cockpit/Viewport/Camera.global_transform.basis.y))
		
		if lock_on_timer < 3 and (enemy.get_node("Center").global_transform.origin - $cockpit/yaw/Camera.global_transform.origin).normalized().dot(-$cockpit/yaw/Camera.global_transform.basis.z) > 0:
			$"cockpit/GUI/".fully_locked = false
			# cheap blinking outline effect
			if int(lock_on_timer) % 2 != 0: $cockpit/GUI.homing_reticle = null # turn off reticle for odd numbers
			else: $cockpit/GUI.homing_reticle = $cockpit/yaw/Camera.unproject_position(enemy.get_node("Center").global_transform.origin)
			# make sure "beep beep beep ..." audio is playing
			lock_on_timer += delta
			pass
		else: # locked on
			lock_on_target = enemy
			# update HUD
			$"cockpit/GUI/".fully_locked = true
			# make sure "beeeeeeeeep..." audio is playing
			# "locked in" reticle around target
			$cockpit/GUI.homing_reticle = $cockpit/yaw/Camera.unproject_position(enemy.get_node("Center").global_transform.origin)

func gun_name(g):
	match g:
		0: return "CANNON"
		1: return "ASM"
		2: return "AAM"

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


