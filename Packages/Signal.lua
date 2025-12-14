local REQUIRED_MODULE = require(script.Parent._Index["sleitnick_signal@1.5.0"]["signal"])
export type Connection = REQUIRED_MODULE.Connection 
export type Signal<T...> = REQUIRED_MODULE.Signal<T...>
return REQUIRED_MODULE
