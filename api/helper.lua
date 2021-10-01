function calculateCellPosition(x, y)
  return {
    x = math.floor((x - zoom/2 + offx)/zoom),
    y = math.floor((y - zoom/2 + offx)/zoom)
  }
end

function calculateScreenPosition(x, y, lastvars)
  if lastvars == nil then
    return {
      x = math.floor(x*zoom-offx+zoom/2),
      y = math.floor(y*zoom-offy+zoom/2)
    }
  else
    return calculateScreenPosition(lerp(lastvars[1],x,itime/delay), lerp(lastvars[2],y,itime/delay))
  end
end

function walkDivergedPath(from_x, from_y, to_x, to_y, depth)
  local dx, dy = from_x - to_x, from_y - to_y

  local dir = 0
  depth = depth or 0

  if dx == -1 then dir = 0 elseif dx == 1 then dir = 2 end
  if dy == -1 then dir = 1 elseif dy == 1 then dir = 3 end 

  local checkedrot = cells[to_y][to_x].rot

  if depth > 999999 then
    cells[to_y][to_x].ctype = 11
  end

  if moddedDivergers[cells[to_y][to_x].ctype] ~= nil then
    local dir = moddedDivergers[cells[to_y][to_x].ctype](to_x, to_y, dir)
    if dir == nil then
      return {
        x = to_x,
        y = to_y
      }
    end

    dx, dy = 0, 0

    if dir == 0 then dx = 1 elseif dir == 2 then dx = -1 end
    if dir == 1 then dy = 1 elseif dir == 3 then dy = -1 end

    return walkDivergedPath(to_x, to_y, to_x + dx, to_y + dy, depth + 1)
  elseif cells[to_y][to_x].ctype == 15 then
    if (checkedrot-1)%4 == dir then
      dir = (dir+1)%4
    elseif (checkedrot+2)%4 == dir then
      dir = (dir-1)%4
    else
      return {
        x = to_x,
        y = to_y
      }
    end

    dx, dy = 0, 0

    if dir == 0 then dx = 1 elseif dir == 2 then dx = -1 end
    if dir == 1 then dy = 1 elseif dir == 3 then dy = -1 end

    return walkDivergedPath(to_x, to_y, to_x + dx, to_y + dy, depth + 1)
  elseif cells[to_y][to_x].ctype == 30 then
    if (checkedrot+1)%2 == dir%2 then
      dir = (dir+1)%4
    else
      dir = (dir-1)%4
    end

    dx, dy = 0, 0

    if dir == 0 then dx = 1 elseif dir == 2 then dx = -1 end
    if dir == 1 then dy = 1 elseif dir == 3 then dy = -1 end

    return walkDivergedPath(to_x, to_y, to_x + dx, to_y + dy, depth + 1)
  elseif cells[to_y][to_x].ctype == 37 then
    if checkedrot%2 == dir%2 then
      return walkDivergedPath(to_x, to_y, to_x - dx, to_y - dy, depth + 1)
    else
      return {
        x = to_x,
        y = to_y
      }
    end
  elseif cells[to_y][to_x].ctype == 38 then
    return walkDivergedPath(to_x, to_y, to_x - dx, to_y - dy, depth + 1)
  else
    return {
      x = to_x,
      y = to_y
    }
  end
end

function getCellLabelById(id)
  if initialCells[id] ~= nil then
    return "vanilla"
  end
  return cellLabels[id] or "unknown"
end

function getCellIDByLabel(label)
  for id,val in pairs(cellLabels) do
    if val == label then
      return id
    end
  end
end

function rotateCell(x, y, amount)
  cells[y][x].rot = (cells[y][x].rot+amount)%4
end

function getCellLabel(x, y)
  local id = cells[y][x].ctype
  return getCellLabelById(id)
end