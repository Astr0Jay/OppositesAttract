extends CharacterBody2D
@export var speed : float = 100  # Horizontal movement speed
@export var gravity : float = 500  # Gravity strength (higher value = stronger gravity)
@export var jump_strength : float = 220  # How high the player can jump
@export var push_force : float = 80  # Force applied when moving objects
@export var pull_force : float = 12  # Force applied when pulling objects
@export var player_number : int = 2  # Which player this is (1 or 2)

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
	if Input.is_action_pressed("Dmove_right"):
		#print("Moving Right")
		input_direction.x += 1
	if Input.is_action_pressed("Dmove_left"):
		#print("Moving Left")
		input_direction.x -= 1
	
	# Apply horizontal speed based on input
	velocity.x = input_direction.x * speed
	
	# Apply gravity (constantly pulling the player down)
	if not is_on_floor():  # Only apply gravity if the player isn't on the floor
		velocity.y += gravity * delta  # Apply gravity
	
	# Jumping logic (if the player presses the jump key and is on the floor)
	if Input.is_action_pressed("Djump") and is_on_floor():
		velocity.y = -jump_strength  # Apply a negative velocity to make the player jump
	
	# Move the player with the calculated velocity
	move_and_slide()  # Use move_and_slide with no arguments
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
		
		# Check for spike collision during movement
		if c.get_collider().is_in_group("death"):
			die()
		
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
