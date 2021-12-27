CreateThread(function()
  local route = AddRoute('GET', '/huh')

  ConfigureRoute(route, function(req, res)
    res.send('Hello World')
  end)
end)
