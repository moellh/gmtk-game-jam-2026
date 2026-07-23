extends "res://src/game.gd"

const COURSE_SOURCE_ID := 0

const LEFT_COLUMN := 5
const RIGHT_COLUMN := 20
const CEILING_ROW := 1
const FLOOR_ROW := 7
const FOUNDATION_ROW := 8
const GATE_OPENING_TOP_ROW := 5
const GATE_OPENING_BOTTOM_ROW := 6

const GATE_COLUMNS: Array[int] = [10, 15]
const STEP_CELLS: Array[Vector2i] = [
	Vector2i(12, 6),
	Vector2i(17, 6),
]

const TILE_FLOOR := Vector2i(16, 5)
const TILE_FOUNDATION := Vector2i(16, 7)
const TILE_FOUNDATION_LEFT := Vector2i(15, 7)
const TILE_FOUNDATION_RIGHT := Vector2i(17, 7)
const TILE_CEILING := Vector2i(16, 12)
const TILE_CEILING_LEFT := Vector2i(15, 9)
const TILE_CEILING_RIGHT := Vector2i(17, 9)
const TILE_GATE_JOINT := Vector2i(16, 9)
const TILE_WALL := Vector2i(18, 10)
const TILE_WALL_FLOOR_LEFT := Vector2i(15, 6)
const TILE_WALL_FLOOR_RIGHT := Vector2i(17, 6)
const TILE_GATE_WALL := Vector2i(13, 10)
const TILE_GATE_CAP := Vector2i(13, 11)

@onready var course: TileMapLayer = $Course


func _ready() -> void:
	build_course()
	super()


func build_course() -> void:
	course.clear()

	for column in range(LEFT_COLUMN + 1, RIGHT_COLUMN):
		set_course_cell(Vector2i(column, CEILING_ROW), TILE_CEILING)
		set_course_cell(Vector2i(column, FLOOR_ROW), TILE_FLOOR)
		set_course_cell(Vector2i(column, FOUNDATION_ROW), TILE_FOUNDATION)

	set_course_cell(Vector2i(LEFT_COLUMN, CEILING_ROW), TILE_CEILING_LEFT)
	set_course_cell(Vector2i(RIGHT_COLUMN, CEILING_ROW), TILE_CEILING_RIGHT)

	for row in range(CEILING_ROW + 1, FLOOR_ROW):
		set_course_cell(Vector2i(LEFT_COLUMN, row), TILE_WALL)
		set_course_cell(Vector2i(RIGHT_COLUMN, row), TILE_WALL)

	set_course_cell(Vector2i(LEFT_COLUMN, FLOOR_ROW), TILE_WALL_FLOOR_LEFT)
	set_course_cell(Vector2i(RIGHT_COLUMN, FLOOR_ROW), TILE_WALL_FLOOR_RIGHT)
	set_course_cell(Vector2i(LEFT_COLUMN, FOUNDATION_ROW), TILE_FOUNDATION_LEFT)
	set_course_cell(Vector2i(RIGHT_COLUMN, FOUNDATION_ROW), TILE_FOUNDATION_RIGHT)

	for gate_column in GATE_COLUMNS:
		set_course_cell(Vector2i(gate_column, CEILING_ROW), TILE_GATE_JOINT)
		for row in range(CEILING_ROW + 1, GATE_OPENING_TOP_ROW - 1):
			set_course_cell(Vector2i(gate_column, row), TILE_GATE_WALL)
		set_course_cell(
			Vector2i(gate_column, GATE_OPENING_TOP_ROW - 1),
			TILE_GATE_CAP,
		)

	for step_cell in STEP_CELLS:
		set_course_cell(step_cell, TILE_FLOOR)


func set_course_cell(cell: Vector2i, atlas_coordinates: Vector2i) -> void:
	course.set_cell(cell, COURSE_SOURCE_ID, atlas_coordinates)


func gate_opening_cells(gate_column: int) -> Array[Vector2i]:
	return [
		Vector2i(gate_column, GATE_OPENING_TOP_ROW),
		Vector2i(gate_column, GATE_OPENING_BOTTOM_ROW),
	]


func gate_openings_are_clear() -> bool:
	for gate_column in GATE_COLUMNS:
		for cell in gate_opening_cells(gate_column):
			if course.get_cell_source_id(cell) != -1:
				return false
	return true
