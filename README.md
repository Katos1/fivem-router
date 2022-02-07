# FiveM Router

## Simple and configurable FiveM Router library
```lua
CreateThread(function()
  local welcomeRoute = AddRoute('GET', '/')
  local byeRoute = AddRoute('GET', '/bye')
  
  ConfigureRoute(byeRoute, function(req, res)
    res.send('Welcome')
  end)

  ConfigureRoute(byeRoute, function(req, res)
    res.send('Bye nerd')
  end)
end)
```