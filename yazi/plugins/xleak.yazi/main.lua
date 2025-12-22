local M = {}

local function as_lines(text)
	local lines = {}
	for line in (text or ""):gmatch("[^\n]+") do
		lines[#lines + 1] = line
	end
	return lines
end

local function render_error(job, message)
	ya.preview_widgets(job, { ui.Text({ message or "xleak failed" }):area(job.area):style(ui.Style():fg("red")) })
end

local function run_xleak(job)
	local height = math.max(job.area.h, 1)
	local width = math.max(job.area.w, 20)

	local output, err = Command("/opt/homebrew/bin/xleak")
		:arg("--export")
		:arg("text")
		:arg("--max-rows")
		:arg(tostring(job.skip + height))
		:arg("--max-width")
		:arg(tostring(width > 2 and width - 2 or width))
		:arg("--wrap")
		:arg(tostring(job.file.url))
		:env("NO_COLOR", "1")
		:env("COLUMNS", tostring(width))
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()

	if not output then
		return nil, err or "spawn xleak failed"
	end

	if output.status.code ~= 0 then
		local msg = output.stderr
		if not msg or msg == "" then
			msg = output.stdout
		end
		return nil, msg ~= "" and msg or "xleak exit code " .. tostring(output.status.code)
	end

	return as_lines(output.stdout)
end

function M:peek(job)
	local lines, err = run_xleak(job)
	if not lines then
		return render_error(job, err)
	end

	local height = math.max(job.area.h, 1)
	local start = job.skip + 1
	local finish = math.min(#lines, job.skip + height)

	local slice = {}
	for i = start, finish do
		slice[#slice + 1] = lines[i]
	end

	if #slice == 0 then
		slice[1] = "xleak: 无输出"
	end

	local max_w = math.max(job.area.w - 1, 1)
	for idx, line in ipairs(slice) do
		line = line or ""
		line = line:gsub("\t", " ")
		line = line:gsub("%s%s+", " ")
		line = line:gsub("%s+$", "")
		if #line > max_w then
			line = line:sub(1, max_w)
		end
		slice[idx] = line
	end

	ya.preview_widgets(job, { ui.Text(slice):area(job.area) })

	if job.skip > 0 and finish < job.skip + height then
		ya.manager_emit("peek", { math.max(0, #lines - height), only_if = job.file.url, upper_bound = true })
	end
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = math.floor(job.units * job.area.h / 10)
		ya.manager_emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
	end
end

return M
