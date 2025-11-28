extends Node3D

@onready var ani = $AnimationPlayer2

func _ready() -> void:
	ani.play("idle")
