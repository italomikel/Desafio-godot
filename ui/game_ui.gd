extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var gold_label: Label = %GoldLabel
@onready var meat_label: Label = %MeatLabel




#func _ready():
	
	#GameManager.player.meat_collected.connect(on_meat_collected)
	
func _process(delta: float):
	timer_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.meat_counter)
	
#func on_meat_collected(regeneration_value: int):
	#meat_counter += 1
	#meat_label.text = str(meat_counter)
