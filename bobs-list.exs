{:ok, cache} = Todo.Cache.start
bobs = Todo.Cache.server_process cache, "Bob's list"
