local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

function cb_enrich(tag, timestamp, record)
  local container_id = record["container_id"]
  if (not container_id or #container_id == 0) and record["filepath"] then
    container_id = string.match(record["filepath"], "/var/lib/docker/containers/([A-Fa-f0-9]+)/")
  end
  if not container_id or #container_id == 0 then
    return 1, timestamp, record
  end

  local cfg_path = "/var/lib/docker/containers/" .. container_id .. "/config.v2.json"
  local data = read_file(cfg_path)
  if not data then
    return 1, timestamp, record
  end
  local name = string.match(data, '"Name"%s*:%s*"([^"]+)"')
  if name then
    if name:sub(1,1) == "/" then
      name = name:sub(2)
    end
    record["container_name"] = name
  end

  return 1, timestamp, record
end


