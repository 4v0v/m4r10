Play_scene = Scene:extend('Play_scene')

function Play_scene:new()
	Play_scene.super.new(@)

	@.player = { 400, 0  , 50 , 50}
	@.ground = { 50 , 500, 700, 50}

	@.gravity = -5
	@.player_force = Tween(0)

	@.camera:set_position(400, 300)
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)
	@.player_force:update(dt)

	if pressed('escape') then change_scene_with_transition('menu') end


	local delta_x = @.player[1]
	local delta_y = @.player[2]

	if down('q') then delta_x -= 3 end
	if down('d') then delta_x += 3 end

	delta_y = @.player[2] - @.gravity - @.player_force:get()


	if !rect_rect_collision(@.ground, {delta_x, delta_y, @.player[3], self.player[4]}) then 
		@.player[2] = delta_y
	end

	@.player[1] = delta_x


	if pressed('space') then 
		print(@.player_force:get())
		@.player_force:tween(30, .3)
		@:after(.4, fn()@.player_force:tween(0, .3) end, 'jump')
	end

end

function Play_scene:draw_inside_camera_fg()
	lg.setColor(COLORS.YELLOW)
	lg.rectangle('fill', @.ground[1], @.ground[2], @.ground[3], @.ground[4])

	lg.setColor(COLORS.CYAN)
	lg.rectangle('fill', @.player[1], @.player[2], @.player[3], @.player[4])
end
