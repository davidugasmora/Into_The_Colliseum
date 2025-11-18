class_name hurt_box extends Area2D

signal damaged(dmg_amount : int)

func take_dmg(dmg_amount : int) -> void: 
	
	print("TakeDamage: ", dmg_amount)
	damaged.emit(dmg_amount)
