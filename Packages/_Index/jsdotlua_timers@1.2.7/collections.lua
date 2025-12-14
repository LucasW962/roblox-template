<<<<<<< HEAD
local REQUIRED_MODULE = require(script.Parent.Parent["jsdotlua_collections@1.2.7"]["collections"])
export type Array<T> = REQUIRED_MODULE.Array<T>
export type Map<T, V> = REQUIRED_MODULE.Map<T, V>
export type Object = REQUIRED_MODULE.Object 
export type Set<T> = REQUIRED_MODULE.Set<T>
export type WeakMap<T, V> = REQUIRED_MODULE.WeakMap<T, V>
return REQUIRED_MODULE
=======
return require(script.Parent.Parent["jsdotlua_collections@1.2.7"]["collections"])
>>>>>>> e711346ee46bc1967ab87eca5c6d3e23e75dc2d4
