Play_scene = Scene:extend('Play_scene')

function Play_scene:new()
	Play_scene.super.new(@)

	@.gravity = 10
end

function Play_scene:enter()
	@:remove_all_triggers()

	@:kill_all_entities()

	local player = @:add('player', Rectangle(400,  0, 50, 50, {color = COLORS.CYAN, centered = true}))
	player.vel            = Vec2(0, 0)
	player.can_jump       = false
	player.can_doublejump = false

	@:add('ground', Rectangle(50,  450, 1000, 50, {color = COLORS.YELLOW, mode= 'fill'}))
	@:add('goal', Rectangle(550,  400, 50, 50, {color = COLORS.RED, mode= 'fill'}))
	@:add('cam_rect', Rectangle(300, 300, 300, 600, {centered = true, visible = false} ))



	@:chain({
		fn() return pressed('space') end, 
		fn() print('one') end,

		1, 
		fn() print('two')   end,

		1, 
		fn() print('three') end,

		3, 
		fn() @:during(3, fn() print('hello') end, 'during') end,

		fn() return !@.trigger:get('during') end, 
		fn() @:every(2, fn() print('every') end, 3, 'every') end,

		fn() return !@.trigger:get('every') end, 
		fn() end,

		1, 
		fn() print('five') end,

		1, 
		fn() print('six') end,
	}, 'test')


end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	if pressed('escape') then change_scene_with_transition('menu') end

	local player      = @:get('player')
	local ground      = @:get('ground')
	local goal        = @:get('goal')
	local cam_rect    = @:get('cam_rect')
	local restart_btn = @:get('restart_btn')

	if restart_btn then
		if point_rect_collision({lm:getX(), lm:getY()}, restart_btn:aabb()) then
			@:once(fn() restart_btn.scale_spring:change(1.5) end, 'is_inside_play')
			if pressed('m_1') then @:enter() end
		else 
			if @:remove_trigger('is_inside_play') then restart_btn.scale_spring:change(1) end
		end
	else
		if down('q') then
			player.vel.x -= 10
		end

		if down('d') then 
			player.vel.x += 10
		end

		if !down('q') && !down('d') then
			if math.abs(player.vel.x) < 10 then 
				player.vel.x = 0
			else
				player.vel.x -= 10 * sign(player.vel.x)
			end
		end

		if pressed('space') && player.can_doublejump then 
			player.vel.y          = -400
			player.can_doublejump = false
		end

		if pressed('space') && player.can_jump then
			player.vel.y          = -800
			player.can_jump       = false
			player.can_doublejump = true
		end

		player.vel.y += @.gravity  * 2
		player.pos   += player.vel * dt
	end

	if ground && player && rect_rect_collision(ground:aabb(), player:aabb()) then 
		player:set_bottom(ground.pos.y)
		player.vel.y    = 0
		player.can_jump = true
	end

	if goal && player && !restart_btn && rect_rect_collision(goal:aabb(), player:aabb()) then
		@:add('restart_btn', Text(lg.getWidth()/2, lg.getHeight()/2, "Restart ?",
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		}))
	end

	if cam_rect then
		if   player.pos.x < cam_rect:left()  then
			cam_rect:set_left(player.pos.x)
		elif player.pos.x > cam_rect:right() then
			cam_rect:set_right(player.pos.x)
		end
		@:follow(cam_rect.pos)
	end
end

function Play_scene:draw_outside_camera_bg()
	local restart_btn = @:get('restart_btn')
	if restart_btn then
		lg.setColor(0, 0, 0, .4)
		lg.rectangle('fill', 0, 0, lg.getWidth(), lg.getHeight())
	end
end
