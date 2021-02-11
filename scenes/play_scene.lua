Play_scene = Scene:extend('Play_scene')

function Play_scene:new()
	Play_scene.super.new(@)

	@.gravity = 9.8
end

function Play_scene:enter()
	@:kill_all_entities()

	@.trigger:destroy()

	@.player = {
		w   = 50,
		h   = 50,
		pos = Vec2(400, 0),
		vel = Vec2(0, 0),
		can_jump = false
	}

	@.ground = { 
		x = 50, 
		y = 450, 
		w = 8000, 
		h = 50
	}

	@.goal = {
		x = 550, 
		y = 400, 
		w = 50, 
		h = 50
	}

	@:add('cam_rect', Rectangle(300, 300, 300, 600, {centered = true, visible = false} ))
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	if pressed('escape') then change_scene_with_transition('menu') end

	local restart_btn = @:get('restart_btn')
	if restart_btn then
		if point_rect_collision({lm:getX(), lm:getY()}, restart_btn:aabb()) then
			@:once(fn() restart_btn.scale_spring:change(1.5) end, 'is_inside_play')
			if pressed('m_1') then @:enter() end
		else 
			if @.trigger:remove('is_inside_play') then restart_btn.scale_spring:change(1) end
		end
	else
		if down('q') then
			@.player.vel.x = -400
		end

		if down('d') then 
			@.player.vel.x = 400
		end

		if !down('q') && !down('d') then
			@.player.vel.x = 0
		end

		if pressed('space') && @.player.can_jump then 
			@.player.vel.y = -800
			@.player.can_jump = false
		end
		
		@.player.vel.y += @.gravity * 2

		@.player.pos += @.player.vel * dt
	end

	if rect_rect_collision(@.ground, {@.player.pos.x, @.player.pos.y, @.player.w, @.player.h}) then 
		@.player.pos.y = @.ground.y - @.player.w
		@.player.vel.y = 0
		@.player.can_jump = true
	end

	if rect_rect_collision(@.goal, {@.player.pos.x, @.player.pos.y, @.player.w, @.player.h}) then 
		@:once(fn() @:add('restart_btn', Text(lg.getWidth()/2, lg.getHeight()/2, "Restart ?", 
			{
				font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
				centered       = true,
				outside_camera = true,
			})
		) end, 'add_restart_button')
	end


	local cam_rect = @:get('cam_rect')

	if cam_rect then
		if @.player.pos.x < cam_rect:left() then
			cam_rect:set_left(@.player.pos.x)
		end
		if @.player.pos.x > cam_rect:right() then
			cam_rect:set_right(@.player.pos.x)
			
		end

		@:follow(cam_rect.pos)
	end
end

function Play_scene:draw_inside_camera_fg()
	lg.setColor(COLORS.YELLOW)
	lg.rectangle('fill', @.ground.x, @.ground.y, @.ground.w, @.ground.h)

	lg.setColor(COLORS.CYAN)
	lg.rectangle('fill', @.player.pos.x, @.player.pos.y, @.player.w, @.player.h)

	lg.setColor(COLORS.RED)
	lg.rectangle('fill', @.goal.x, @.goal.y, @.goal.w, @.goal.h)
end

function Play_scene:draw_outside_camera_bg()
	local restart_btn = @:get('restart_btn')
	if restart_btn then
		lg.setColor(0, 0, 0, .4)
		lg.rectangle('fill', 0, 0, lg.getWidth(), lg.getHeight())
	end
end
