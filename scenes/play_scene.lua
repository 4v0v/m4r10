Play_scene = Scene:extend('Play_scene')

function Play_scene:new()
	Play_scene.super.new(@)

	@.physics = Physics()

	@.map = sti('assets/tiled/lua/level1.lua')
	@.map.layers.solid.visible = false


	for @.map.layers.solid.objects do 
		@.physics:add_rectangle(it.x, it.y, it.width, it.height)
	end

	-- print(@.map.layers.solid.objects[1])
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)


	if pressed('escape') then change_scene_with_transition('menu') end
end

function Play_scene:draw_inside_camera_bg()
	@.map:draw(0, 0, 1, 1)

	@.physics:draw()
end
