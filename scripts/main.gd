extends Node2D

const WORLD_HALF = Vector2(1000, 1000)
const STAR_COUNT = 10
const INITIAL_TREE_COUNT = 20
const MAX_TREES = 40
const QUEEN_SPEED = 200.0
const COLLECT_RANGE = 70.0
const WOOD_PER_STAGE = 5
const TOTAL_STAGES = 5
const FIRST_PALACE_POS = Vector2(-400, 200)
const PALACE_SPACING = Vector2(170, 0)
const PALACE_RANGE = 90.0
const TREE_GROW_RATE = 0.08
const SAPLING_SPAWN_INTERVAL = 4.0

const INITIAL_BERRY_COUNT = 6
const MAX_BERRIES = 15
const BERRY_GROW_RATE = 0.05
const BERRY_SPAWN_INTERVAL = 18.0
const BERRY_COLLECT_RANGE = 65.0

const ENERGY_START = 10.0
const ENERGY_MIN = 1.0
const ENERGY_DECAY = 0.014

const JOYSTICK_RADIUS = 75.0
const STICK_RADIUS = 32.0
const COLLECT_BTN_CENTER = Vector2(255, 370)
const COLLECT_BTN_RADIUS = 38.0
const BUILD_BTN_CENTER = Vector2(120, 370)
const BUILD_BTN_RADIUS = 38.0
const BERRY_BTN_CENTER = Vector2(255, 460)
const BERRY_BTN_RADIUS = 38.0

# Palace interior (at a separate world location, off the normal map)
const INTERIOR_ORIGIN = Vector2(0.0, -3500.0)
const ROOM_W = 370.0
const ROOM_H = 580.0
const WALL_T = 20.0
const DOOR_H = 90.0
const EXIT_W = 55.0
const PALACE_ENTER_DIST = 30.0
const SERVANT_SPEED = 42.0

const INITIAL_MUSHROOM_COUNT = 8
const MAX_MUSHROOMS = 15
const MUSHROOM_GROW_RATE = 0.04
const MUSHROOM_SPAWN_INTERVAL = 15.0
const MUSHROOM_COLLECT_RANGE = 60.0
const COOK_TIME = 25.0
const STOVE_POS = Vector2(135.0, -3395.0)
const SERVING_TABLE_POS = Vector2(93.0, -3324.0)
const SERVANT_IDLE_POS = Vector2(68.0, -3330.0)
const KITCHEN_INTERACT_POS = Vector2(88.0, -3355.0)
const KITCHEN_INTERACT_RANGE = 95.0
const MUSHROOM_BTN_CENTER = Vector2(120.0, 460.0)
const MUSHROOM_BTN_RADIUS = 38.0
const KITCHEN_BTN_CENTER = Vector2(195.0, 430.0)
const KITCHEN_BTN_RADIUS = 38.0
const FURNISH_BTN_CENTER = Vector2(255.0, 370.0)
const FURNISH_BTN_RADIUS = 38.0

const NPC_POS = Vector2(420.0, -300.0)
const FLOWER_POS = Vector2(-550.0, 380.0)
const NPC_TALK_RANGE = 80.0
const FLOWER_PICK_RANGE = 55.0
const QUEST_REWARD_WOOD = 10
const ROOM_NAMES = ["Thronsaal", "Bibliothek", "Galerie", "Königskammer"]
const ROOM_0_ITEMS = [
	{id = "throne",    label = "Thron",          wood = 10},
	{id = "rug",       label = "Zierteppich",    wood = 3},
	{id = "candle",    label = "Kerzenständer",  wood = 4},
	{id = "tapestry",  label = "Wandteppich",    wood = 5},
	{id = "bookshelf", label = "Bücherregal",    wood = 6},
]
const ROOM_1_ITEMS = [
	{id = "chair",    label = "Lesesessel",       wood = 6},
	{id = "desk",     label = "Schreibtisch",     wood = 8},
	{id = "gclock",   label = "Standuhr",         wood = 10},
	{id = "painting", label = "Gemälde",          wood = 8},
	{id = "globe",    label = "Globus",           wood = 6},
]
const ROOM_2_ITEMS = [
	{id = "mirror",    label = "Großer Spiegel", wood = 8},
	{id = "vase",      label = "Hohe Vase",      wood = 6},
	{id = "curtains",  label = "Vorhänge",       wood = 8},
	{id = "statue",    label = "Statue",         wood = 12},
	{id = "sidetable", label = "Beistelltisch",  wood = 5},
]
const ROOM_3_ITEMS = [
	{id = "bed",       label = "Himmelbett",     wood = 15},
	{id = "wardrobe",  label = "Kleiderschrank", wood = 10},
	{id = "vanity",    label = "Schminktisch",   wood = 8},
	{id = "fireplace", label = "Kamin",          wood = 12},
	{id = "trophy",    label = "Trophäenschrank",wood = 10},
]

var queen: CharacterBody2D
var stars_collected := 0
var tree_inventory := 0
var palaces_completed := 0

var ui_label: Label
var tree_label: Label
var palace_label: Label
var energy_label: Label
var energy_bar_fill: ColorRect
var collect_button: Node2D
var build_button: Node2D
var berry_button: Node2D
var game_over := false

var energy := ENERGY_START

# Each entry: {node: Node2D, growth: float}
var trees: Array = []
var nearest_tree_data = null

# Each entry: {node: Node2D, growth: float}
var berries: Array = []
var nearest_berry_data = null
var berry_timer := 0.0

# Each entry: {pos: Vector2, stage: int, node: Node2D}
var palaces: Array = []
var active_palace_idx := -1

var sapling_timer := 0.0

var in_palace := false
var palace_num_rooms := 0
var palace_interior_node: Node2D = null
var queen_world_pos := Vector2.ZERO

var servant_node: Node2D = null
var servant_target := Vector2.ZERO
var servant_wait := 0.0
var servant_cook_t := 0.0

# Each entry: {node: Node2D, growth: float}
var mushrooms: Array = []
var nearest_mushroom_data = null
var mushroom_timer := 0.0
var carrying_mushroom := false
var mushroom_carried_node: Node2D = null

var kitchen_state := "idle"
var cook_timer := 0.0
var food_ready_node: Node2D = null
var near_kitchen := false

var mushroom_button: Node2D
var give_button: Node2D
var eat_button: Node2D
var furnish_button: Node2D
var furnish_menu_open := false
var furnish_menu_layer: CanvasLayer = null
var exit_palace_idx := 0

# Quest: flower delivery
var quest_state := "waiting"  # "waiting" | "carrying" | "done"
var quest_npc_node: Node2D = null
var quest_flower_node: Node2D = null
var quest_dialog_layer: CanvasLayer = null
var quest_near_npc := false
var quest_near_flower := false
var quest_carried_flower_node: Node2D = null

var joystick_touch_id := -1
var joystick_origin := Vector2.ZERO
var joystick_base: Polygon2D
var joystick_stick: Polygon2D
var touch_direction := Vector2.ZERO


func _ready() -> void:
	_create_background()

	# Start with two completed palaces
	_spawn_palace(FIRST_PALACE_POS)
	palaces[0].stage = TOTAL_STAGES
	_rebuild_palace(palaces[0])
	palaces_completed = 1

	var second_pos: Vector2 = FIRST_PALACE_POS + PALACE_SPACING
	_spawn_palace(second_pos)
	palaces[1].stage = TOTAL_STAGES
	_rebuild_palace(palaces[1])
	palaces_completed = 2

	# Third palace is the one to build next
	_spawn_palace(second_pos + PALACE_SPACING)

	_create_queen()
	_create_stars()
	_create_initial_trees()
	_create_initial_berries()
	_create_initial_mushrooms()
	_create_quest()
	_create_ui()
	_create_joystick()


# ── Background ────────────────────────────────────────────────────────────────

func _create_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.18, 0.45, 0.18)
	bg.size = WORLD_HALF * 2
	bg.position = -WORLD_HALF
	add_child(bg)

	for i in range(60):
		var patch := ColorRect.new()
		patch.color = Color(0.13, 0.35, 0.13)
		patch.size = Vector2(randf_range(30, 90), randf_range(30, 90))
		patch.position = Vector2(
			randf_range(-WORLD_HALF.x, WORLD_HALF.x),
			randf_range(-WORLD_HALF.y, WORLD_HALF.y)
		)
		add_child(patch)


# ── Queen ─────────────────────────────────────────────────────────────────────

func _create_queen() -> void:
	queen = CharacterBody2D.new()
	queen.position = Vector2.ZERO

	var body := ColorRect.new()
	body.color = Color(0.55, 0.08, 0.75)
	body.size = Vector2(32, 32)
	body.position = Vector2(-16, -16)
	queen.add_child(body)

	var crown := ColorRect.new()
	crown.color = Color(1.0, 0.85, 0.0)
	crown.size = Vector2(24, 8)
	crown.position = Vector2(-12, -24)
	queen.add_child(crown)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	col.shape = shape
	queen.add_child(col)

	var cam := Camera2D.new()
	cam.make_current()
	queen.add_child(cam)

	queen.z_index = 10
	add_child(queen)


# ── Stars ─────────────────────────────────────────────────────────────────────

func _create_stars() -> void:
	for i in range(STAR_COUNT):
		var star := _make_star()
		star.position = _random_world_pos(120)
		add_child(star)


func _make_star() -> Area2D:
	var star := Area2D.new()

	var poly := Polygon2D.new()
	poly.color = Color(1.0, 0.9, 0.1)
	poly.polygon = _star_polygon(14)
	star.add_child(poly)

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 14
	col.shape = shape
	star.add_child(col)

	star.body_entered.connect(_on_star_collected.bind(star))
	return star


func _star_polygon(r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(10):
		var angle := (PI * i / 5.0) - PI / 2.0
		var radius := r if i % 2 == 0 else r * 0.4
		pts.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	return pts


func _on_star_collected(body: Node2D, star: Area2D) -> void:
	if body != queen:
		return
	star.queue_free()
	stars_collected += 1
	_update_ui()
	if stars_collected >= STAR_COUNT:
		_show_overlay("Gewonnen!\nAlle Sterne gesammelt!")
		game_over = true


# ── Trees ─────────────────────────────────────────────────────────────────────

func _create_initial_trees() -> void:
	for i in range(INITIAL_TREE_COUNT):
		_spawn_tree(_random_world_pos(150), 1.0)


func _spawn_tree(pos: Vector2, growth: float) -> void:
	var node := _make_tree_node()
	node.position = pos
	add_child(node)
	var data := {node = node, growth = growth}
	trees.append(data)
	_apply_tree_scale(data)


func _make_tree_node() -> Node2D:
	var tree := Node2D.new()

	var trunk := ColorRect.new()
	trunk.color = Color(0.45, 0.28, 0.1)
	trunk.size = Vector2(10, 14)
	trunk.position = Vector2(-5, 4)
	tree.add_child(trunk)

	var canopy := Polygon2D.new()
	canopy.color = Color(0.1, 0.6, 0.1)
	canopy.polygon = PackedVector2Array([
		Vector2(0, -22), Vector2(-14, 4), Vector2(14, 4)
	])
	tree.add_child(canopy)

	return tree


func _apply_tree_scale(data: Dictionary) -> void:
	var s: float = lerp(0.25, 1.0, clampf(data.growth, 0.0, 1.0))
	data.node.scale = Vector2(s, s)
	var canopy := data.node.get_child(1) as Polygon2D
	if canopy:
		canopy.color = Color(0.25, 0.72, 0.25) if data.growth < 1.0 else Color(0.1, 0.6, 0.1)


func _grow_trees(delta: float) -> void:
	for data in trees:
		if data.growth >= 1.0:
			continue
		data.growth = minf(data.growth + TREE_GROW_RATE * delta, 1.0)
		_apply_tree_scale(data)


func _maybe_spawn_sapling(delta: float) -> void:
	sapling_timer -= delta
	if sapling_timer > 0.0 or trees.size() >= MAX_TREES:
		return
	sapling_timer = SAPLING_SPAWN_INTERVAL
	_spawn_tree(_random_world_pos(100), 0.0)


# ── Berries ───────────────────────────────────────────────────────────────────

func _create_initial_berries() -> void:
	for i in range(INITIAL_BERRY_COUNT):
		_spawn_berry(_random_world_pos(100), 1.0)


func _spawn_berry(pos: Vector2, growth: float) -> void:
	var node := _make_berry_node()
	node.position = pos
	add_child(node)
	var data := {node = node, growth = growth}
	berries.append(data)
	_apply_berry_scale(data)


func _make_berry_node() -> Node2D:
	var bush := Node2D.new()

	var base := Polygon2D.new()
	base.color = Color(0.15, 0.55, 0.15)
	base.polygon = _circle_polygon(12)
	bush.add_child(base)

	for bpos in [Vector2(-5, -5), Vector2(5, -5), Vector2(0, 4), Vector2(-6, 2), Vector2(6, 2)]:
		var berry := Polygon2D.new()
		berry.color = Color(0.85, 0.10, 0.20)
		berry.polygon = _circle_polygon(3.5)
		berry.position = bpos
		bush.add_child(berry)

	return bush


func _apply_berry_scale(data: Dictionary) -> void:
	var s: float = lerp(0.2, 1.0, clampf(data.growth, 0.0, 1.0))
	data.node.scale = Vector2(s, s)


func _grow_berries(delta: float) -> void:
	for data in berries:
		if data.growth >= 1.0:
			continue
		data.growth = minf(data.growth + BERRY_GROW_RATE * delta, 1.0)
		_apply_berry_scale(data)


func _maybe_spawn_berry(delta: float) -> void:
	berry_timer -= delta
	if berry_timer > 0.0 or berries.size() >= MAX_BERRIES:
		return
	berry_timer = BERRY_SPAWN_INTERVAL
	_spawn_berry(_random_world_pos(80), 0.0)


func _update_nearest_berry() -> void:
	var closest = null
	var closest_dist := BERRY_COLLECT_RANGE
	for data in berries:
		if not is_instance_valid(data.node) or data.growth < 1.0:
			continue
		var d := queen.position.distance_to(data.node.position)
		if d < closest_dist:
			closest_dist = d
			closest = data
	nearest_berry_data = closest
	_refresh_buttons()


func _on_berry_pressed() -> void:
	if nearest_berry_data == null or not is_instance_valid(nearest_berry_data.node):
		return
	nearest_berry_data.node.queue_free()
	berries.erase(nearest_berry_data)
	nearest_berry_data = null
	energy += 1.0
	_update_energy_ui()
	_refresh_buttons()


# ── Mushrooms ─────────────────────────────────────────────────────────────────

func _create_initial_mushrooms() -> void:
	for i in range(INITIAL_MUSHROOM_COUNT):
		_spawn_mushroom(_random_world_pos(100), 1.0)


func _spawn_mushroom(pos: Vector2, growth: float) -> void:
	var node := _make_mushroom_node()
	node.position = pos
	add_child(node)
	var data := {node = node, growth = growth}
	mushrooms.append(data)
	_apply_mushroom_scale(data)


func _make_mushroom_node() -> Node2D:
	var m := Node2D.new()
	var stem := ColorRect.new()
	stem.color = Color(0.88, 0.80, 0.65)
	stem.size = Vector2(8, 8)
	stem.position = Vector2(-4, 0)
	m.add_child(stem)
	var cap := Polygon2D.new()
	cap.color = Color(0.72, 0.20, 0.08)
	cap.polygon = _circle_polygon(12)
	cap.position = Vector2(0, -4)
	m.add_child(cap)
	for sp: Vector2 in [Vector2(-4, -6), Vector2(4, -3), Vector2(0, -10)]:
		var spot := Polygon2D.new()
		spot.color = Color(0.95, 0.90, 0.85)
		spot.polygon = _circle_polygon(2.5)
		spot.position = sp
		m.add_child(spot)
	return m


func _apply_mushroom_scale(data: Dictionary) -> void:
	var s: float = lerp(0.2, 1.0, clampf(data.growth, 0.0, 1.0))
	data.node.scale = Vector2(s, s)


func _grow_mushrooms(delta: float) -> void:
	for data in mushrooms:
		if data.growth >= 1.0:
			continue
		data.growth = minf(data.growth + MUSHROOM_GROW_RATE * delta, 1.0)
		_apply_mushroom_scale(data)


func _maybe_spawn_mushroom(delta: float) -> void:
	mushroom_timer -= delta
	if mushroom_timer > 0.0 or mushrooms.size() >= MAX_MUSHROOMS:
		return
	mushroom_timer = MUSHROOM_SPAWN_INTERVAL
	_spawn_mushroom(_random_world_pos(80), 0.0)


func _update_nearest_mushroom() -> void:
	if carrying_mushroom:
		nearest_mushroom_data = null
		return
	var closest = null
	var closest_dist := MUSHROOM_COLLECT_RANGE
	for data in mushrooms:
		if not is_instance_valid(data.node) or data.growth < 1.0:
			continue
		var d := queen.position.distance_to(data.node.position)
		if d < closest_dist:
			closest_dist = d
			closest = data
	nearest_mushroom_data = closest


func _on_mushroom_collect_pressed() -> void:
	if nearest_mushroom_data == null or not is_instance_valid(nearest_mushroom_data.node):
		return
	nearest_mushroom_data.node.queue_free()
	mushrooms.erase(nearest_mushroom_data)
	nearest_mushroom_data = null
	carrying_mushroom = true
	_attach_carried_mushroom()
	_refresh_buttons()


func _attach_carried_mushroom() -> void:
	mushroom_carried_node = _make_mushroom_node()
	mushroom_carried_node.scale = Vector2(0.7, 0.7)
	mushroom_carried_node.position = Vector2(22, -18)
	mushroom_carried_node.z_index = 11
	queen.add_child(mushroom_carried_node)


func _drop_carried_mushroom() -> void:
	if mushroom_carried_node != null and is_instance_valid(mushroom_carried_node):
		mushroom_carried_node.queue_free()
	mushroom_carried_node = null
	carrying_mushroom = false


# ── Kitchen interaction ────────────────────────────────────────────────────────

func _on_give_pressed() -> void:
	if not carrying_mushroom or kitchen_state != "idle":
		return
	_drop_carried_mushroom()
	kitchen_state = "cooking"
	cook_timer = COOK_TIME
	_refresh_buttons()


func _on_eat_pressed() -> void:
	if kitchen_state != "ready":
		return
	kitchen_state = "idle"
	energy = 20.0
	_update_energy_ui()
	if food_ready_node != null and is_instance_valid(food_ready_node):
		food_ready_node.queue_free()
		food_ready_node = null
	_refresh_buttons()


func _update_cooking(delta: float) -> void:
	if kitchen_state != "cooking":
		return
	cook_timer -= delta
	if cook_timer <= 0.0:
		kitchen_state = "ready"
		_spawn_food_ready_visual()
		_refresh_buttons()


func _spawn_food_ready_visual() -> void:
	if palace_interior_node == null:
		return
	food_ready_node = Node2D.new()
	food_ready_node.position = SERVING_TABLE_POS
	palace_interior_node.add_child(food_ready_node)
	var plate := Polygon2D.new()
	plate.color = Color(0.92, 0.88, 0.80)
	plate.polygon = _circle_polygon(14)
	food_ready_node.add_child(plate)
	var food := Polygon2D.new()
	food.color = Color(0.75, 0.38, 0.12)
	food.polygon = _circle_polygon(9)
	food_ready_node.add_child(food)
	var steam1 := ColorRect.new()
	steam1.color = Color(1, 1, 1, 0.55)
	steam1.size = Vector2(3, 10)
	steam1.position = Vector2(-5, -22)
	food_ready_node.add_child(steam1)
	var steam2 := ColorRect.new()
	steam2.color = Color(1, 1, 1, 0.55)
	steam2.size = Vector2(3, 10)
	steam2.position = Vector2(2, -24)
	food_ready_node.add_child(steam2)


# ── Energy ────────────────────────────────────────────────────────────────────

func _update_energy(delta: float) -> void:
	energy = maxf(ENERGY_MIN, energy - energy * ENERGY_DECAY * delta)
	_update_energy_ui()


func _update_energy_ui() -> void:
	energy_label.text = "Energie: %d" % int(energy)
	var fill_ratio: float = clampf(energy / 20.0, 0.0, 1.0)
	energy_bar_fill.size.x = 160.0 * fill_ratio
	if energy < 3.0:
		energy_bar_fill.color = Color(0.85, 0.15, 0.10)
	elif energy < 7.0:
		energy_bar_fill.color = Color(0.90, 0.70, 0.10)
	else:
		energy_bar_fill.color = Color(0.20, 0.80, 0.25)


# ── Palaces (world) ───────────────────────────────────────────────────────────

func _spawn_palace(pos: Vector2) -> void:
	var node := Node2D.new()
	node.position = pos
	add_child(node)
	var data := {pos = pos, stage = 0, node = node, furniture = []}
	palaces.append(data)
	_rebuild_palace(data)


func _rebuild_palace(data: Dictionary) -> void:
	for child in data.node.get_children():
		child.queue_free()

	var plot := ColorRect.new()
	plot.color = Color(0.65, 0.60, 0.50)
	plot.size = Vector2(100, 80)
	plot.position = Vector2(-50, -40)
	data.node.add_child(plot)

	var border := Polygon2D.new()
	border.color = Color(0.45, 0.40, 0.30)
	border.polygon = PackedVector2Array([
		Vector2(-50,-40), Vector2(50,-40), Vector2(50,40), Vector2(-50,40),
		Vector2(-50,-40), Vector2(-46,-36), Vector2(-46,36), Vector2(46,36),
		Vector2(46,-36), Vector2(-46,-36)
	])
	data.node.add_child(border)

	if data.stage < 1:
		return

	var foundation := ColorRect.new()
	foundation.color = Color(0.72, 0.68, 0.60)
	foundation.size = Vector2(100, 80)
	foundation.position = Vector2(-50, -40)
	data.node.add_child(foundation)

	if data.stage < 2:
		return

	var walls := ColorRect.new()
	walls.color = Color(0.80, 0.76, 0.68)
	walls.size = Vector2(84, 55)
	walls.position = Vector2(-42, -65)
	data.node.add_child(walls)

	var battlements := ColorRect.new()
	battlements.color = Color(0.70, 0.66, 0.58)
	battlements.size = Vector2(84, 8)
	battlements.position = Vector2(-42, -73)
	data.node.add_child(battlements)

	if data.stage < 3:
		return

	for tx in [-46, 34]:
		var tower := ColorRect.new()
		tower.color = Color(0.68, 0.64, 0.56)
		tower.size = Vector2(14, 70)
		tower.position = Vector2(tx, -75)
		data.node.add_child(tower)

		var tcap := ColorRect.new()
		tcap.color = Color(0.55, 0.50, 0.42)
		tcap.size = Vector2(14, 8)
		tcap.position = Vector2(tx, -83)
		data.node.add_child(tcap)

	if data.stage < 4:
		return

	var roof := Polygon2D.new()
	roof.color = Color(0.40, 0.20, 0.10)
	roof.polygon = PackedVector2Array([
		Vector2(0,-105), Vector2(-42,-65), Vector2(42,-65)
	])
	data.node.add_child(roof)

	var arch := ColorRect.new()
	arch.color = Color(0.20, 0.15, 0.08)
	arch.size = Vector2(18, 24)
	arch.position = Vector2(-9, -40)
	data.node.add_child(arch)

	if data.stage < 5:
		return

	var gold_trim := ColorRect.new()
	gold_trim.color = Color(1.0, 0.80, 0.0)
	gold_trim.size = Vector2(84, 4)
	gold_trim.position = Vector2(-42, -69)
	data.node.add_child(gold_trim)

	for fx in [-32, 0, 32]:
		var pole := ColorRect.new()
		pole.color = Color(0.60, 0.45, 0.10)
		pole.size = Vector2(3, 22)
		pole.position = Vector2(fx, -126)
		data.node.add_child(pole)

		var flag := Polygon2D.new()
		flag.color = Color(0.75, 0.05, 0.05)
		flag.polygon = PackedVector2Array([
			Vector2(fx + 3,-126), Vector2(fx + 18,-119), Vector2(fx + 3,-112)
		])
		data.node.add_child(flag)

	# Entrance arch at the front (bottom) of the completed palace
	var door_bg := ColorRect.new()
	door_bg.color = Color(0.10, 0.08, 0.06)
	door_bg.size = Vector2(24, 32)
	door_bg.position = Vector2(-12, -10)
	data.node.add_child(door_bg)

	var door_arch := Polygon2D.new()
	door_arch.color = Color(0.10, 0.08, 0.06)
	door_arch.polygon = PackedVector2Array([
		Vector2(-12, -10), Vector2(12, -10), Vector2(12, -26), Vector2(0, -32), Vector2(-12, -26)
	])
	data.node.add_child(door_arch)


# ── Palace interior ───────────────────────────────────────────────────────────

func _enter_palace() -> void:
	queen_world_pos = queen.position
	in_palace = true
	palace_num_rooms = maxi(palaces_completed, 1)
	_refresh_buttons()
	_update_ui()

	if palace_interior_node != null:
		palace_interior_node.queue_free()
	palace_interior_node = Node2D.new()
	add_child(palace_interior_node)
	for i in range(palace_num_rooms):
		_build_room(i)
	_draw_palace_furniture()
	_spawn_servant()

	# Place queen at the entered palace's room entrance
	var enter_x := INTERIOR_ORIGIN.x + active_palace_idx * ROOM_W
	queen.position = Vector2(enter_x, INTERIOR_ORIGIN.y + ROOM_H / 2.0 - WALL_T - 25.0)


func _exit_palace() -> void:
	_close_furnish_menu()
	in_palace = false
	near_kitchen = false
	servant_node = null
	food_ready_node = null
	if palace_interior_node != null:
		palace_interior_node.queue_free()
		palace_interior_node = null
	if exit_palace_idx >= 0 and exit_palace_idx < palaces.size():
		queen.position = palaces[exit_palace_idx].pos + Vector2(0, 60)
	else:
		queen.position = queen_world_pos + Vector2(0, 60)
	_refresh_buttons()
	_update_ui()


func _build_room(room_idx: int) -> void:
	var cx: float = INTERIOR_ORIGIN.x + room_idx * ROOM_W
	var cy: float = INTERIOR_ORIGIN.y
	var left: float = cx - ROOM_W / 2.0
	var right: float = cx + ROOM_W / 2.0
	var top: float = cy - ROOM_H / 2.0
	var bottom: float = cy + ROOM_H / 2.0

	# Floor
	_ri(left, top, ROOM_W, ROOM_H, Color(0.82, 0.78, 0.70))

	# Carpet runner (north-south)
	_ri(cx - 28.0, top + WALL_T, 56.0, ROOM_H - WALL_T * 2.0, Color(0.50, 0.08, 0.12))
	# Gold carpet trim
	_ri(cx - 30.0, top + WALL_T, 2.0, ROOM_H - WALL_T * 2.0, Color(0.85, 0.70, 0.10))
	_ri(cx + 28.0, top + WALL_T, 2.0, ROOM_H - WALL_T * 2.0, Color(0.85, 0.70, 0.10))

	# Top wall (solid)
	_ri(left, top, ROOM_W, WALL_T, Color(0.30, 0.27, 0.23))
	# Gold trim under top wall
	_ri(left + WALL_T, top + WALL_T, ROOM_W - WALL_T * 2.0, 3.0, Color(0.85, 0.70, 0.10))

	# Bottom wall — exit door in every room (each room has its own palace entrance)
	var hw: float = (ROOM_W - EXIT_W) / 2.0
	_ri(left, bottom - WALL_T, hw, WALL_T, Color(0.30, 0.27, 0.23))
	_ri(right - hw, bottom - WALL_T, hw, WALL_T, Color(0.30, 0.27, 0.23))
	_ri(left + hw - 3.0, bottom - WALL_T - 6.0, 3.0, 6.0, Color(0.55, 0.40, 0.10))
	_ri(right - hw, bottom - WALL_T - 6.0, 3.0, 6.0, Color(0.55, 0.40, 0.10))

	# Left wall — solid for room 0, door for rooms > 0
	if room_idx == 0:
		_ri(left, top, WALL_T, ROOM_H, Color(0.30, 0.27, 0.23))
	else:
		var dt: float = cy - DOOR_H / 2.0
		var db: float = cy + DOOR_H / 2.0
		_ri(left, top, WALL_T, dt - top, Color(0.30, 0.27, 0.23))
		_ri(left, db, WALL_T, bottom - db, Color(0.30, 0.27, 0.23))
		# Door frame gold
		_ri(left, dt - 3.0, WALL_T, 3.0, Color(0.55, 0.40, 0.10))
		_ri(left, db, WALL_T, 3.0, Color(0.55, 0.40, 0.10))

	# Right wall — door if more rooms follow, solid otherwise
	if room_idx < palace_num_rooms - 1:
		var dt: float = cy - DOOR_H / 2.0
		var db: float = cy + DOOR_H / 2.0
		_ri(right - WALL_T, top, WALL_T, dt - top, Color(0.30, 0.27, 0.23))
		_ri(right - WALL_T, db, WALL_T, bottom - db, Color(0.30, 0.27, 0.23))
		_ri(right - WALL_T, dt - 3.0, WALL_T, 3.0, Color(0.55, 0.40, 0.10))
		_ri(right - WALL_T, db, WALL_T, 3.0, Color(0.55, 0.40, 0.10))
	else:
		_ri(right - WALL_T, top, WALL_T, ROOM_H, Color(0.30, 0.27, 0.23))

	# Pillars at interior corners
	var ps: float = 16.0
	for px in [left + WALL_T, right - WALL_T - ps]:
		for py in [top + WALL_T, bottom - WALL_T - ps]:
			_ri(px, py, ps, ps, Color(0.48, 0.44, 0.38))
			# Pillar highlight
			_ri(px + 2.0, py + 2.0, 4.0, 4.0, Color(0.62, 0.57, 0.50))

	# Torches on left and right walls
	for ty in [cy - 100.0, cy, cy + 100.0]:
		_rc(left + WALL_T / 2.0, ty, 7.0, Color(1.0, 0.60, 0.0))
		_rc(right - WALL_T / 2.0, ty, 7.0, Color(1.0, 0.60, 0.0))
		# Torch glow
		_rc(left + WALL_T / 2.0, ty, 12.0, Color(1.0, 0.85, 0.0, 0.25))
		_rc(right - WALL_T / 2.0, ty, 12.0, Color(1.0, 0.85, 0.0, 0.25))

	# Windows on top wall
	for wx in [cx - 80.0, cx + 58.0]:
		_ri(wx, top + 3.0, 22.0, WALL_T - 6.0, Color(0.55, 0.78, 0.95))
		_ri(wx + 8.0, top + 2.0, 6.0, 4.0, Color(0.75, 0.90, 1.0))

	# Tapestries on top wall (between windows)
	_ri(cx - 52.0, top + 2.0, 28.0, WALL_T - 4.0, Color(0.55, 0.08, 0.12))
	_ri(cx + 24.0, top + 2.0, 28.0, WALL_T - 4.0, Color(0.55, 0.08, 0.12))

	# Kitchen in room 0 (throne is now a buyable item)
	if room_idx == 0:
		_build_kitchen(cx, cy)

	# Chandelier in other rooms
	if room_idx > 0:
		_rc(cx, cy, 18.0, Color(0.85, 0.70, 0.10))
		_rc(cx, cy, 10.0, Color(1.0, 0.90, 0.50))
		for angle in [0.0, PI / 2.0, PI, 3.0 * PI / 2.0]:
			var arm_end := Vector2(cos(angle) * 22.0, sin(angle) * 22.0)
			_rc(cx + arm_end.x, cy + arm_end.y, 5.0, Color(1.0, 0.65, 0.0))


func _build_throne(cx: float, ty: float) -> void:
	# Seat base
	_ri(cx - 20.0, ty + 10.0, 40.0, 26.0, Color(0.50, 0.30, 0.10))
	# Backrest
	_ri(cx - 18.0, ty - 16.0, 36.0, 28.0, Color(0.58, 0.35, 0.12))
	# Armrests
	_ri(cx - 24.0, ty + 10.0, 7.0, 18.0, Color(0.45, 0.27, 0.09))
	_ri(cx + 17.0, ty + 10.0, 7.0, 18.0, Color(0.45, 0.27, 0.09))
	# Cushion
	_ri(cx - 15.0, ty + 14.0, 30.0, 16.0, Color(0.50, 0.08, 0.12))
	# Gold top rail
	_ri(cx - 16.0, ty - 18.0, 32.0, 4.0, Color(0.90, 0.75, 0.10))
	# Crown finial on top
	var crown_pts := PackedVector2Array([
		Vector2(cx - 10.0, ty - 18.0),
		Vector2(cx - 10.0, ty - 30.0),
		Vector2(cx - 4.0, ty - 24.0),
		Vector2(cx, ty - 34.0),
		Vector2(cx + 4.0, ty - 24.0),
		Vector2(cx + 10.0, ty - 30.0),
		Vector2(cx + 10.0, ty - 18.0),
	])
	var crown_poly := Polygon2D.new()
	crown_poly.color = Color(0.90, 0.75, 0.10)
	crown_poly.polygon = crown_pts
	palace_interior_node.add_child(crown_poly)


func _build_kitchen(cx: float, cy: float) -> void:
	var ri := cx + ROOM_W / 2.0 - WALL_T  # right inner wall x
	var kb := cy + 50.0                    # kitchen top y

	# Overall kitchen mat
	_ri(ri - 130.0, kb + 5.0, 115.0, 175.0, Color(0.68, 0.55, 0.38, 0.35))

	# === COOKING ZONE (upper) ===
	# Stone floor to mark cooking area
	_ri(ri - 128.0, kb + 7.0, 111.0, 88.0, Color(0.50, 0.47, 0.44, 0.45))

	# Fireplace/stove built into right wall
	_ri(ri - 50.0, kb + 8.0, 48.0, 62.0, Color(0.28, 0.24, 0.20))   # stone surround
	_ri(ri - 46.0, kb + 12.0, 40.0, 46.0, Color(0.15, 0.12, 0.10))   # fire chamber
	var fire := Polygon2D.new()
	fire.color = Color(1.0, 0.45, 0.05, 0.92)
	fire.polygon = PackedVector2Array([
		Vector2(ri - 40.0, kb + 54.0), Vector2(ri - 26.0, kb + 28.0),
		Vector2(ri - 12.0, kb + 54.0), Vector2(ri - 18.0, kb + 62.0),
		Vector2(ri - 34.0, kb + 64.0)
	])
	palace_interior_node.add_child(fire)
	var ember := Polygon2D.new()
	ember.color = Color(1.0, 0.85, 0.20, 0.75)
	ember.polygon = _circle_polygon(7.0)
	ember.position = Vector2(ri - 26.0, kb + 40.0)
	palace_interior_node.add_child(ember)

	# Iron pot sitting on stove ledge
	_rc(ri - 26.0, kb + 58.0, 12.0, Color(0.30, 0.28, 0.26))
	_rc(ri - 26.0, kb + 58.0, 9.0, Color(0.45, 0.40, 0.36))
	_ri(ri - 36.0, kb + 46.0, 20.0, 4.0, Color(0.22, 0.20, 0.18))   # pot handle bar

	# Prep counter (left of stove)
	_ri(ri - 120.0, kb + 8.0, 56.0, 40.0, Color(0.50, 0.36, 0.18))
	_ri(ri - 118.0, kb + 10.0, 52.0, 36.0, Color(0.64, 0.50, 0.28))

	# Stone divider between cooking and serving zones
	_ri(ri - 130.0, kb + 95.0, 115.0, 12.0, Color(0.40, 0.38, 0.36))
	_ri(ri - 128.0, kb + 97.0, 111.0, 8.0, Color(0.52, 0.50, 0.48))

	# === SERVING ZONE (lower) ===
	# Wooden serving table
	_ri(ri - 128.0, kb + 112.0, 108.0, 8.0, Color(0.35, 0.22, 0.08))   # shadow/legs
	_ri(ri - 127.0, kb + 116.0, 106.0, 52.0, Color(0.56, 0.38, 0.16))   # table body
	_ri(ri - 125.0, kb + 118.0, 102.0, 46.0, Color(0.70, 0.52, 0.28))   # table surface

	# Decorative empty plates on table (before food is ready)
	_rc(ri - 90.0, kb + 138.0, 11.0, Color(0.88, 0.84, 0.78))
	_rc(ri - 90.0, kb + 138.0, 7.0, Color(0.78, 0.74, 0.68))
	_rc(ri - 60.0, kb + 143.0, 9.0, Color(0.88, 0.84, 0.78))
	_rc(ri - 60.0, kb + 143.0, 6.0, Color(0.78, 0.74, 0.68))


func _spawn_servant() -> void:
	servant_node = Node2D.new()
	servant_node.position = SERVANT_IDLE_POS
	servant_node.z_index = 10
	palace_interior_node.add_child(servant_node)

	var body := ColorRect.new()
	body.color = Color(0.88, 0.82, 0.72)
	body.size = Vector2(16, 20)
	body.position = Vector2(-8, -8)
	servant_node.add_child(body)

	var apron := ColorRect.new()
	apron.color = Color(0.96, 0.96, 0.94)
	apron.size = Vector2(10, 13)
	apron.position = Vector2(-5, -2)
	servant_node.add_child(apron)

	var head := Polygon2D.new()
	head.color = Color(0.82, 0.65, 0.50)
	head.polygon = _circle_polygon(6.5)
	head.position = Vector2(0, -13)
	servant_node.add_child(head)


func _update_servant(delta: float) -> void:
	if servant_node == null or not is_instance_valid(servant_node):
		return

	if kitchen_state == "idle":
		servant_node.position = SERVANT_IDLE_POS

	elif kitchen_state == "cooking":
		servant_cook_t += delta
		var diff := STOVE_POS - servant_node.position
		if diff.length() > 8.0:
			servant_node.position += diff.normalized() * SERVANT_SPEED * delta
		else:
			# Stirring animation at stove
			servant_node.position.x = STOVE_POS.x + sin(servant_cook_t * 3.5) * 2.5
			servant_node.position.y = STOVE_POS.y + cos(servant_cook_t * 4.0) * 2.0

	elif kitchen_state == "ready":
		servant_node.position = SERVING_TABLE_POS


# _ri / _rc: helpers that add rects/circles to the interior node
func _ri(x: float, y: float, w: float, h: float, color: Color) -> void:
	var r := ColorRect.new()
	r.color = color
	r.size = Vector2(w, h)
	r.position = Vector2(x, y)
	palace_interior_node.add_child(r)


func _rc(x: float, y: float, radius: float, color: Color) -> void:
	var p := Polygon2D.new()
	p.color = color
	p.polygon = _circle_polygon(radius)
	p.position = Vector2(x, y)
	palace_interior_node.add_child(p)


# ── UI ────────────────────────────────────────────────────────────────────────

func _create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	ui_label = Label.new()
	ui_label.position = Vector2(20, 20)
	ui_label.add_theme_font_size_override("font_size", 28)
	ui_label.add_theme_color_override("font_color", Color.WHITE)
	layer.add_child(ui_label)

	tree_label = Label.new()
	tree_label.position = Vector2(20, 58)
	tree_label.add_theme_font_size_override("font_size", 28)
	tree_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.3))
	layer.add_child(tree_label)

	palace_label = Label.new()
	palace_label.position = Vector2(20, 96)
	palace_label.add_theme_font_size_override("font_size", 28)
	palace_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	layer.add_child(palace_label)

	# Energy bar
	energy_label = Label.new()
	energy_label.position = Vector2(20, 134)
	energy_label.add_theme_font_size_override("font_size", 24)
	energy_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	layer.add_child(energy_label)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.2, 0.2, 0.2, 0.7)
	bar_bg.size = Vector2(162, 14)
	bar_bg.position = Vector2(20, 163)
	layer.add_child(bar_bg)

	energy_bar_fill = ColorRect.new()
	energy_bar_fill.size = Vector2(160, 10)
	energy_bar_fill.position = Vector2(21, 165)
	layer.add_child(energy_bar_fill)
	_update_energy_ui()

	collect_button = _make_icon_button(layer, COLLECT_BTN_CENTER)
	var handle := ColorRect.new()
	handle.color = Color(0.5, 0.28, 0.08)
	handle.size = Vector2(7, 30)
	handle.position = Vector2(-3, -8)
	collect_button.add_child(handle)
	var blade := Polygon2D.new()
	blade.color = Color(0.78, 0.78, 0.85)
	blade.polygon = PackedVector2Array([
		Vector2(3,-16), Vector2(20,-20), Vector2(22,-5), Vector2(3,-1)
	])
	collect_button.add_child(blade)

	build_button = _make_icon_button(layer, BUILD_BTN_CENTER)
	var hhead := ColorRect.new()
	hhead.color = Color(0.70, 0.70, 0.75)
	hhead.size = Vector2(22, 12)
	hhead.position = Vector2(-11, -16)
	build_button.add_child(hhead)
	var hhandle := ColorRect.new()
	hhandle.color = Color(0.5, 0.28, 0.08)
	hhandle.size = Vector2(7, 24)
	hhandle.position = Vector2(2, -4)
	hhandle.rotation = 0.5
	build_button.add_child(hhandle)

	# Berry button — green bush with red dots
	berry_button = _make_icon_button(layer, BERRY_BTN_CENTER)
	var bush_base := Polygon2D.new()
	bush_base.color = Color(0.15, 0.55, 0.15)
	bush_base.polygon = _circle_polygon(16)
	berry_button.add_child(bush_base)
	for bpos: Vector2 in [Vector2(-6, -6), Vector2(6, -6), Vector2(0, 5), Vector2(-7, 3), Vector2(7, 3)]:
		var dot := Polygon2D.new()
		dot.color = Color(0.85, 0.10, 0.20)
		dot.polygon = _circle_polygon(4.5)
		dot.position = bpos
		berry_button.add_child(dot)

	# Mushroom collect button
	mushroom_button = _make_icon_button(layer, MUSHROOM_BTN_CENTER)
	var m_stem := ColorRect.new()
	m_stem.color = Color(0.88, 0.80, 0.65)
	m_stem.size = Vector2(8, 9)
	m_stem.position = Vector2(-4, 2)
	mushroom_button.add_child(m_stem)
	var m_cap := Polygon2D.new()
	m_cap.color = Color(0.72, 0.20, 0.08)
	m_cap.polygon = _circle_polygon(14)
	m_cap.position = Vector2(0, -4)
	mushroom_button.add_child(m_cap)
	for sp: Vector2 in [Vector2(-5, -7), Vector2(5, -3), Vector2(0, -12)]:
		var spot := Polygon2D.new()
		spot.color = Color(0.95, 0.90, 0.85)
		spot.polygon = _circle_polygon(3.0)
		spot.position = sp
		mushroom_button.add_child(spot)

	# Give-to-kitchen button (mushroom handed over)
	give_button = _make_icon_button(layer, KITCHEN_BTN_CENTER)
	var g_cap := Polygon2D.new()
	g_cap.color = Color(0.72, 0.20, 0.08)
	g_cap.polygon = _circle_polygon(11)
	g_cap.position = Vector2(-6, -4)
	give_button.add_child(g_cap)
	var g_arrow := Polygon2D.new()
	g_arrow.color = Color(0.95, 0.85, 0.30)
	g_arrow.polygon = PackedVector2Array([
		Vector2(2, -4), Vector2(14, -4), Vector2(14, -8), Vector2(20, 0), Vector2(14, 8), Vector2(14, 4), Vector2(2, 4)
	])
	give_button.add_child(g_arrow)

	# Eat button (steaming plate)
	eat_button = _make_icon_button(layer, KITCHEN_BTN_CENTER)
	var e_plate := Polygon2D.new()
	e_plate.color = Color(0.92, 0.88, 0.80)
	e_plate.polygon = _circle_polygon(14)
	e_plate.position = Vector2(0, 4)
	eat_button.add_child(e_plate)
	var e_food := Polygon2D.new()
	e_food.color = Color(0.75, 0.38, 0.12)
	e_food.polygon = _circle_polygon(9)
	e_food.position = Vector2(0, 4)
	eat_button.add_child(e_food)
	var e_steam := ColorRect.new()
	e_steam.color = Color(1, 1, 1, 0.7)
	e_steam.size = Vector2(3, 9)
	e_steam.position = Vector2(-3, -14)
	eat_button.add_child(e_steam)
	var e_steam2 := ColorRect.new()
	e_steam2.color = Color(1, 1, 1, 0.7)
	e_steam2.size = Vector2(3, 9)
	e_steam2.position = Vector2(3, -16)
	eat_button.add_child(e_steam2)

	# Furnish button — sofa icon
	furnish_button = _make_icon_button(layer, FURNISH_BTN_CENTER)
	var f_back := ColorRect.new()
	f_back.color = Color(0.55, 0.35, 0.12)
	f_back.size = Vector2(24, 10)
	f_back.position = Vector2(-12, -14)
	furnish_button.add_child(f_back)
	var f_seat := ColorRect.new()
	f_seat.color = Color(0.65, 0.42, 0.16)
	f_seat.size = Vector2(26, 9)
	f_seat.position = Vector2(-13, -4)
	furnish_button.add_child(f_seat)
	var f_arm_l := ColorRect.new()
	f_arm_l.color = Color(0.50, 0.30, 0.10)
	f_arm_l.size = Vector2(5, 14)
	f_arm_l.position = Vector2(-14, -11)
	furnish_button.add_child(f_arm_l)
	var f_arm_r := ColorRect.new()
	f_arm_r.color = Color(0.50, 0.30, 0.10)
	f_arm_r.size = Vector2(5, 14)
	f_arm_r.position = Vector2(9, -11)
	furnish_button.add_child(f_arm_r)
	var f_star := Polygon2D.new()
	f_star.color = Color(0.95, 0.80, 0.10)
	f_star.polygon = PackedVector2Array([
		Vector2(10, -20), Vector2(12, -16), Vector2(16, -16),
		Vector2(13, -13), Vector2(14, -9), Vector2(10, -12),
		Vector2(6, -9), Vector2(7, -13), Vector2(4, -16), Vector2(8, -16)
	])
	furnish_button.add_child(f_star)

	_update_ui()


func _make_icon_button(layer: CanvasLayer, center: Vector2) -> Node2D:
	var btn := Node2D.new()
	btn.position = center
	btn.visible = false
	layer.add_child(btn)
	var bg := Polygon2D.new()
	bg.color = Color(0.15, 0.15, 0.15, 0.8)
	bg.polygon = _circle_polygon(BUILD_BTN_RADIUS)
	btn.add_child(bg)
	return btn


func _update_ui() -> void:
	ui_label.text = "Sterne: %d / %d" % [stars_collected, STAR_COUNT]
	tree_label.text = "Holz: %d" % tree_inventory
	if in_palace:
		palace_label.text = "Im Palast"
	elif active_palace_idx >= 0:
		var p: Dictionary = palaces[active_palace_idx]
		if p.stage >= TOTAL_STAGES:
			palace_label.text = "Palast %d: fertig!" % (active_palace_idx + 1)
		else:
			palace_label.text = "Palast %d: Stufe %d/%d" % [active_palace_idx + 1, p.stage, TOTAL_STAGES]
	else:
		palace_label.text = "Paläste gebaut: %d" % palaces_completed


func _refresh_buttons() -> void:
	collect_button.visible = nearest_tree_data != null and not in_palace
	berry_button.visible = nearest_berry_data != null and not in_palace
	mushroom_button.visible = nearest_mushroom_data != null and not in_palace and not carrying_mushroom
	give_button.visible = in_palace and near_kitchen and carrying_mushroom and kitchen_state == "idle"
	eat_button.visible = in_palace and near_kitchen and kitchen_state == "ready"
	var can_build: bool = (
		active_palace_idx >= 0
		and tree_inventory >= WOOD_PER_STAGE
		and palaces[active_palace_idx].stage < TOTAL_STAGES
		and not in_palace
	)
	build_button.visible = can_build
	furnish_button.visible = in_palace and not furnish_menu_open


# ── Actions ───────────────────────────────────────────────────────────────────

func _on_collect_pressed() -> void:
	if nearest_tree_data == null or not is_instance_valid(nearest_tree_data.node):
		return
	nearest_tree_data.node.queue_free()
	trees.erase(nearest_tree_data)
	nearest_tree_data = null
	tree_inventory += 1
	_update_ui()
	_refresh_buttons()


func _on_build_pressed() -> void:
	if active_palace_idx < 0:
		return
	var p: Dictionary = palaces[active_palace_idx]
	if tree_inventory < WOOD_PER_STAGE or p.stage >= TOTAL_STAGES:
		return
	tree_inventory -= WOOD_PER_STAGE
	p.stage += 1
	_rebuild_palace(p)
	_update_ui()
	_refresh_buttons()

	if p.stage >= TOTAL_STAGES:
		palaces_completed += 1
		var next_pos: Vector2 = p.pos + PALACE_SPACING
		next_pos = next_pos.clamp(-WORLD_HALF + Vector2(60, 60), WORLD_HALF - Vector2(60, 60))
		_spawn_palace(next_pos)


func _show_overlay(msg: String) -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var label := Label.new()
	label.text = msg
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 44)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.1))
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(label)


# ── Furnish menu ──────────────────────────────────────────────────────────────

func _current_room_idx() -> int:
	var rel := queen.position.x - INTERIOR_ORIGIN.x + ROOM_W * 0.5
	return clampi(int(rel / ROOM_W), 0, palace_num_rooms - 1)


func _room_items(room_idx: int) -> Array:
	match room_idx:
		0: return ROOM_0_ITEMS
		1: return ROOM_1_ITEMS
		2: return ROOM_2_ITEMS
		3: return ROOM_3_ITEMS
	return []


func _open_furnish_menu() -> void:
	if not in_palace:
		return
	var room_idx := _current_room_idx()
	if room_idx >= palaces.size():
		return
	furnish_menu_open = true
	_refresh_buttons()
	furnish_menu_layer = CanvasLayer.new()
	add_child(furnish_menu_layer)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.70)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	furnish_menu_layer.add_child(dim)

	var panel := ColorRect.new()
	panel.color = Color(0.16, 0.12, 0.08, 0.97)
	panel.size = Vector2(350, 370)
	panel.position = Vector2(20, 220)
	furnish_menu_layer.add_child(panel)

	var border_top := ColorRect.new()
	border_top.color = Color(0.80, 0.62, 0.12)
	border_top.size = Vector2(350, 4)
	border_top.position = Vector2(20, 220)
	furnish_menu_layer.add_child(border_top)

	var room_name: String = ROOM_NAMES[mini(room_idx, ROOM_NAMES.size() - 1)]
	var title := Label.new()
	title.text = "Room %d: %s" % [room_idx + 1, room_name]
	title.position = Vector2(30, 228)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.38))
	furnish_menu_layer.add_child(title)

	var p: Dictionary = palaces[room_idx]
	var palace_furniture: Array = p.furniture

	var sub := Label.new()
	sub.text = "Holz verfügbar: " + str(tree_inventory)
	sub.position = Vector2(30, 258)
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.70, 0.90, 0.40))
	furnish_menu_layer.add_child(sub)

	var items := _room_items(room_idx)
	for i in range(items.size()):
		var item: Dictionary = items[i]
		var row_y: float = 280.0 + i * 50.0
		var is_owned: bool = palace_furniture.has(item.id)
		var can_afford: bool = tree_inventory >= item.wood

		var row_bg := ColorRect.new()
		if is_owned:
			row_bg.color = Color(0.12, 0.30, 0.12, 0.85)
		elif can_afford:
			row_bg.color = Color(0.14, 0.28, 0.14, 0.85)
		else:
			row_bg.color = Color(0.30, 0.18, 0.10, 0.85)
		row_bg.size = Vector2(346, 46)
		row_bg.position = Vector2(22, row_y + 2)
		furnish_menu_layer.add_child(row_bg)

		var name_lbl := Label.new()
		name_lbl.text = item.label + ("  [besessen]" if is_owned else "")
		name_lbl.position = Vector2(30, row_y + 10)
		name_lbl.add_theme_font_size_override("font_size", 19)
		name_lbl.add_theme_color_override("font_color",
			Color(0.55, 0.90, 0.45) if is_owned else Color(0.90, 0.84, 0.74))
		furnish_menu_layer.add_child(name_lbl)

		if not is_owned:
			var cost_bg := ColorRect.new()
			cost_bg.color = Color(0.25, 0.52, 0.18, 0.9) if can_afford else Color(0.40, 0.18, 0.10, 0.9)
			cost_bg.size = Vector2(80, 36)
			cost_bg.position = Vector2(282, row_y + 6)
			furnish_menu_layer.add_child(cost_bg)

			var cost_lbl := Label.new()
			cost_lbl.text = str(item.wood) + " Holz"
			cost_lbl.position = Vector2(286, row_y + 12)
			cost_lbl.add_theme_font_size_override("font_size", 17)
			cost_lbl.add_theme_color_override("font_color", Color.WHITE)
			furnish_menu_layer.add_child(cost_lbl)


func _close_furnish_menu() -> void:
	if furnish_menu_layer != null and is_instance_valid(furnish_menu_layer):
		furnish_menu_layer.queue_free()
		furnish_menu_layer = null
	furnish_menu_open = false
	_refresh_buttons()


func _on_furnish_row_tapped(i: int) -> void:
	var room_idx := _current_room_idx()
	if room_idx >= palaces.size():
		return
	var items := _room_items(room_idx)
	if i >= items.size():
		return
	var item: Dictionary = items[i]
	var p: Dictionary = palaces[room_idx]
	var palace_furniture: Array = p.furniture
	if palace_furniture.has(item.id):
		return
	if tree_inventory < item.wood:
		return
	tree_inventory -= item.wood
	palace_furniture.append(item.id)
	_draw_furniture_item(item.id, room_idx)
	_update_ui()
	_close_furnish_menu()
	_open_furnish_menu()


func _draw_palace_furniture() -> void:
	if palace_interior_node == null:
		return
	for i in range(mini(palaces.size(), 4)):
		if i >= palace_num_rooms:
			break
		var pf: Array = palaces[i].furniture
		for id in pf:
			_draw_furniture_item(id, i)


func _draw_furniture_item(id: String, room_idx: int) -> void:
	if palace_interior_node == null:
		return
	var ox := float(room_idx) * ROOM_W  # x offset for this room
	match id:
		# ── Room 0: Throne Room ───────────────────────────────────────────────
		"throne":
			_build_throne(ox, INTERIOR_ORIGIN.y - ROOM_H / 2.0 + WALL_T + 14.0)
		"rug":
			_ri(ox - 150.0, -3575.0, 90.0, 106.0, Color(0.62, 0.10, 0.08))
			_ri(ox - 148.0, -3573.0, 86.0, 102.0, Color(0.72, 0.14, 0.10, 0.85))
			_ri(ox - 148.0, -3573.0, 86.0, 5.0, Color(0.90, 0.72, 0.20))
			_ri(ox - 148.0, -3471.0, 86.0, 5.0, Color(0.90, 0.72, 0.20))
			_ri(ox - 148.0, -3573.0, 5.0, 102.0, Color(0.90, 0.72, 0.20))
			_ri(ox - 67.0, -3573.0, 5.0, 102.0, Color(0.90, 0.72, 0.20))
			_rc(ox - 105.0, -3522.0, 20.0, Color(0.90, 0.72, 0.20, 0.55))
			_rc(ox - 105.0, -3522.0, 12.0, Color(0.72, 0.14, 0.10, 0.90))
		"candle":
			_ri(ox - 139.0, -3278.0, 5.0, 28.0, Color(0.55, 0.40, 0.12))
			_ri(ox - 145.0, -3284.0, 17.0, 4.0, Color(0.65, 0.50, 0.18))
			_ri(ox - 142.0, -3282.0, 5.0, 14.0, Color(0.92, 0.90, 0.82))
			var flame := Polygon2D.new()
			flame.color = Color(1.0, 0.72, 0.05, 0.95)
			flame.polygon = PackedVector2Array([
				Vector2(ox - 142.0, -3293.0), Vector2(ox - 139.5, -3300.0),
				Vector2(ox - 137.0, -3293.0), Vector2(ox - 138.5, -3289.0), Vector2(ox - 140.5, -3289.0)
			])
			palace_interior_node.add_child(flame)
		"tapestry":
			_ri(ox - 163.0, -3515.0, 15.0, 65.0, Color(0.48, 0.06, 0.10))
			_ri(ox - 161.0, -3513.0, 11.0, 61.0, Color(0.62, 0.09, 0.13, 0.92))
			_ri(ox - 163.0, -3515.0, 15.0, 3.0, Color(0.88, 0.70, 0.10))
			_ri(ox - 163.0, -3453.0, 15.0, 3.0, Color(0.88, 0.70, 0.10))
			_rc(ox - 155.0, -3493.0, 5.0, Color(0.90, 0.72, 0.20, 0.82))
			_rc(ox - 155.0, -3474.0, 4.0, Color(0.90, 0.72, 0.20, 0.82))
			_ri(ox - 163.0, -3483.0, 15.0, 2.0, Color(0.90, 0.72, 0.20, 0.55))
		"bookshelf":
			_ri(ox - 163.0, -3665.0, 22.0, 95.0, Color(0.38, 0.23, 0.07))
			_ri(ox - 161.0, -3663.0, 18.0, 91.0, Color(0.50, 0.33, 0.11))
			_ri(ox - 161.0, -3630.0, 18.0, 2.0, Color(0.30, 0.18, 0.05))
			_ri(ox - 161.0, -3600.0, 18.0, 2.0, Color(0.30, 0.18, 0.05))
			_ri(ox - 161.0, -3663.0, 4.0, 31.0, Color(0.15, 0.40, 0.65))
			_ri(ox - 157.0, -3663.0, 4.0, 25.0, Color(0.65, 0.15, 0.15))
			_ri(ox - 153.0, -3663.0, 4.0, 29.0, Color(0.15, 0.55, 0.20))
			_ri(ox - 149.0, -3663.0, 4.0, 22.0, Color(0.70, 0.55, 0.10))
			_ri(ox - 161.0, -3628.0, 4.0, 26.0, Color(0.55, 0.15, 0.55))
			_ri(ox - 157.0, -3628.0, 4.0, 30.0, Color(0.15, 0.50, 0.50))
			_ri(ox - 153.0, -3628.0, 4.0, 20.0, Color(0.70, 0.30, 0.10))
			_ri(ox - 149.0, -3628.0, 4.0, 28.0, Color(0.20, 0.20, 0.70))
			_ri(ox - 161.0, -3598.0, 4.0, 24.0, Color(0.65, 0.45, 0.10))
			_ri(ox - 157.0, -3598.0, 4.0, 28.0, Color(0.15, 0.45, 0.60))
			_ri(ox - 153.0, -3598.0, 4.0, 22.0, Color(0.60, 0.15, 0.30))
		# ── Room 1: Library ───────────────────────────────────────────────────
		"chair":
			_ri(ox - 110.0, -3562.0, 34.0, 12.0, Color(0.42, 0.21, 0.07))
			_ri(ox - 112.0, -3550.0, 38.0, 12.0, Color(0.50, 0.26, 0.09))
			_ri(ox - 114.0, -3562.0, 6.0, 22.0, Color(0.38, 0.18, 0.06))
			_ri(ox - 74.0,  -3562.0, 6.0, 22.0, Color(0.38, 0.18, 0.06))
			_ri(ox - 106.0, -3560.0, 26.0, 9.0, Color(0.50, 0.07, 0.11))
			_ri(ox - 108.0, -3548.0, 30.0, 9.0, Color(0.50, 0.07, 0.11))
		"desk":
			_ri(ox - 163.0, -3642.0, 24.0, 58.0, Color(0.42, 0.26, 0.09))
			_ri(ox - 161.0, -3640.0, 20.0, 54.0, Color(0.58, 0.38, 0.14))
			_ri(ox - 160.0, -3588.0, 4.0, 12.0, Color(0.35, 0.20, 0.07))
			_ri(ox - 146.0, -3588.0, 4.0, 12.0, Color(0.35, 0.20, 0.07))
			_ri(ox - 158.0, -3638.0, 2.0, 18.0, Color(0.85, 0.80, 0.55))
			_rc(ox - 157.0, -3619.0, 3.0, Color(0.18, 0.14, 0.10))
			_ri(ox - 155.0, -3638.0, 11.0, 14.0, Color(0.95, 0.92, 0.85))
		"gclock":
			_ri(ox - 163.0, -3728.0, 19.0, 112.0, Color(0.35, 0.22, 0.08))
			_ri(ox - 161.0, -3726.0, 15.0, 108.0, Color(0.48, 0.30, 0.11))
			_rc(ox - 153.0, -3700.0, 9.0, Color(0.90, 0.86, 0.78))
			_rc(ox - 153.0, -3700.0, 7.0, Color(0.96, 0.93, 0.86))
			_ri(ox - 154.0, -3708.0, 2.0, 8.0, Color(0.12, 0.10, 0.08))
			_ri(ox - 154.0, -3706.0, 7.0, 2.0, Color(0.12, 0.10, 0.08))
			_ri(ox - 159.0, -3668.0, 11.0, 32.0, Color(0.62, 0.50, 0.30, 0.4))
			_rc(ox - 153.0, -3652.0, 5.0, Color(0.85, 0.70, 0.10))
			_ri(ox - 161.0, -3730.0, 15.0, 4.0, Color(0.28, 0.17, 0.06))
		"painting":
			_ri(ox - 163.0, -3492.0, 19.0, 28.0, Color(0.55, 0.40, 0.12))
			_ri(ox - 161.0, -3490.0, 15.0, 24.0, Color(0.18, 0.32, 0.52))
			_ri(ox - 161.0, -3477.0, 15.0, 11.0, Color(0.22, 0.48, 0.18))
			_rc(ox - 154.0, -3485.0, 3.5, Color(0.95, 0.85, 0.20))
			_ri(ox - 159.0, -3479.0, 2.0, 6.0, Color(0.35, 0.22, 0.08))
			_rc(ox - 158.0, -3482.0, 4.0, Color(0.14, 0.48, 0.14))
		"globe":
			_ri(ox - 102.0, -3440.0, 6.0, 22.0, Color(0.48, 0.30, 0.10))
			_ri(ox - 114.0, -3420.0, 30.0, 5.0, Color(0.55, 0.35, 0.12))
			_rc(ox - 99.0, -3452.0, 16.0, Color(0.15, 0.35, 0.65))
			_ri(ox - 110.0, -3462.0, 10.0, 7.0, Color(0.25, 0.55, 0.20))
			_ri(ox - 97.0,  -3456.0, 8.0, 10.0, Color(0.25, 0.55, 0.20))
			_ri(ox - 104.0, -3444.0, 7.0, 5.0, Color(0.25, 0.55, 0.20))
			_ri(ox - 91.0,  -3462.0, 5.0, 6.0, Color(0.25, 0.55, 0.20))
		# ── Room 2: Gallery ───────────────────────────────────────────────────
		"mirror":
			_rc(ox - 152.0, -3470.0, 22.0, Color(0.80, 0.62, 0.12))
			_rc(ox - 152.0, -3470.0, 17.0, Color(0.55, 0.75, 0.90, 0.82))
			_rc(ox - 152.0, -3470.0, 13.0, Color(0.80, 0.92, 1.00, 0.42))
			_rc(ox - 152.0, -3492.0, 5.0, Color(0.90, 0.72, 0.20))
			_rc(ox - 152.0, -3448.0, 5.0, Color(0.90, 0.72, 0.20))
			_rc(ox - 174.0, -3470.0, 4.0, Color(0.90, 0.72, 0.20))
			_rc(ox - 130.0, -3470.0, 4.0, Color(0.90, 0.72, 0.20))
		"vase":
			var vpts := PackedVector2Array([
				Vector2(ox - 149.0, -3258.0), Vector2(ox - 143.0, -3260.0),
				Vector2(ox - 139.0, -3265.0), Vector2(ox - 138.0, -3278.0),
				Vector2(ox - 140.0, -3286.0), Vector2(ox - 146.0, -3289.0),
				Vector2(ox - 154.0, -3289.0), Vector2(ox - 158.0, -3283.0),
				Vector2(ox - 157.0, -3270.0), Vector2(ox - 154.0, -3260.0)
			])
			var vase := Polygon2D.new()
			vase.color = Color(0.65, 0.22, 0.06)
			vase.polygon = vpts
			palace_interior_node.add_child(vase)
			_ri(ox - 151.0, -3250.0, 6.0, 10.0, Color(0.65, 0.22, 0.06))
			_ri(ox - 154.0, -3252.0, 12.0, 3.0, Color(0.78, 0.32, 0.10))
			_rc(ox - 148.0, -3272.0, 4.0, Color(0.95, 0.78, 0.38, 0.72))
		"curtains":
			for wx: float in [ox - 80.0, ox + 58.0]:
				_ri(wx - 8.0, -3773.0, 40.0, 4.0, Color(0.68, 0.52, 0.12))
				for rx: float in [-6.0, -1.0, 4.0, 9.0, 14.0, 19.0, 24.0]:
					_rc(wx + rx, -3771.0, 2.5, Color(0.84, 0.68, 0.16))
				_ri(wx - 7.0, -3769.0, 9.0, 52.0, Color(0.50, 0.07, 0.11, 0.92))
				_ri(wx + 20.0, -3769.0, 9.0, 52.0, Color(0.50, 0.07, 0.11, 0.92))
		"statue":
			_ri(ox - 100.0, -3432.0, 20.0, 22.0, Color(0.58, 0.55, 0.50))
			_ri(ox - 98.0,  -3430.0, 16.0, 18.0, Color(0.72, 0.68, 0.62))
			_rc(ox - 90.0,  -3448.0, 7.0, Color(0.65, 0.62, 0.57))
			_ri(ox - 96.0,  -3445.0, 12.0, 18.0, Color(0.62, 0.58, 0.53))
			_ri(ox - 99.0,  -3442.0, 5.0, 10.0, Color(0.60, 0.56, 0.51))
			_ri(ox - 82.0,  -3439.0, 5.0, 10.0, Color(0.60, 0.56, 0.51))
			_rc(ox - 88.0,  -3448.0, 3.0, Color(0.82, 0.80, 0.76, 0.5))
		"sidetable":
			_ri(ox - 107.0, -3324.0, 54.0, 6.0, Color(0.38, 0.22, 0.07))
			_ri(ox - 105.0, -3322.0, 50.0, 5.0, Color(0.62, 0.44, 0.18))
			_ri(ox - 102.0, -3317.0, 5.0, 20.0, Color(0.46, 0.28, 0.09))
			_ri(ox - 60.0,  -3317.0, 5.0, 20.0, Color(0.46, 0.28, 0.09))
			_rc(ox - 80.0,  -3327.0, 7.0, Color(0.88, 0.82, 0.74))
			_ri(ox - 87.0,  -3320.0, 14.0, 2.0, Color(0.88, 0.82, 0.74))
		# ── Room 3: Royal Chamber ─────────────────────────────────────────────
		"bed":
			_ri(ox - 140.0, -3700.0, 100.0, 60.0, Color(0.40, 0.24, 0.08))
			_ri(ox - 138.0, -3698.0, 96.0,  56.0, Color(0.55, 0.35, 0.14))
			_ri(ox - 136.0, -3696.0, 92.0,  52.0, Color(0.88, 0.84, 0.78))
			_ri(ox - 133.0, -3694.0, 26.0,  14.0, Color(0.96, 0.94, 0.90))
			_ri(ox - 103.0, -3694.0, 26.0,  14.0, Color(0.96, 0.94, 0.90))
			_ri(ox - 136.0, -3678.0, 92.0,  32.0, Color(0.50, 0.07, 0.11))
			_ri(ox - 133.0, -3676.0, 86.0,  28.0, Color(0.60, 0.09, 0.14, 0.85))
			for bpx: float in [ox - 141.0, ox - 45.0]:
				_rc(bpx, -3700.0, 4.5, Color(0.42, 0.26, 0.09))
				_rc(bpx, -3642.0, 4.5, Color(0.42, 0.26, 0.09))
		"wardrobe":
			_ri(ox - 163.0, -3712.0, 32.0, 82.0, Color(0.38, 0.23, 0.08))
			_ri(ox - 161.0, -3710.0, 28.0, 78.0, Color(0.52, 0.34, 0.12))
			_ri(ox - 160.0, -3708.0, 12.0, 74.0, Color(0.58, 0.40, 0.16))
			_ri(ox - 147.0, -3708.0, 12.0, 74.0, Color(0.58, 0.40, 0.16))
			_rc(ox - 150.0, -3671.0, 2.5, Color(0.80, 0.65, 0.12))
			_rc(ox - 137.0, -3671.0, 2.5, Color(0.80, 0.65, 0.12))
			_ri(ox - 163.0, -3714.0, 32.0, 4.0, Color(0.30, 0.18, 0.06))
		"vanity":
			_ri(ox - 112.0, -3334.0, 54.0, 6.0, Color(0.42, 0.26, 0.08))
			_ri(ox - 110.0, -3332.0, 50.0, 5.0, Color(0.60, 0.42, 0.16))
			_ri(ox - 107.0, -3327.0, 4.0, 18.0, Color(0.45, 0.27, 0.09))
			_ri(ox - 65.0,  -3327.0, 4.0, 18.0, Color(0.45, 0.27, 0.09))
			_ri(ox - 102.0, -3358.0, 32.0, 24.0, Color(0.52, 0.38, 0.12))
			_ri(ox - 100.0, -3356.0, 28.0, 20.0, Color(0.65, 0.82, 0.95, 0.8))
			_rc(ox - 86.0,  -3352.0, 6.0, Color(0.80, 0.90, 1.0, 0.4))
			_rc(ox - 97.0,  -3336.0, 4.0, Color(0.62, 0.30, 0.62))
			_rc(ox - 84.0,  -3336.0, 3.5, Color(0.30, 0.55, 0.72))
		"fireplace":
			_ri(ox - 163.0, -3532.0, 40.0, 56.0, Color(0.45, 0.42, 0.38))
			_ri(ox - 159.0, -3528.0, 32.0, 44.0, Color(0.15, 0.12, 0.10))
			var fp := Polygon2D.new()
			fp.color = Color(1.0, 0.45, 0.05, 0.92)
			fp.polygon = PackedVector2Array([
				Vector2(ox - 152.0, -3488.0), Vector2(ox - 143.0, -3512.0),
				Vector2(ox - 134.0, -3488.0), Vector2(ox - 138.0, -3482.0),
				Vector2(ox - 148.0, -3480.0)
			])
			palace_interior_node.add_child(fp)
			var fe := Polygon2D.new()
			fe.color = Color(1.0, 0.85, 0.20, 0.75)
			fe.polygon = _circle_polygon(7.0)
			fe.position = Vector2(ox - 143.0, -3500.0)
			palace_interior_node.add_child(fe)
			_ri(ox - 165.0, -3534.0, 44.0, 5.0, Color(0.52, 0.50, 0.46))
			_rc(ox - 153.0, -3492.0, 3.0, Color(0.30, 0.28, 0.26))
			_rc(ox - 133.0, -3492.0, 3.0, Color(0.30, 0.28, 0.26))
		"trophy":
			_ri(ox - 112.0, -3452.0, 42.0, 52.0, Color(0.38, 0.22, 0.07))
			_ri(ox - 110.0, -3450.0, 38.0, 48.0, Color(0.68, 0.82, 0.90, 0.48))
			_rc(ox - 91.0,  -3432.0, 9.0, Color(0.85, 0.68, 0.10))
			_ri(ox - 94.0,  -3421.0, 6.0, 8.0, Color(0.85, 0.68, 0.10))
			_ri(ox - 98.0,  -3415.0, 14.0, 3.0, Color(0.85, 0.68, 0.10))
			_rc(ox - 80.0,  -3438.0, 6.0, Color(0.78, 0.78, 0.82))
			_ri(ox - 83.0,  -3430.0, 6.0, 7.0, Color(0.78, 0.78, 0.82))
			_ri(ox - 86.0,  -3425.0, 12.0, 3.0, Color(0.78, 0.78, 0.82))


# ── Joystick ──────────────────────────────────────────────────────────────────

func _create_joystick() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	joystick_base = Polygon2D.new()
	joystick_base.color = Color(1, 1, 1, 0.15)
	joystick_base.polygon = _circle_polygon(JOYSTICK_RADIUS)
	joystick_base.visible = false
	layer.add_child(joystick_base)
	joystick_stick = Polygon2D.new()
	joystick_stick.color = Color(1, 1, 1, 0.35)
	joystick_stick.polygon = _circle_polygon(STICK_RADIUS)
	joystick_stick.visible = false
	layer.add_child(joystick_stick)


func _circle_polygon(r: float, segments: int = 32) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(segments):
		var a := 2.0 * PI * i / segments
		pts.append(Vector2(cos(a) * r, sin(a) * r))
	return pts


# ── Input ─────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if furnish_menu_open:
		var menu_tap := Vector2(-9999, -9999)
		if event is InputEventScreenTouch and event.pressed:
			menu_tap = event.position
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			menu_tap = event.position
		if menu_tap.x > -9000:
			var panel := Rect2(20, 220, 350, 370)
			if not panel.has_point(menu_tap):
				_close_furnish_menu()
			else:
				var items := _room_items(_current_room_idx())
				for i in range(items.size()):
					var row_y := 280.0 + i * 50.0
					if menu_tap.y >= row_y and menu_tap.y < row_y + 48.0:
						_on_furnish_row_tapped(i)
						break
		get_viewport().set_input_as_handled()
		return

	var tap_pos := Vector2(-9999, -9999)
	if event is InputEventScreenTouch and event.pressed:
		tap_pos = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap_pos = event.position

	if furnish_button.visible and tap_pos.distance_to(FURNISH_BTN_CENTER) < FURNISH_BTN_RADIUS:
		_open_furnish_menu()
		get_viewport().set_input_as_handled()
		return

	if collect_button.visible and tap_pos.distance_to(COLLECT_BTN_CENTER) < COLLECT_BTN_RADIUS:
		_on_collect_pressed()
		get_viewport().set_input_as_handled()
		return

	if build_button.visible and tap_pos.distance_to(BUILD_BTN_CENTER) < BUILD_BTN_RADIUS:
		_on_build_pressed()
		get_viewport().set_input_as_handled()
		return

	if berry_button.visible and tap_pos.distance_to(BERRY_BTN_CENTER) < BERRY_BTN_RADIUS:
		_on_berry_pressed()
		get_viewport().set_input_as_handled()
		return

	if mushroom_button.visible and tap_pos.distance_to(MUSHROOM_BTN_CENTER) < MUSHROOM_BTN_RADIUS:
		_on_mushroom_collect_pressed()
		get_viewport().set_input_as_handled()
		return

	if give_button.visible and tap_pos.distance_to(KITCHEN_BTN_CENTER) < KITCHEN_BTN_RADIUS:
		_on_give_pressed()
		get_viewport().set_input_as_handled()
		return

	if eat_button.visible and tap_pos.distance_to(KITCHEN_BTN_CENTER) < KITCHEN_BTN_RADIUS:
		_on_eat_pressed()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventScreenTouch:
		if event.pressed and joystick_touch_id == -1:
			joystick_touch_id = event.index
			joystick_origin = event.position
			joystick_base.position = joystick_origin
			joystick_stick.position = joystick_origin
			joystick_base.visible = true
			joystick_stick.visible = true
		elif not event.pressed and event.index == joystick_touch_id:
			joystick_touch_id = -1
			touch_direction = Vector2.ZERO
			joystick_base.visible = false
			joystick_stick.visible = false

	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_id:
			_update_joystick(event.position)


func _update_joystick(touch_pos: Vector2) -> void:
	var offset := touch_pos - joystick_origin
	if offset.length() > JOYSTICK_RADIUS:
		offset = offset.normalized() * JOYSTICK_RADIUS
	touch_direction = offset / JOYSTICK_RADIUS
	joystick_stick.position = joystick_origin + offset


# ── Physics loop ──────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if game_over or not is_instance_valid(queen):
		return

	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	if dir.length_squared() < 0.01:
		dir = touch_direction
	if dir.length() > 1.0:
		dir = dir.normalized()

	var actual_speed: float = QUEEN_SPEED * clampf(energy / ENERGY_START, 0.4, 1.5)
	queen.velocity = dir * actual_speed
	queen.move_and_slide()

	_update_energy(delta)

	if in_palace:
		_palace_bounds_and_exit()
		_update_servant(delta)
		_update_cooking(delta)
		var was_near := near_kitchen
		near_kitchen = queen.position.distance_to(KITCHEN_INTERACT_POS) < KITCHEN_INTERACT_RANGE
		if near_kitchen != was_near:
			_refresh_buttons()
	else:
		queen.position = queen.position.clamp(-WORLD_HALF, WORLD_HALF)
		_grow_trees(delta)
		_maybe_spawn_sapling(delta)
		_grow_berries(delta)
		_maybe_spawn_berry(delta)
		_grow_mushrooms(delta)
		_maybe_spawn_mushroom(delta)
		_update_nearest_tree()
		_update_nearest_berry()
		_update_nearest_mushroom()
		_update_palace_proximity()
		_check_palace_entry()
		_update_quest()
		_refresh_buttons()


func _palace_bounds_and_exit() -> void:
	var total_w: float = palace_num_rooms * ROOM_W
	var min_x: float = INTERIOR_ORIGIN.x - ROOM_W / 2.0 + WALL_T + 5.0
	var max_x: float = INTERIOR_ORIGIN.x + total_w - ROOM_W / 2.0 - WALL_T - 5.0
	var min_y: float = INTERIOR_ORIGIN.y - ROOM_H / 2.0 + WALL_T + 5.0
	var max_y: float = INTERIOR_ORIGIN.y + ROOM_H / 2.0

	queen.position.x = clampf(queen.position.x, min_x, max_x)
	queen.position.y = clampf(queen.position.y, min_y, max_y)

	# Exit: walk through any room's bottom door
	var at_exit_y: bool = queen.position.y >= INTERIOR_ORIGIN.y + ROOM_H / 2.0 - WALL_T / 2.0
	if at_exit_y:
		for r in range(palace_num_rooms):
			var room_cx: float = INTERIOR_ORIGIN.x + r * ROOM_W
			if absf(queen.position.x - room_cx) < EXIT_W / 2.0:
				exit_palace_idx = r
				_exit_palace()
				return


func _check_palace_entry() -> void:
	for i in range(palaces.size()):
		var p: Dictionary = palaces[i]
		if p.stage < TOTAL_STAGES:
			continue
		var entrance: Vector2 = p.pos + Vector2(0.0, 10.0)
		if queen.position.distance_to(entrance) < PALACE_ENTER_DIST:
			active_palace_idx = i
			_enter_palace()
			return


func _update_nearest_tree() -> void:
	var closest = null
	var closest_dist := COLLECT_RANGE
	for data in trees:
		if not is_instance_valid(data.node) or data.growth < 1.0:
			continue
		var d := queen.position.distance_to(data.node.position)
		if d < closest_dist:
			closest_dist = d
			closest = data
	nearest_tree_data = closest
	_refresh_buttons()


func _update_palace_proximity() -> void:
	var prev := active_palace_idx
	active_palace_idx = -1
	for i in range(palaces.size()):
		if queen.position.distance_to(palaces[i].pos) < PALACE_RANGE:
			active_palace_idx = i
			break
	if active_palace_idx != prev:
		_update_ui()
		_refresh_buttons()


# ── Helpers ───────────────────────────────────────────────────────────────────

# ── Quest: flower delivery ─────────────────────────────────────────────────────

func _create_quest() -> void:
	quest_npc_node = _make_npc_node()
	quest_npc_node.position = NPC_POS
	add_child(quest_npc_node)

	quest_flower_node = _make_flower_node()
	quest_flower_node.position = FLOWER_POS
	add_child(quest_flower_node)


func _make_npc_node() -> Node2D:
	var n := Node2D.new()
	var body := ColorRect.new()
	body.color = Color(0.85, 0.65, 0.40)
	body.size = Vector2(18, 22)
	body.position = Vector2(-9, -11)
	n.add_child(body)
	var head := Polygon2D.new()
	head.color = Color(0.90, 0.72, 0.50)
	head.polygon = _circle_polygon(9)
	head.position = Vector2(0, -20)
	n.add_child(head)
	var hat := Polygon2D.new()
	hat.color = Color(0.40, 0.60, 0.30)
	hat.polygon = PackedVector2Array([Vector2(0,-16), Vector2(-10,-5), Vector2(10,-5)])
	hat.position = Vector2(0, -27)
	n.add_child(hat)
	n.z_index = 5
	return n


func _make_flower_node() -> Node2D:
	var f := Node2D.new()
	var stem := ColorRect.new()
	stem.color = Color(0.25, 0.65, 0.20)
	stem.size = Vector2(3, 14)
	stem.position = Vector2(-1, 0)
	f.add_child(stem)
	for angle in [0.0, 72.0, 144.0, 216.0, 288.0]:
		var petal := Polygon2D.new()
		petal.color = Color(0.95, 0.30, 0.60)
		petal.polygon = _circle_polygon(6)
		var rad := deg_to_rad(angle)
		petal.position = Vector2(cos(rad) * 8, sin(rad) * 8 - 10)
		f.add_child(petal)
	var center := Polygon2D.new()
	center.color = Color(1.0, 0.90, 0.10)
	center.polygon = _circle_polygon(5)
	center.position = Vector2(0, -10)
	f.add_child(center)
	f.z_index = 5
	return f


func _update_quest() -> void:
	if quest_state == "done":
		var was_near := quest_near_npc
		quest_near_npc = (
			is_instance_valid(quest_npc_node)
			and queen.position.distance_to(NPC_POS) < NPC_TALK_RANGE
		)
		quest_near_flower = false
		if quest_near_npc != was_near:
			_refresh_quest_dialog()
		return

	var prev_near_npc := quest_near_npc
	var prev_near_flower := quest_near_flower

	quest_near_npc = (
		is_instance_valid(quest_npc_node)
		and queen.position.distance_to(NPC_POS) < NPC_TALK_RANGE
	)
	quest_near_flower = (
		quest_state == "waiting"
		and is_instance_valid(quest_flower_node)
		and queen.position.distance_to(FLOWER_POS) < FLOWER_PICK_RANGE
	)

	# Pick up flower
	if quest_near_flower:
		quest_flower_node.queue_free()
		quest_flower_node = null
		quest_state = "carrying"
		quest_near_flower = false
		_attach_carried_flower()

	# Deliver flower
	if quest_state == "carrying" and quest_near_npc:
		quest_state = "done"
		_drop_carried_flower()
		tree_inventory += QUEST_REWARD_WOOD
		_update_ui()

	if quest_near_npc != prev_near_npc or quest_near_flower != prev_near_flower:
		_refresh_quest_dialog()


func _attach_carried_flower() -> void:
	quest_carried_flower_node = _make_flower_node()
	quest_carried_flower_node.scale = Vector2(0.6, 0.6)
	quest_carried_flower_node.position = Vector2(-26, -18)
	quest_carried_flower_node.z_index = 11
	queen.add_child(quest_carried_flower_node)
	_refresh_quest_dialog()


func _drop_carried_flower() -> void:
	if quest_carried_flower_node != null and is_instance_valid(quest_carried_flower_node):
		quest_carried_flower_node.queue_free()
	quest_carried_flower_node = null
	_refresh_quest_dialog()


func _refresh_quest_dialog() -> void:
	if quest_dialog_layer != null and is_instance_valid(quest_dialog_layer):
		quest_dialog_layer.queue_free()
	quest_dialog_layer = null

	var msg := ""
	if quest_near_npc:
		match quest_state:
			"waiting":
				msg = "Bitte hilf mir!\nIch brauche die\nbesondere Blume,\ndie im Südwesten wächst."
			"carrying":
				msg = "Du hast sie gefunden!\nBring sie mir\nbitte!"
			"done":
				msg = "Vielen Dank!\nHier, nimm 10 Holz\nals Geschenk!"
	elif quest_near_flower and quest_state == "waiting":
		msg = "Eine besondere Blume!\nAufnehmen?"

	if msg == "":
		return

	quest_dialog_layer = CanvasLayer.new()
	add_child(quest_dialog_layer)

	var bubble := PanelContainer.new()
	bubble.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	bubble.offset_top = 60
	bubble.offset_left = -120
	bubble.offset_right = 120
	quest_dialog_layer.add_child(bubble)

	var vbox := VBoxContainer.new()
	bubble.add_child(vbox)

	var label := Label.new()
	label.text = msg
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(label)

	if quest_state == "done" and quest_near_npc:
		var timer := get_tree().create_timer(3.0)
		timer.timeout.connect(func() -> void:
			if quest_dialog_layer != null and is_instance_valid(quest_dialog_layer):
				quest_dialog_layer.queue_free()
				quest_dialog_layer = null
		)


func _random_world_pos(min_dist_from_origin: float) -> Vector2:
	var pos := Vector2.ZERO
	for _i in range(50):
		pos = Vector2(
			randf_range(-WORLD_HALF.x + 60, WORLD_HALF.x - 60),
			randf_range(-WORLD_HALF.y + 60, WORLD_HALF.y - 60)
		)
		var ok: bool = pos.distance_to(Vector2.ZERO) >= min_dist_from_origin
		for p in palaces:
			if pos.distance_to(p.pos) < 150:
				ok = false
				break
		if ok:
			return pos
	return pos
