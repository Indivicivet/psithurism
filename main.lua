function love.load()
	WIDTH = 1280
	HEIGHT = 720
	love.window.setMode(WIDTH, HEIGHT)
	love.window.setTitle("boilerplate!")

	BASE_FONTSIZE = 24
	BASE_FONT = love.graphics.newFont("fonts/arial.ttf", BASE_FONTSIZE)
	
	SCREEN = {splash=1, game=2}
	
	screen = SCREEN.splash
	
	-- MUSIC = love.audio.newSource("sound/bgmusic.mp3", "stream")
	-- MUSIC:setLooping(true)
	-- MUSIC:play()
	
	t = 0
	
	love.mouse.setVisible(false)
	
	--screen = SCREEN.game -- for testing
	screen = SCREEN.splash -- for release
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


function love.draw()
	love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
	
	if screen == SCREEN.splash then
		-- splash screen
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(BASE_FONT)
		love.graphics.printf("SPLASH SCREEN", 0, 200, WIDTH, "center")

		draw_cursor()
		return
	end
	
	love.graphics.setColor(1, 1, 1)
	-- mouse
	draw_cursor()
end


function love.update(dt)
	t = t + dt
	
	if screen == SCREEN.splash then
		return
	end
end


function begin_game()
	screen = SCREEN.game
end



function love.mousepressed(x, y, button, istouch, presses)
	if screen == SCREEN.splash then
		begin_game()
		return
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