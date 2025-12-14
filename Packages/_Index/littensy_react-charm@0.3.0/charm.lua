<<<<<<< HEAD
local REQUIRED_MODULE = require(script.Parent.Parent["littensy_charm@0.10.0"]["charm"])
export type Atom<State> = REQUIRED_MODULE.Atom<State>
export type Selector<State> = REQUIRED_MODULE.Selector<State>
export type Molecule<State> = REQUIRED_MODULE.Molecule<State>
return REQUIRED_MODULE
=======
return require(script.Parent.Parent["littensy_charm@0.10.0"]["charm"])
>>>>>>> e711346ee46bc1967ab87eca5c6d3e23e75dc2d4
