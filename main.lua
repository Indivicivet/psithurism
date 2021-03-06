function love.load()
	WIDTH = 1280
	HEIGHT = 720
	love.window.setMode(WIDTH, HEIGHT)
	love.window.setTitle("boilerplate!")

	BASE_FONTSIZE = 36
	BASE_FONT = love.graphics.newFont("fonts/arial.ttf", BASE_FONTSIZE)
	
	SCREEN = {splash=1, game=2}
	TURN = {p1=1, p2=2, p1_moving=3, p2_moving=4}
	TURN_STRS = {
		[TURN.p1]="Player 1's turn!",
		[TURN.p2]="Player 2's turn!",
		[TURN.p1_moving]="Player 1 is moving!",
		[TURN.p2_moving]="Player 2 is moving!"
	}
	
	CLICK_RADIUS = 200
	CLICK_RADIUS_NICE = 250
	TRAVEL_TIME = 1
	TRAVEL_STEPS = 4
	MAX_VELOCITY = CLICK_RADIUS / TRAVEL_TIME
	
	-- MUSIC = love.audio.newSource("sound/bgmusic.mp3", "stream")
	-- MUSIC:setLooping(true)
	-- MUSIC:play()
	
	WIND_VANE = {x=1000, y=150, scale=0.5}
	
	t = 0
	
	love.mouse.setVisible(false)
	
	screen = SCREEN.splash
	
	begin_game() -- for testing
end


function draw_sprite(sprite, x, y)
	-- mostly for things which have non-int coords, otherwise
	-- they get a weird alpha halo
	love.graphics.draw(
		sprite,
		math.floor((x or 0) + 0.5),
		math.floor((y or 0) + 0.5)
	)
end


function draw_cursor()
	mouse_x, mouse_y = love.mouse.getPosition()
	love.graphics.setColor(1, 0, 0, 0.7)
	love.graphics.circle("fill", mouse_x, mouse_y, 7)
end


function draw_node_and_children(node)
	if node.children ~= nil then
		for i, child in ipairs(node.children) do
			draw_node_and_children(child)
		end
	end
	if node.owner == 1 then
		love.graphics.setColor(1, 0, 1)
	elseif node.owner == 2 then
		love.graphics.setColor(1, 1, 0)
	else
		love.graphics.setColor(1, 0, 0)
	end
	if node.backlink ~= nil and #node.backlink >= 4 then
		love.graphics.line(node.backlink)
	elseif node.parent ~= nil then
		-- debug
		r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(0.5, 0, 0)
		love.graphics.line(node.parent.x, node.parent.y, node.x, node.y)
		love.graphics.setColor(r, g, b, a)
	end
	love.graphics.circle("fill", node.x, node.y, node.radius)
	if node == player_selections[1] or node == player_selections[2] then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.circle("line", node.x, node.y, node.radius + 2)
		if node.owner == turn then
			-- idk, do something to make it extra obvious :: todo improve
			love.graphics.circle("line", node.x, node.y, node.radius + 8)
		end
	end
end


function love.draw()
	love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
	love.graphics.setFont(BASE_FONT)
	
	if screen == SCREEN.splash then
		-- splash screen
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("SPLASH SCREEN", 0, 200, WIDTH, "center")

		draw_cursor()
		return
	end
	
	love.graphics.setColor(1, 1, 1)
	
	love.graphics.printf(TURN_STRS[turn], 50, 625, 300, "center")
	
	draw_node_and_children(player1)
	draw_node_and_children(player2)
	
	-- selected indicator
	love.graphics.setColor(1, 1, 1, 0.5)
	if turn == TURN.p1 then
		love.graphics.circle("line", player_selections[1].x, player_selections[1].y, CLICK_RADIUS)
	elseif turn == TURN.p2 then
		love.graphics.circle("line", player_selections[2].x, player_selections[2].y, CLICK_RADIUS)
	end
	
	-- wind indicator
	love.graphics.setColor(0.5, 0.5, 1)
	wind_vane_end = {x=WIND_VANE.x + wind.x * WIND_VANE.scale, y=WIND_VANE.y + wind.y * WIND_VANE.scale}
	love.graphics.circle("fill", WIND_VANE.x, WIND_VANE.y, 20)
	love.graphics.line(WIND_VANE.x, WIND_VANE.y, wind_vane_end.x, wind_vane_end.y)
	love.graphics.circle("fill", wind_vane_end.x, wind_vane_end.y, 10)
	
	-- mouse
	draw_cursor()
end


function add_node_and_children_to_pixel_objects(node)
	if node.backlink ~= nil then
		-- todo
	end
	-- fill in a circle within the square
	for y_offs = -node.radius, node.radius do
		for x_offs = -node.radius, node.radius do
			if hypot(x_offs, y_offs) <= node.radius then
				pixel_objects[math.floor(node.y + y_offs) * WIDTH + math.floor(node.x + x_offs)] = node
			end
		end
	end
	if node.children ~= nil then
		for i, child in ipairs(node.children) do
			add_node_and_children_to_pixel_objects(child)
		end
	end
end


function update_pixel_objects()
	pixel_objects = {}
	add_node_and_children_to_pixel_objects(player1)
	add_node_and_children_to_pixel_objects(player2)
end


function love.update(dt)
	t = t + dt
	
	if screen == SCREEN.splash then
		return
	end
	
	if turn == TURN.p1_moving or turn == TURN.p2_moving then
		moving_time = moving_time + dt
		if moving_time > 0.2 then
			moving_time = 0
			if turn == TURN.p1_moving then
				turn = TURN.p2
			else
				turn = TURN.p1
			end
			new_wind_amt = math.random(50, 300)
			new_wind_dir = 2 * math.pi * math.random()
			wind.x = new_wind_amt * math.cos(new_wind_dir)
			wind.y = new_wind_amt * math.sin(new_wind_dir)
		end
	end
end


-- got inlined
--function add_child(node, x_offs, y_offs, radius, backlink)


function begin_game()
	screen = SCREEN.game
	
	player1 = {x=250, y=250, children={}, radius=30, owner=1}
	player2 = {x=1000, y=600, children={}, radius=30, owner=2}
	
	player_selections = {player1, player2}
	
	pixel_objects = {} -- map from pixel pos 1D to what object lives there
	
	wind = {x=0, y=100}
	
	turn = TURN.p1
	moving_time = 0
end


function hypot(dx, dy)
	return math.sqrt(dx * dx + dy * dy)
end


function attempt_to_make_move(selected, click_x, click_y)
	dx = click_x - selected.x
	dy = click_y - selected.y
	click_dist = hypot(dx, dy)
	if click_dist < CLICK_RADIUS_NICE then
		-- check if we did the "nice clicking" but want to scale down to 1:
		if click_dist <= CLICK_RADIUS then
			vx = dx * MAX_VELOCITY / CLICK_RADIUS
			vy = dy * MAX_VELOCITY / CLICK_RADIUS
		else
			vx = dx * MAX_VELOCITY / click_dist
			vy = dy * MAX_VELOCITY / click_dist
		end
		-- initial_vx = vx
		-- initial_vy = vy
		
		x = selected.x
		y = selected.y
		backlink = {x, y}
		dt = TRAVEL_TIME / TRAVEL_STEPS
		for i = 1, TRAVEL_STEPS do
			-- Euler, for now. todo :: better?
			x = x + dt * vx
			y = y + dt * vy
			vx = vx + dt * wind.x
			vy = vy + dt * wind.y
			backlink[#backlink + 1] = x
			backlink[#backlink + 1] = y
		end
		child = {
			x=x,
			y=y,
			parent=selected,
			backlink=backlink,
			radius=10,
			owner=selected.owner
		}
		if selected.children == nil then
			selected.children = {}
		end
		selected.children[#selected.children + 1] = child
		player_selections[selected.owner] = child
		return true
	end
	return false
end


function love.mousepressed(m_x, m_y, button, istouch, presses)
	if screen == SCREEN.splash then
		begin_game()
		return
	end
	
	update_pixel_objects() -- is this the place? todo :: scratch head
		-- ^ don't do it here - makes spam clicking a laggy w/ large nodes
	clicked = pixel_objects[m_y * WIDTH + m_x]
	if clicked ~= nil and clicked.owner == turn then
		player_selections[turn] = clicked
	elseif turn == TURN.p1 then
		if attempt_to_make_move(player_selections[1], m_x, m_y) then
			turn = TURN.p1_moving
		end
	elseif turn == TURN.p2 then
		if attempt_to_make_move(player_selections[2], m_x, m_y) then
			turn = TURN.p2_moving
		end
	end
end


function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
	
	if key == "r" then
		begin_game()
	end
	
	-- if key == "m" then
	-- 	if MUSIC:isPlaying() then
	-- 		MUSIC:pause()
	-- 	else
	-- 		MUSIC:play()
	-- 	end
	-- end
	
	if screen == SCREEN.splash then
		begin_game()
		return
	end
	
end
