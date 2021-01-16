function love.load()
	WIDTH = 1280
	HEIGHT = 720
	love.window.setMode(WIDTH, HEIGHT)
	love.window.setTitle("boilerplate!")

	BASE_FONTSIZE = 24
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
	
	-- MUSIC = love.audio.newSource("sound/bgmusic.mp3", "stream")
	-- MUSIC:setLooping(true)
	-- MUSIC:play()
	
	t = 0
	
	love.mouse.setVisible(false)

	PLAYER1 = {x=250, y=250, children={}, radius=30, owner=1}
	PLAYER2 = {x=300, y=600, children={}, radius=30, owner=2}
	
	player_selections = {PLAYER1, PLAYER2}
	
	screen = SCREEN.splash
	turn = TURN.p1
	moving_time = 0
	
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
	if node.owner == 1 then
		love.graphics.setColor(1, 0, 1)
	elseif node.owner == 2 then
		love.graphics.setColor(1, 1, 0)
	else
		love.graphics.setColor(1, 0, 0)
	end
	if node.backlink ~= nil and #node.backlink >= 4 then
		love.graphics.line(node.backlink)
	end
	love.graphics.circle("fill", node.x, node.y, node.radius)
	if node == player_selections[1] or node == player_selections[2] then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.circle("line", node.x, node.y, node.radius + 2)
	end
	if node.children ~= nil then
		for i, child in ipairs(node.children) do
			draw_node_and_children(child)
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
	
	love.graphics.print(TURN_STRS[turn], 50, 50)
	
	draw_node_and_children(PLAYER1)
	draw_node_and_children(PLAYER2)
	
	-- selected indicator
	love.graphics.setColor(1, 1, 1, 0.5)
	if turn == TURN.p1 then
		love.graphics.circle("line", player_selections[1].x, player_selections[1].y, CLICK_RADIUS)
	elseif turn == TURN.p2 then
		love.graphics.circle("line", player_selections[2].x, player_selections[2].y, CLICK_RADIUS)
	end
	
	-- mouse
	draw_cursor()
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
		end
	end
end

function add_child(node, x_offs, y_offs, radius, backlink)
	child = {
		x=node.x + x_offs,
		y=node.y + y_offs,
		parent=node,
		backlink=backlink,
		radius=radius,
		owner=node.owner
	}
	if node.children == nil then
		node.children = {}
	end
	node.children[#node.children + 1] = child
	player_selections[node.owner] = child
	return child
end


function begin_game()
	screen = SCREEN.game
	
	-- testing
	-- add_child(
	-- 	PLAYER1, 200, 10, 15,
	-- 	{PLAYER1.x, PLAYER1.y, PLAYER1.x + 50, PLAYER1.y + 50, PLAYER1.x + 200, PLAYER1.y + 10}
	-- )
end


function hypot(dx, dy)
	return math.sqrt(dx * dx + dy * dy)
end


function attempt_to_make_move(selected, click_x, click_y)
	if hypot(selected.x - click_x, selected.y - click_y) < CLICK_RADIUS_NICE then
		add_child(
			selected,
			math.random(10, 200),
			math.random(-50, 50),
			20,
			{}
		)
		return true
	end
	return false
end



function love.mousepressed(x, y, button, istouch, presses)
	if screen == SCREEN.splash then
		begin_game()
		return
	end
	
	if turn == TURN.p1 then
		if attempt_to_make_move(player_selections[1], x, y) then
			turn = TURN.p1_moving
		end
	elseif turn == TURN.p2 then
		if attempt_to_make_move(player_selections[2], x, y) then
			turn = TURN.p2_moving
		end
	end
end


function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
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