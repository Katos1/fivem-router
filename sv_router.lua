local routes = {}
local acceptedMethods = {
  GET = true, 
  POST = true, 
  PUT = true, 
  DELETE = true
}

local function getRoute(route)
  assert(type(route) == 'string', 'Invalid Lua type at argument #1, expected string, got ' .. type(route))

  if routes[route] then
    return true, routes[route]
  end

  return false, nil
end

local function getParsedUrl(str)
  assert(type(str) == 'string', 'Invalid Lua type at argument #1, expected string, got ' .. type(str))
  local path, query

  for _path, _query in str:gmatch('(.+)?(.+)') do
    path = _path
    query = _query

    break
  end

  if not path then
    return str
  end

  return path, query
end

local function sendFile(res, filePath)
  assert(type(filePath) == 'string', 'Invalid Lua type at argument #1, expected string, got ' .. type(filePath))
  local fileContext = LoadResourceFile(GetCurrentResourceName(), filePath)

  if not fileContext then
    return
  end

  res.send(fileContext)
end

-- Incomming request
SetHttpHandler(function(req, res)
  print('Incoming request from ' .. req.address)
  local path, query = getParsedUrl(req.path)

  if path then
    local routeExists, routeData = getRoute(path)

    if routeExists and req.method == routeData.method then
      -- Middleware is configured
      if routeData.middleWare then
        local p = promise.new()

        routeData.middleWare(req, res, function()
          p:resolve()
        end)

        Citizen.Await(p)
      end

      req.path = path
      req.query = query
      res.sendFile = function(filePath)
        sendFile(res, filePath)
      end

      return routeData.handler(req, res)
    end
  end

  res.writeHead(404)
  res.send('Route does not exist')
end)

function AddRoute(method, route)
  assert(type(method) == 'string', 'Invalid Lua type at argument #1, expected string, got ' .. type(method))
  assert(type(route) == 'string', 'Invalid Lua type at argument #2, expected string, got ' .. type(route))

  if acceptedMethods[method] then
    routes[route] = {method = method}
  end

  return route
end

function ConfigureRoute(route, handler)
  assert(type(route) == 'string', 'Invalid Lua type at argument #1, expected string, got ' .. type(route))
  assert(type(handler) == 'function', 'Invalid Lua type at argument #2, expected function, got ' .. type(handler))
  assert(routes[route], 'Invalid route ' .. route)

  routes[route].handler = handler
end

function ConfigureMiddleware(route, handler)
  assert(type(route) == 'string', 'Invalid Lua type at argument #1, expected string, got ' .. type(route))
  assert(type(handler) == 'function', 'Invalid Lua type at argument #2, expected function, got ' .. type(handler))
  assert(routes[route], 'Invalid route ' .. route)

  routes[route].middleWare = handler
end
