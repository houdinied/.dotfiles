Name = "apps"
NamePretty = "Apps"
HideFromProviderlist = true
Cache = false
SearchName = false

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function split_paths(value)
  local paths = {}
  for path in (value or ""):gmatch("[^:]+") do
    table.insert(paths, path)
  end
  return paths
end

local function read_desktop_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local entry = { Path = path }
  local in_desktop_entry = false

  for line in file:lines() do
    local section = line:match("^%[(.-)%]$")
    if section then
      in_desktop_entry = section == "Desktop Entry"
    elseif in_desktop_entry then
      local key, value = line:match("^([%w%-]+)%s*=%s*(.*)$")
      if key and not key:match("%[") then
        entry[key] = value
      end
    end
  end

  file:close()
  return entry
end

local function should_show(entry)
  return entry
    and entry.Type == "Application"
    and entry.Name
    and entry.Exec
    and entry.Hidden ~= "true"
    and entry.NoDisplay ~= "true"
end

local function app_type(entry)
  if entry.Exec:match("^%s*omarchy%-launch%-webapp") or entry.Exec:match("^%s*omarchy%-webapp%-handler") then
    return "Webapp"
  end

  return "Native app"
end

local function add_desktop_files(entries, seen, applications_dir)
  local handle = io.popen("find " .. shell_quote(applications_dir) .. " -maxdepth 1 -type f -name '*.desktop' 2>/dev/null | sort")
  if not handle then
    return
  end

  for path in handle:lines() do
    local desktop_id = path:match("([^/]+)$")
    if desktop_id and not seen[desktop_id] then
      local entry = read_desktop_file(path)
      if should_show(entry) then
        local type_label = app_type(entry)
        seen[desktop_id] = true
        table.insert(entries, {
          Text = entry.Name,
          AppType = type_label,
          Icon = entry.Icon or "applications-other",
          Keywords = { desktop_id, entry.Name, type_label, entry.Exec },
          Actions = {
            open = "gtk-launch " .. shell_quote(desktop_id),
          },
        })
      end
    end
  end

  handle:close()
end

function GetEntries()
  local entries = {}
  local seen = {}
  local home = os.getenv("HOME")

  if home then
    add_desktop_files(entries, seen, home .. "/.local/share/applications")
  end

  local data_dirs = split_paths(os.getenv("XDG_DATA_DIRS") or "/usr/local/share:/usr/share")
  for _, data_dir in ipairs(data_dirs) do
    add_desktop_files(entries, seen, data_dir .. "/applications")
  end

  local types_by_name = {}
  for _, entry in ipairs(entries) do
    local key = entry.Text:lower()
    types_by_name[key] = types_by_name[key] or {}
    types_by_name[key][entry.AppType] = true
  end

  for _, entry in ipairs(entries) do
    local types = types_by_name[entry.Text:lower()]
    if types["Webapp"] and types["Native app"] then
      entry.Subtext = entry.AppType
    end
    entry.AppType = nil
  end

  table.sort(entries, function(a, b)
    return a.Text:lower() < b.Text:lower()
  end)

  return entries
end
