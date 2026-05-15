extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	await get_tree().process_frame
	
	if animation_player.has_animation("mixamo_com"):
		animation_player.play("mixamo_com")
