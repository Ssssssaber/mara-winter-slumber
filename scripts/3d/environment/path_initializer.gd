extends Node

@export var ROAD_TILE_ID : int = 0
@export var CELL_SIZE : Vector3 = Vector3(2, 2, 2)

func generate_path_from_roads(grid_map : GridMap) -> Path3D:
	# Step 1: Collect all road cells
	var road_cells = []
	var used_cells = grid_map.get_used_cells()
	for cell in used_cells:
		if grid_map.get_cell_item(Vector3(cell.x, cell.y, cell.z)) == ROAD_TILE_ID:
			road_cells.append(cell)

	if road_cells.is_empty():
		print("No road tiles found!")
		return

	# Step 2: Build the path by traversing the loop's perimeter
	var path_cells = traverse_loop(road_cells)
	if path_cells.is_empty():
		print("Could not trace a valid loop!")
		return

	# Step 3: Create the Path3D
	var path_3d = Path3D.new()
	var curve = Curve3D.new()

	for cell in path_cells:
		var world_pos = grid_map.map_to_local(cell)  # Gets the local position of the cell
		curve.add_point(world_pos)

	if path_cells.size() > 0:
		var start_pos = grid_map.map_to_local(path_cells[0])
		curve.add_point(start_pos)

	path_3d.curve = curve
	add_child(path_3d)
	print("Path3D created with ", path_cells.size(), " points (including loop closure).")
	return path_3d

func traverse_loop(road_cells: Array) -> Array:
	if road_cells.is_empty():
		return []

	# Convert road_cells to a set for fast lookup
	var road_set = {}
	for cell in road_cells:
		road_set[cell] = true

	# Find a starting cell on the perimeter (e.g., the one with the smallest X, then Z)
	var start_cell = road_cells[0]
	for cell in road_cells:
		if cell.x < start_cell.x or (cell.x == start_cell.x and cell.z < start_cell.z):
			start_cell = cell

	# Directions: 0=Z+, 1=X+, 2=Z-, 3=X- (clockwise)
	var directions = [Vector3i(0, 0, 1), Vector3i(1, 0, 0), Vector3i(0, 0, -1), Vector3i(-1, 0, 0)]
	var current = start_cell
	var facing = 0  # Start facing Z+
	var path = [current]
	var visited_edges = {}  # Track edges to avoid infinite loops

	while true:
		# Find the next cell by following the wall (right-hand rule)
		var next_cell = null
		var next_facing = facing

		# Turn right (check if we can move right; if not, it's a wall, so turn)
		var right_dir = (facing + 1) % 4
		var right_cell = current + directions[right_dir]
		if road_set.has(right_cell):
			# Can turn right, so do it and move forward
			next_facing = right_dir
			next_cell = right_cell
		else:
			# Can't turn right (wall), so move forward in current direction
			next_cell = current + directions[facing]

		# If next_cell is not a road, we hit a wall—turn left instead
		if not road_set.has(next_cell):
			next_facing = (facing - 1 + 4) % 4  # Turn left
			next_cell = current + directions[next_facing]
			if not road_set.has(next_cell):
				# Stuck—shouldn't happen in a loop, but break
				print("Stuck during traversal!")
				return []

		# Move to next_cell
		current = next_cell
		facing = next_facing

		# Check if we're back at start (and have moved enough)
		if current == start_cell and path.size() > 2:
			break

		# Avoid revisiting the same edge (to prevent loops within wide areas)
		var edge_key = str(current) + "_" + str(facing)
		if visited_edges.has(edge_key):
			print("Edge revisited—possible issue with loop shape.")
			return []
		visited_edges[edge_key] = true

		path.append(current)

	return path

# Optional: Function to print all tile IDs for debugging (call in _ready if needed)
func print_used_tile_ids(grid_map : GridMap):
	var used_cells = grid_map.get_used_cells()
	for cell in used_cells:
		var tile_id = grid_map.get_cell_item(Vector3(cell.x, cell.y, cell.z))
		print("Cell at ", cell, " has tile ID: ", tile_id)
