extends Node

# operator ids
const EQUALITY := 10
const ADDITION := 11
const MULTIPLICATION := 12
const SUBTRACTION := 13
const LTR_MOVEMENT := 14
const SWAPIFICATION := 15

func get_numerical_neighbours(left, right, up, down):
	var neighbours = []
	if left != null and left.is_number(): neighbours.append(left)
	if right != null and right.is_number(): neighbours.append(right)
	if up != null and up.is_number(): neighbours.append(up)
	if down != null and down.is_number(): neighbours.append(down)
	return neighbours
	
func add(slf, left, right, up, down):
	var numerical_neighbours = get_numerical_neighbours(left, right, up, down)
	if len(numerical_neighbours) < 2: return

	var sum = 0
	for block in numerical_neighbours:
		sum += block.get_type()
		block.destroy()
	sum = sum % 10

	slf.next_type = sum

func multiply(slf, left, right, up, down):
	var numerical_neighbours = get_numerical_neighbours(left, right, up, down)
	if len(numerical_neighbours) < 2: return

	var product = 1
	for block in numerical_neighbours:
		product *= block.get_type()
		block.destroy()
	product = product % 10

	slf.next_type = product

func subtract(slf, left, right):
	if left == null or left.is_operator(): return
	if right == null or right.is_operator(): return

	var difference = abs(left.get_type() - right.get_type())
	left.destroy()
	right.destroy()
	slf.next_type = difference

func eq(slf, left, right, make_block_at):
	if left != null and right != null: return
	if left == null and right == null: return
	if (left != null and left.is_operator()) or (right != null and right.is_operator()): return

	var next_type = left.get_type() if left != null else right.get_type()
	
	if left == null:
		make_block_at.call(slf.get_grid_position() - Vector2(1, 0), next_type, false)
	elif right == null:
		make_block_at.call(slf.get_grid_position() + Vector2(1, 0), next_type, false)
	
	slf.destroy()

func move(slf, left, right, make_block_at):
	if left != null and right != null: return
	if left == null and right == null: return
	if (left != null and left.is_operator()) or (right != null and right.is_operator()): return

	var next_type = left.get_type() if left != null else right.get_type()
	
	if left == null:
		make_block_at.call(slf.get_grid_position() - Vector2(1, 0), next_type, false)
		right.destroy()
	elif right == null:
		make_block_at.call(slf.get_grid_position() + Vector2(1, 0), next_type, false)
		left.destroy()
	
	slf.destroy()

func swap(slf, left, right):
	if left == null or left.is_operator(): return
	if right == null or right.is_operator(): return

	left.next_type = right.get_type()
	right.next_type = left.get_type()
	slf.destroy()
