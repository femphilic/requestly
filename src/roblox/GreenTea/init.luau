--!strict

local GreenTea = require(script.GreenTea)
local InstanceClasses = require(script.InstanceClasses)
local tCompat = require(script.tCompat)

export type Cause = GreenTea.Cause
export type Type = GreenTea.Type
export type TuplePacked<T...> = GreenTea.TuplePacked<T...>

local module = {}

module.t = tCompat

module.isGreenTeaType = GreenTea.isGreenTeaType
module.isGtType = GreenTea.isGtType

module.any = GreenTea.any
module.unknown = GreenTea.unknown
module.never = GreenTea.never

module.boolean = GreenTea.boolean
module.bool = GreenTea.bool

module.Instance = GreenTea.Instance
module.isA = InstanceClasses
module.IsA = InstanceClasses

module.coroutine = GreenTea.coroutine
module.thread = GreenTea.thread

module.buffer = GreenTea.buffer

module.userdata = GreenTea.userdata

module.Vector2 = GreenTea.Vector2
module.vector = GreenTea.vector
module.Vector3 = GreenTea.Vector3
module.CFrame = GreenTea.CFrame
module.Color3 = GreenTea.Color3
module.UDim = GreenTea.UDim
module.UDim2 = GreenTea.UDim2
module.Ray = GreenTea.Ray
module.Rect = GreenTea.Rect
module.Region3 = GreenTea.Region3
module.BrickColor = GreenTea.BrickColor
module.Font = GreenTea.Font

module.Enum = GreenTea.Enum
module.EnumItem = GreenTea.EnumItem

module.none = GreenTea.none

module.literal = GreenTea.literal

module.withCustom = GreenTea.withCustom
module.custom = GreenTea.custom

module.number = GreenTea.number

module.string = GreenTea.string

module.isTypeof = GreenTea.isTypeof
module.isType = GreenTea.isType

module.vararg = GreenTea.vararg
module.tuple = GreenTea.tuple

module.args = GreenTea.args
module.returns = GreenTea.returns
module.fn = GreenTea.fn
module.anyfn = GreenTea.anyfn

module.tuplePacked = GreenTea.tuplePacked

module.table = GreenTea.table
module.struct = GreenTea.struct

module.anyTable = GreenTea.anyTable
module.array = GreenTea.array
module.dictionary = GreenTea.dictionary

module.union = GreenTea.union
module.oneOf = GreenTea.oneOf

module.intersection = GreenTea.intersection
module.allOf = GreenTea.allOf

module.optional = GreenTea.optional
module.opt = GreenTea.opt

module.typeof = GreenTea.typeof

module.typecast = GreenTea.typecast
module.asGreenTeaType = GreenTea.asGreenTeaType
module.asGtType = GreenTea.asGtType

module.build = GreenTea.build

module.meta = GreenTea.meta

module.wrapFn = GreenTea.wrapFn
module.wrapFnArgs = GreenTea.wrapFnArgs
module.wrapFnReturns = GreenTea.wrapFnReturns

table.freeze(module)
table.freeze(module.isA)
table.freeze(module.t)
table.freeze(GreenTea.__Cause)
table.freeze(GreenTea.__Type)

for key, value in module :: { [keyof<typeof(module)>]: index<typeof(module), keyof<typeof(module)>> } do
	GreenTea.__greenteaConstructorsSet[value] = `GreenTea.{key}`
end

for key: string, value: any in pairs(module.isA :: any) do
	GreenTea.__greenteaConstructorsSet[value] = `GreenTea.isA.{key}`
end

for key: string, value: any in pairs(module.t) do
	GreenTea.__greenteaConstructorsSet[value] = `GreenTea.t.{key}`
end

return module
