class_name hit_box extends Area2D

@export var dmg_amount : int = 1

func _ready() -> void:
	area_entered.connect(areaEntered)

func areaEntered(area: Area2D) -> void:
	if area is hurt_box:
		area.take_dmg(dmg_amount)
