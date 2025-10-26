extends Node
class_name HouseTimerInitializer

@export var HOUSE_TILE_ID: int = 1  # Replace with your actual house tile ID
@export var TIMER_SCENE: PackedScene = preload("res://scenes/3d/ui/PieTimerWorld.tscn")
var grid_map: GridMap

func _init() -> void:
	GameManager.OnGameManagerReady.connect(_on_game_manager_ready)

func _on_game_manager_ready() -> void:
	initialize_house_timers()

func initialize_house_timers() -> void:
	grid_map = GameManager.GetBuildingGridMap()

	# Step 1: Collect all house cells
	var house_cells = []
	var used_cells = grid_map.get_used_cells()

	for cell in used_cells:
		if grid_map.get_cell_item(cell) == HOUSE_TILE_ID:
			house_cells.append(cell)

	if house_cells.is_empty():
		print("No house tiles found!")
		return

	# Step 2: Attach timers to each house
	for cell in house_cells:
		var instance_id = grid_map.get_cell_instance_id(cell)
		if instance_id != -1:  # Valid instance
			var house_instance = grid_map.get_node(str(instance_id))

			if house_instance:
				# Create and attach the timer
				var timer_ui = TIMER_SCENE.instantiate()
				house_instance.add_child(timer_ui)

				# Position the timer 5 units above the house
				timer_ui.position.y = 5.0

				# Start the timer
				if timer_ui.has_method("start_timer"):
					timer_ui.start_timer(5.0)  # Example: 5-second timer

	print("Initialized timers for ", house_cells.size(), " houses.")

# Optional: Debug function to print tile IDs
func print_used_tile_ids(grid_map: GridMap) -> void:
	var used_cells = grid_map.get_used_cells()
	for cell in used_cells:
		var tile_id = grid_map.get_cell_item(cell)
		print("Cell at ", cell, " has tile ID: ", tile_id)
