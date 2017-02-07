{:ok, cache} = Todo.Cache.start()
bobs = Todo.Cache.server_process cache, "Bob's list"
Todo.Server.entries bobs, {2017,2,2}
