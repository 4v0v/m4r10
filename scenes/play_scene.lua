Play_scene = Scene:extend('Play_scene')

function Play_scene:new()
	Play_scene.super.new(@)
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	if pressed('escape') then change_scene_with_transition('menu') end
end
