extends CharacterBody2D
@export var speed : float = 100  # Horizontal movement speed
@export var gravity : float = 500  # Gravity strength (higher value = stronger gravity)
@export var jump_strength : float = 220  # How high the player can jump
@export var push_force : float = 80  # Force applied when moving objects
@export var pull_force : float = 12  # Force applied when pulling objects
@export var player_number : int = 1  # Which player this is (1 or 2)

var pullable_object = null
var is_pulling = false

func _ready():
	# Create a detection area
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	
	shape.radius = 50  # Detection radius in pixels
	collision.shape = shape
	area.add_child(collision)
	add_child(area)
	
	# Connect signals
	area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
	area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	area.connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(delta):
	# Handle horizontal movement
	var input_direction = Vector2.ZERO  # Initialize the input direction
	if Input.is_action_pressed("Cmove_right"):
		#print("Moving Right")
		input_direction.x += 1
	if Input.is_action_pressed("Cmove_left"):
		#print("Moving Left")
		input_direction.x -= 1
	if Input.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
	
	# Apply horizontal speed based on input
	velocity.x = input_direction.x * speed
	
	# Apply gravity (constantly pulling the player down)
	if not is_on_floor():  # Only apply gravity if the player isn't on the floor
		velocity.y += gravity * delta  # Apply gravity
	
	# Jumping logic (if the player presses the jump key and is on the floor)
	if Input.is_action_pressed("Cjump") and is_on_floor():
		velocity.y = -jump_strength  # Apply a negative velocity to make the player jump
	
	# Move the player with the calculated velocity
	move_and_slide()  # Use move_and_slide with no arguments
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		# Check for spike collision during movement
		if c.get_collider().is_in_group("death"):
			die()
	
	# Handle pulling physics
	if is_pulling and pullable_object != null:
		# Calculate direction from object to player
		var pull_direction = global_position - pullable_object.global_position
		pull_direction = pull_direction.normalized()
		
		# Apply force to pull object toward player
		pullable_object.apply_central_impulse(pull_direction * pull_force * delta * 60)
		
		# Optional: If player is moving, add additional force in movement direction
		if input_direction.length() > 0:
			pullable_object.apply_central_impulse(input_direction * pull_force * 0.5 * delta * 60)

func _process(_delta):
	# Handle object interaction with a key press to toggle pulling
	if Input.is_action_just_pressed("Cinteract"):
		toggle_pull()

func toggle_pull():
	if pullable_object != null:
		is_pulling = !is_pulling
		print("Pulling toggled: ", is_pulling)
		
		# Optional: Visual feedback
		if is_pulling:
			# You could add a visual effect here to show the connection
			pass
		else:
			# Remove any visual connection effects
			pass

func _on_detection_area_body_entered(body):
	if body.is_in_group("pullable"):
		pullable_object = body
		print("Pullable object detected")

func _on_detection_area_body_exited(body):
	if body == pullable_object:
		pullable_object = null
		is_pulling = false
		print("Pullable object out of range")

		
# Add this new function to detect when the player enters an area
func _on_area_entered(area):
	if area.is_in_group("finish"):
		print("Player " + str(player_number) + " reached finish")
		# Tell the GameManager this player has reached the finish
		GameManager.player_reached_finish(player_number)

func die():
	#death_sound.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().reload_current_scene()
