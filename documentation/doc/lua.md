# Yoshi Engine - Lua Documentation
## How to use Lua in Yoshi Engine ?
This page covers up the new Lua update, and how to use the new language.
The language communicates with the engine this way :

Using the `set`, `get`, `call`, `v` and `createClass` functions, the language can edit values in the `variables` map, which is the same as the hscript global variables, for example :
```haxe
function create() {
    PlayState.health = 1;
}
```
in Lua would be :
```lua
function create()
    set("PlayState.health", 1)
end
```
This is the syntax for a simple health change. We'll see how we can push it further

## __The `v` function.__
The v function is used to get a global value and use it in a function arguments

Example : `set("PlayState.health", v("newHealth"))`

## __The `set` function.__
Syntax :
`set(path, value)`

`path`: "Path" to the value (ex : `"PlayState.health"`)

`value`: New value (can be anything.)

To use a global value that can't be translated in lua, use `"$value"` for the value parameter.

For example, `set("PlayState.health", v("newHealth"))`

## __The `get` function.__
Syntax :
`get(path, ?globalValue)`

`path`: "Path" to the value (ex : `"PlayState.health"`)

`?globalValue`: If set, will set the result value to the global variable of that name, and returns true. If not set, will return the final value (or `nil` if it can't be converted to lua)

Example usage :
```lua
function create()
    get("PlayState.health", "health")
    set("health", 1.5)
    set("PlayState.health", v("health"))
end
```

## __The `call` function.__
Syntax : `call(path, ?globalVar, ?args)`

`path`: "Path" of the function (example : `PlayState.dad.playAnim`)

`globalVar`: Will set the value to the global var if set, or will return the value if not set or equal to `nil`

`args`: Array of arguments. Add `v("value")` in the list to use a global value. Example : `{"arg 1", 0, v("val3")}`

Example usage :
```lua
function create()
    createClass("newDad", "Character", {0, 100, "your-char"})

    call("PlayState.dads.push", nil, {v("newDad")})
    call("PlayState.add", nil, {v("newDad")})
end
```

## __The `createClass` function__
Syntax : `createClass(globalVar, classType, args)`

`globalVar`: Value name

`classType`: The class name (ex: `FlxSprite` or `Character`)

`args`: Array of arguments (ex : `{"arg1", 0, v("arg3")}`)

Example usage :
```lua
function createInFront()
    createClass("newDad", "Character", {0, 100, "your-char"})

    call("PlayState.dads.push", nil, {v("newDad")})
    call("PlayState.add", nil, {v("newDad")})
end
```

## __The `getArray` function.__
Syntax :
`get(path, index, ?globalValue)`

`path`: "Path" to the value (ex : `"PlayState.playerStrums.members"` or `"PlayState.cpuStrums.members"`)

`index`: Index of the value (ex : `1`)

`?globalValue`: If set, will set the result value to the global variable of that name, and returns true. If not set, will return the final value (or `nil` if it can't be converted to lua)

Example usage :
```lua
function musicstart()
    getArray("PlayState.playerStrums.members", 0, "strum1");
    set("strum1.x", 360);
end
```

## __The `setArray` function.__
Syntax :
`get(path, index, value)`

`path`: "Path" to the value (ex : `"PlayState.playerStrums.members"` or `"PlayState.cpuStrums.members"`)

`index`: Index of the value (ex : `1`)

`value`: The new value

Example usage :
```lua
function createInFront()
    createClass("newDad", "Character", {0, 100, "your-char"})

    call("PlayState.add", nil, {v("newDad")})
    setArray("PlayState.dads", 1, v("newDad"))
end
```