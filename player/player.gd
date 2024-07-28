class_name Player
extends CharacterBody2D
@export_category("Movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage: int = 2
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progess_bar:ProgressBar = $HealthProgessBar

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking:bool = false
var attack_coooldown:float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

signal meat_collected(value: int)


func _ready():
	GameManager.player = self
	meat_collected.connect(func(value: int): GameManager.meat_counter += 1)

func _process(delta: float):
	GameManager.player_position = position
	read_input()
	#Processar ataque
	attack_update_cooldown(delta)
	# sistema de attack
	if Input.is_action_just_pressed("attack"):
		attack()	
		
	# Processar animação e rotação do sprite
	play_run_idel_animation()
	if not is_attacking:
		rotate_sprite()
		
	# Processar dano
	update_damage_hitbox_detection(delta)
	
	# ritual
	update_ritual(delta)
	
	# Atualizar barra de vida
	health_progess_bar.max_value = max_health
	health_progess_bar.value = health
		
func _physics_process(delta: float):
	# Modificar a velocidade
	var targuet_velocity = input_vector * speed * 100.0
	if is_attacking:
		targuet_velocity *= 0.25
	velocity = lerp(velocity, targuet_velocity, 0.05)
	move_and_slide()
	
func read_input():
	# Obter o imput vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Atualizar o is running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()
	
func rotate_sprite():
	# Girar isprite
	if input_vector.x > 0:
		sprite.flip_h = false
		# desmarcar flip H do sprit2D	
	elif input_vector.x < 0:
		sprite.flip_h = true
		# marcar flip_h do sprite2D
		
func attack():
	if is_attacking:
		return
	# attack side 1
	# attack side 2
	#trocar animação
	animation_player.play("attack_side_1")
	# Configurar o temporizador
	attack_coooldown = 0.6
	
	#maracar ataque
	is_attacking = true
	
	# Aplicar dano aos inimigos
	
	
func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direciton_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product = direciton_to_enemy.dot(attack_direction)
			if dot_product >= 0.4:
				enemy.damage(sword_damage)
			
			enemy.damage(sword_damage)
			
	#var enemies = get_tree().get_nodes_in_group("enemies")
	#for enemy in enemies:
		#enemy.damage(sword_damage)
	

func attack_update_cooldown(delta: float):
	# Atualozar o temporizador do ataque
	if attack_coooldown > 0:
		attack_coooldown -= delta #0.6 - 0.016
		if attack_coooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func play_run_idel_animation():
# tocar a animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func damage(amount: int):
	if health <= 0: return
	
	health -= amount
	print("Player recebeu dano de ", amount, "A vida total é de ", health)
	
	# Piscar node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	# Processar morte
	if health <= 0:
		die()

func die():
	GameManager.and_game()

	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	queue_free()
	print("Player morreu")
	
func heal(amount: int):
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount, "A vida total é de ", health)
	
	return health
		
func update_damage_hitbox_detection(delta: float):
	
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	
	# Frequencia (2x por segundo)
	hitbox_cooldown = 0.5
	
	
	#detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func update_ritual(delta: float):
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	
	# criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	
	
	
