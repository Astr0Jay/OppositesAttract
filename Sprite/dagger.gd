extends Node2D

@export var speed : float = 200  # Movement speed of the player

# Reference to the sprite
var sprite : AnimatedSprite2D

func _ready():
	sprite = $DagSprite  # Getting the reference to the Sprite2D node

func _process(delta):
	var velocity = Vector2.ZERO  # Initialize the movement vector

	# Input handling for player movement
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	# Normalize the velocity vector to prevent faster diagonal movement
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# Move the player
	position += velocity * delta  # Update position based on velocity
