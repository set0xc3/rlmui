package main

import "core:container/intrusive/list"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

import rl "vendor:raylib"

import mu "my:shared/microui-odin"
import "my:shared/rlmui"

Direction :: enum {
	Left,
	Right,
	Up,
	Down,
}

DockPanel :: struct {
	using node: list.Node,
	title:      string,
	rect:       mu.Rect,
}

DockLayout :: struct {
	panels:      list.List,
	panel_count: int,
	root_panel:  ^DockPanel,
	hot_panel:   ^DockPanel,
}

rlmui_ctx: ^mu.Context
dock_layout_ctx: DockLayout

dock_layout_add_root_panel :: proc() {
	using dock_layout_ctx

	length := fmt.fprintf(-1, "%d", panel_count)
	buf: [dynamic]byte
	buf = make([dynamic]byte, length);defer delete(buf)
	title := strconv.itoa(buf[:], panel_count)

	panel := new(DockPanel)
	panel.title = strings.clone(title)
	panel.rect = {0, 0, rl.GetScreenWidth(), rl.GetScreenHeight()}

	root_panel = panel

	list.push_back(&panels, &panel.node)
	panel_count += 1
}

dock_layout_add_panel :: proc(dir: Direction) {
	using dock_layout_ctx

	length := fmt.fprintf(-1, "%d", panel_count)
	buf: [dynamic]byte
	buf = make([dynamic]byte, length);defer delete(buf)
	title := strconv.itoa(buf[:], panel_count)

	panel := new(DockPanel)
	panel.title = strings.clone(title)

	if dir == .Left {
		panel.rect = {root_panel.rect.x, root_panel.rect.y, 200, rl.GetScreenHeight()}
		root_panel.rect.x += 200
		root_panel.rect.w -= 200
	} else if dir == .Right {
		root_panel.rect.w -= 200
		panel.rect = {
			root_panel.rect.x + root_panel.rect.w,
			root_panel.rect.h,
			200,
			rl.GetScreenHeight(),
		}
		panel.rect.y -= root_panel.rect.h
	} else if dir == .Up {
		panel.rect = {root_panel.rect.x, root_panel.rect.y, root_panel.rect.w, 200}
		root_panel.rect.y += 200
		root_panel.rect.h -= 200
	} else if dir == .Down {
		root_panel.rect.h -= 200
		panel.rect = {
			root_panel.rect.x,
			root_panel.rect.y + root_panel.rect.h,
			root_panel.rect.w,
			200,
		}
	}

	list.push_back(&panels, &panel.node)
	panel_count += 1
}

dock_layout_init :: proc() {
	using dock_layout_ctx

	//dock_layout_ctx.panel_left.rect = {0, 0, 200, 720}
	//
	//dock_layout_ctx.panel_center.rect = {dock_layout_ctx.panel_left.rect.w, 0, 1280, 720}
	//dock_layout_ctx.panel_center.rect.w -= dock_layout_ctx.panel_left.rect.w
	//
	//dock_layout_ctx.panel_right.rect = {1280 - 200, 0, 200, 720}
	//dock_layout_ctx.panel_center.rect.w -= dock_layout_ctx.panel_right.rect.w
	//
	//dock_layout_ctx.panel_down.rect = {0, 720 - 200, 1280, 200}
	//dock_layout_ctx.panel_left.rect.h -= dock_layout_ctx.panel_down.rect.h
	//dock_layout_ctx.panel_center.rect.h -= dock_layout_ctx.panel_down.rect.h
	//dock_layout_ctx.panel_right.rect.h -= dock_layout_ctx.panel_down.rect.h

	dock_layout_add_root_panel()
	dock_layout_add_panel(.Left)
	dock_layout_add_panel(.Left)
	dock_layout_add_panel(.Left)
	dock_layout_add_panel(.Left)
	dock_layout_add_panel(.Down)
	dock_layout_add_panel(.Down)
}

dock_layout_update :: proc() {
	using dock_layout_ctx

	//mu.window(rlmui_ctx, "#window:left", dock_layout_ctx.panel_left.rect)
	//mu.window(rlmui_ctx, "#window:center", dock_layout_ctx.panel_center.rect)
	//mu.window(rlmui_ctx, "#window:right", dock_layout_ctx.panel_right.rect)
	//mu.window(rlmui_ctx, "#window:down", dock_layout_ctx.panel_down.rect)

	iterator_head := list.iterator_head(panels, DockPanel, "node")
	for _panel in list.iterate_next(&iterator_head) {
		panel: ^DockPanel = _panel
		mu.window(rlmui_ctx, panel.title, panel.rect)
		mu.get_container(rlmui_ctx, panel.title).rect = panel.rect
	}
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE})
	rl.InitWindow(1280, 720, "Example");defer rl.CloseWindow()
	rl.SetWindowMinSize(320, 240)

	rlmui_ctx = rlmui.InitUIScope()
	dock_layout_init()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing();defer rl.EndDrawing()

		rl.ClearBackground(rl.WHITE)

		rlmui.BeginUIScope()

		dock_layout_update()

		// Add left
		if rl.IsKeyReleased(.F1) {
		}
		// Add Right
		if rl.IsKeyReleased(.F2) {
		}

		free_all(context.temp_allocator)
	}
}
