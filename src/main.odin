package main

import "core:container/intrusive/list"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

import rl "vendor:raylib"

import mu "my:shared/microui-odin"
import "my:shared/rlmui"

Panel :: struct {
	using node: list.Node,
	title:      string,
	rect:       mu.Rect,
}

panel_list: list.List
panel_count: u32
prev_panel: ^Panel
hot_panel: ^Panel
vertical_width: u32

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE})
	rl.InitWindow(1280, 720, "Example");defer rl.CloseWindow()
	rl.SetWindowMinSize(320, 240)

	ctx := rlmui.InitUIScope()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing();defer rl.EndDrawing()

		rl.ClearBackground(rl.WHITE)

		rlmui.BeginUIScope()

		// Add left
		if rl.IsKeyReleased(.F1) {
			length := fmt.fprintf(-1, "%d", panel_count)

			buf: [dynamic]byte
			buf = make([dynamic]byte, length);defer delete(buf)

			title := strconv.itoa(buf[:], int(panel_count))

			panel := new(Panel)
			panel.title = strings.clone(title)
			list.push_back(&panel_list, &panel.node)

			if panel_count == 0 {
				panel.rect = {0, 0, rl.GetScreenWidth(), rl.GetScreenHeight()}
			} else {
				prev_panel.rect.w /= 2
				vertical_width += u32(prev_panel.rect.w)

				// TODO: Add new function mu.update_container(ctx, "title", {0, 0, 0, 0})
				win := mu.get_container(ctx, prev_panel.title);win.rect = panel.rect

				panel.rect = {i32(vertical_width), 0, prev_panel.rect.w, prev_panel.rect.h}
			}

			prev_panel = panel
			panel_count += 1
		}
		// Add Right
		if rl.IsKeyReleased(.F2) {
			panel_count = 0
		}

		prev_panel: ^Panel
		iter := list.iterator_head(panel_list, Panel, "node")
		for panel in list.iterate_next(&iter) {
			if prev_panel != nil {
				panel.rect.x = prev_panel.rect.w
				mu.get_container(ctx, panel.title).rect = panel.rect
			}

			mu.window(ctx, panel.title, panel.rect, {.NO_CLOSE, .NO_RESIZE})

			if rl.IsMouseButtonDown(.LEFT) {
				if mu.mouse_over(ctx, panel.rect) {
					if i32(rl.GetMousePosition().x) - panel.rect.x >= panel.rect.w - 10 {
						hot_panel = panel
					}
				}
			} else {
				hot_panel = nil
			}

			prev_panel = panel
		}

		if hot_panel != nil {
			hot_panel.rect.w += i32(rl.GetMouseDelta().x)
			// TODO: Add new function mu.update_container(ctx, "title", {0, 0, 0, 0})
			mu.get_container(ctx, hot_panel.title).rect = hot_panel.rect

			fmt.println(hot_panel)
		}

		free_all(context.temp_allocator)
	}
}
