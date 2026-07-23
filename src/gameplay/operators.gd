extends Node

# operator ids
const EQUALITY := 10
const ADDITION := 11
const MULTIPLICATION := 12
const SUBTRACTION := 13
const MOVEMENT := 14
const SWAPIFICATION := 15

func get_numerical_neighbours(left, right, up, down):
	var output = []
	if left != null and left.is_number(): output.append(left)
	if right != null and right.is_number(): output.append(right)
	if up != null and up.is_number(): output.append(up)
	if down != null and down.is_number(): output.append(down)
	return output

func add(slf, left, right, up, down):
	var numerical_neighbours = get_numerical_neighbours(left, right, up, down)
	if len(numerical_neighbours) < 2: return

	var sum = 0
	for block in numerical_neighbours:
		sum += block.get_type()
		block.destroy()
	sum = sum % 10

	slf.next_state = sum

func multiply(slf, left, right, up, down):
	var numerical_neighbours = get_numerical_neighbours(left, right, up, down)
	if len(numerical_neighbours) < 2: return

	var sum = 1
	for block in numerical_neighbours:
		sum *= block.get_type()
		block.destroy()
	sum = sum % 10

	slf.next_state = sum

func subtract(slf, left, right):
	if left == null or left.is_operator(): return
	if right == null or right.is_operator(): return

	var difference = abs(left.get_type() - right.get_type())
	left.destroy()
	right.destroy()
	slf.next_state = difference

func eq(slf, left, right, make_block_at):
	if left != null and right != null: return
	if left == null and right == null: return
	if (left != null and left.is_operator()) or (right != null and right.is_operator()): return

	var next_state = left.get_type() if left != null else right.get_type()
	
	if left == null:
		make_block_at.call(slf.get_grid_position() - Vector2(1, 0), next_state, false)
	elif right == null:
		make_block_at.call(slf.get_grid_position() + Vector2(1, 0), next_state, false)
	
	slf.destroy()

func move(slf, left, right, make_block_at):
	if left != null and right != null: return
	if left == null and right == null: return
	if (left != null and left.is_operator()) or (right != null and right.is_operator()): return

	var next_state = left.get_type() if left != null else right.get_type()
	
	if left == null:
		make_block_at.call(slf.get_grid_position() - Vector2(1, 0), next_state, false)
		right.destroy()
	elif right == null:
		make_block_at.call(slf.get_grid_position() + Vector2(1, 0), next_state, false)
		left.destroy()
	
	slf.destroy()

func swap(slf, left, right):
	if left == null or left.is_operator(): return
	if right == null or right.is_operator(): return

	left.next_state = right.get_type()
	right.next_state = left.get_type()
	slf.destroy()
