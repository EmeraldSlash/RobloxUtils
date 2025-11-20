--!strict

--
-- Various utilities that are useful in Roblox.
--
-- Created by Rio Manson-Hay (@EmeraldSlash)
--
-- Version 9 (2025-11-16)
--

--
-- API summary:
--
-- .RandomSeed()
--
-- .GetAncestry()
-- .AncestryLookup()
--
-- type Props
-- .PropsMerge()
-- .IPropsApply()
-- .OPropsApply()
-- .I()
-- .RaycastParamsNew()
-- .OverlapParamsNew()
--
-- .Lerp()
-- .LerpClamp()
-- .InvLerp()
-- .InvLerpClamp()
-- .Map()
-- .MapClamp()
-- .Damp()
--
-- .C3_Black/White: Color3
-- .C3_Lerp()
-- .CSK()
-- .NSK()
--
-- .V3_Max()
-- .V3_Min()
-- .V3_Format()
-- .V3_Lerp()
-- .V3_LerpClamp()
-- .V3_Clamp()
-- .V3_Abs()
-- .V3_SafeUnit()
-- .V3_XY/XZ/YZ: Vector3
-- .V3_XY/XZ/YZToV2()
-- .V3_FromC3()
-- .C3_FromV3()
--
-- .V2_Max()
-- .V2_Min()
-- .V2_Lerp()
-- .V2_LerpClamp()
-- .V2_Clamp()
-- .V2_Abs()
-- .V2_SafeUnit()
--
-- .ArrayRemove()
-- .ArrayAppend()
-- .ArrayAppendOnce()
-- .ArrayAppendArray()
--
-- .WeakArrayAppend()
-- .WeakArrayAppendOnce()
-- .WeakArrayRemove()
--
-- .TableNestedAppend()
-- .TableNestedRemove()
-- .TableNestedGet()
-- .TableFindName()
-- .TableHas()
-- .TableDeepCopy()
--
-- type Maid
-- .MaidNew()
-- Maid:New()
-- Maid:Add()
-- Maid:AddCall()
-- Maid:Remove()
-- Maid:Clean/Destroy()
-- Maid:Refresh()
-- Maid:Push()
-- Maid:SetParent()
-- type MaidCall
-- .MaidCallNew()
-- MaidCall:Destroy()
--
-- type BulkMoveTo
-- .BMT_New()
-- BulkMoveTo:Add()
-- BulkMoveTo:Apply()
--
-- type AsyncTask
-- .AsyncTaskNew()
-- AsyncTask:IsActive()
-- AsyncTask:Spawn()
-- AsyncTask:Defer()
-- AsyncTask:Delay()
-- AsyncTask:Close()
-- AsyncTask:Destroy()
--
-- type Signal
-- .SignalNew()
-- Signal:Fire()
-- Signal:Connect()
-- Signal:ConnectSpawn()
-- Signal:ConnectDefer()
-- Signal:Destroy()
-- type SignalConnection
-- SignalConnection.Connected
-- SignalConnection:Destroy/Disconnect()
--
-- type DLL_Node
-- .DLL_Create()
-- .DLL_ReplaceSentinel()
-- .DLL_SentinelQuickReset()
-- .DLL_Transfer()
-- .DLL_AppendBefore()
-- .DLL_AppendAfter()
-- .DLL_SentinelAppendFirst()
-- .DLL_SentinelAppendLast()
-- .DLL_AreLinked()
-- .DLL_IsSentinel()
-- .DLL_Remove()
--
-- type ContextActionMulti
-- .CAM_New()
-- .CAM_NewBound()
-- ContextActionMulti:SetInputs()
-- ContextActionMulti:SetBound()
-- ContextActionMulti:Destroy()
--
-- type Cache
-- .CacheNew()
-- .CacheImm()
-- Cache:Begin()
-- Cache:Add()
-- Cache:AddArray()
-- Cache:Mark()
--
-- type Anim
-- .AnimNew()
-- Anim:Aim()
-- Anim:Compute()
-- Anim:Consume()
-- Anim:Eval()
-- Anim:SetDuration()
-- Anim:SetEaseDir()
-- Anim:SetEaseStyle()

local Module = {}

function Module.RandomSeed()
	return math.random(2147483647)
end

--
-- Ancestry
--
function Module.GetAncestry(
	Current: Instance,
	ExcludeAndStopAt: Instance?
): {Instance}
	local Result = {}
	while Current and Current ~= ExcludeAndStopAt do
		Result[#Result+1] = Current
		Current = Current.Parent :: Instance
	end
	return Result
end
function Module.AncestryLookup<T>(
	Table: {[any]: T},
	Ancestry: {Instance}
): T?
	local Result
	for _, Current in Ancestry do
		Result = Table[Current]
		if Result then
			break
		end
	end
	return Result
end

--
-- Instance creation helper functions
--

-- In both the PropsMerge and PropsApply functions, tables specified last will
-- override properties from tables specified earlier.

-- e.g. in the case of PropsMerge(FirstProps, SecondProps) the SecondProps table
-- will override the FirstProps table.

-- Also, none of the tables given as input will ever be mutated so you don't
-- need to worry about that. (Provided the tables are shallow, which they should
-- be since they are just tables of properties.)

export type Props = {
	[string]: any
}
function Module.PropsMerge(FirstProps: Props, ...: Props): Props
	local Props = table.clone(FirstProps)
	for Index = 1, select("#", ...) do
		for Key, Value in select(Index, ...) do
			Props[Key] = Value
		end
	end
	return Props
end

-- Helper function for quickly creating instances.
function Module.I(ClassName: string, ...: Props)
	local NewInstance = Instance.new(ClassName)
	Module.IPropsApply(NewInstance, ...)
	return NewInstance
end

-- Helper function for setting properties on an instance.
function Module.IPropsApply(Object: Instance, ...: Props): Instance
	if select(1, ...) then
		local Props
		if not select(2, ...) then
			Props = select(1, ...)
		else
			Props = {}
			for Index = 1, select("#", ...) do
				for Key, Value in select(Index, ...) do
					Props[Key] = Value
				end
			end
		end
		for Key, Value in Props do
			if Key ~= "Parent" then
				(Object :: any)[Key] = Value
			end
		end
		if Props.Parent then
			Object.Parent = Props.Parent
		end
	end
	return Object
end

-- Helper function similar to IPropsApply, but used for any kind of object which
-- may not be an instance (such as RaycastParams and OverlapParams).
function Module.OPropsApply<T>(Object: T, ...: Props): T
	if select(1, ...) then
		local Props
		if not select(2, ...) then
			Props = select(1, ...)
		else
			Props = {}
			for Index = 1, select("#", ...) do
				for Key, Value in select(Index, ...) do
					Props[Key] = Value
				end
			end
		end
		for Key, Value in Props do
			(Object :: any)[Key] = Value
		end
	end
	return Object
end

-- Helper functions for creating common annoying data types.
export type RaycastParamsProps = {
	FilterType: Enum.RaycastFilterType?;
	FilterDescendantsInstances: {Instance}?;
	CollisionGroup: string?;
	RespectCanCollide: boolean?;
	BruteForceAllSlow: boolean?;
	IgnoreWater: boolean?;
}
function Module.RaycastParamsNew(...: RaycastParamsProps): RaycastParams
	return Module.OPropsApply(RaycastParams.new(), ...)
end
export type OverlapParamsProps = {
	FilterType: Enum.RaycastFilterType?;
	FilterDescendantsInstances: {Instance}?;
	CollisionGroup: string?;
	RespectCanCollide: boolean?;
	BruteForceAllSlow: boolean?;
	MaxParts: number?;
}
function Module.OverlapParamsNew(...: OverlapParamsProps): OverlapParams
	return Module.OPropsApply(OverlapParams.new(), ...)
end

--
-- Maths
--

function Module.Lerp(A: number, B: number, T: number): number
	return (1-T)*A + T*B
end
function Module.LerpClamp(A: number, B: number, T: number): number
	return Module.Lerp(A, B, math.clamp(T, 0, 1))
end

function Module.InvLerp(A: number, B: number, V: number): number
	return (V - A) / (B - A)
end
function Module.InvLerpClamp(A: number, B: number, V: number): number
	local T = math.clamp(Module.InvLerp(A, B, V), 0, 1)
	-- If we get NaN from InvLerp then replace it with 1 since by convention we
	-- should say we have reached the end.
	return if T ~= T then 1 else T
end

function Module.Map(
	A1: number,
	B1: number,
	V1: number,
	A2: number,
	B2: number
): number
	return Module.Lerp(A2, B2, Module.InvLerp(A1, B1, V1))
end
function Module.MapClamp(
	A1: number,
	B1: number,
	V1: number,
	A2: number,
	B2: number
): number
	return Module.LerpClamp(A2, B2, Module.InvLerpClamp(A1, B1, V1))
end

-- Usage example: Value = Module.Damp(Value, Target, Lambda)
function Module.Damp(
	A: number,
	B: number,
	Lambda: number
): number
	return Module.Lerp(A, B, math.clamp(1 - math.exp(-Lambda), 0, 1))
end

--
-- Colors & Keypoints
--

Module.C3_Black = Color3.new(0, 0, 0)
Module.C3_White = Color3.new(1, 1, 1)

Module.C3_Lerp = Color3.new().Lerp

function Module.CSK(Time: number, Value: Color3)
	return ColorSequenceKeypoint.new(Time, Value)
end
function Module.NSK(Time: number, Value: number, Envelope: number?)
	return NumberSequenceKeypoint.new(Time, Value, Envelope)
end

--
-- Vector3
--

function Module.V3_Format(V: Vector3): string
	return ("%.3f, %.3f, %.3f"):format(V.X, V.Y, V.Z)
end

Module.V3_Max = Vector3.zero.Max
Module.V3_Min = Vector3.zero.Min

Module.V3_Lerp = Vector3.zero.Lerp
function Module.V3_LerpClamp(A: Vector3, B: Vector3, T: number): Vector3
	return Module.V3_Lerp(A, B, math.clamp(T, 0, 1))
end
function Module.V3_Clamp(V: Vector3, Min: Vector3, Max: Vector3): Vector3
	return Module.V3_Min(Module.V3_Max(V, Min), Max) 
end
function Module.V3_Abs(V: Vector3): Vector3
	return Module.V3_Max(V, -V)
end
function Module.V3_SafeUnit(V: Vector3)
	return if V ~= Vector3.zero then V.Unit else V 
end

Module.V3_XZ = Vector3.new(1, 0, 1)
Module.V3_XY = Vector3.new(1, 1, 0)
Module.V3_YZ = Vector3.new(0, 1, 1)
function Module.V3_XZToV2(V: Vector3): Vector2
	return Vector2.new(V.X, V.Z)
end
function Module.V3_YZToV2(V: Vector3): Vector2
	return Vector2.new(V.Y, V.Z)
end
function Module.V3_XYToV2(V: Vector3): Vector2
	return Vector2.new(V.X, V.Y)
end

function Module.V3_FromC3(C: Color3): Vector3
	return Vector3.new(C.R, C.G, C.B)
end
function Module.C3_FromV3(V: Vector3): Color3
	return Color3.new(V.X, V.Y, V.Z)
end

--
-- Vector2
--

function Module.V2_Format(V: Vector2): string
	return ("%.3f, %.3f"):format(V.X, V.Y)
end

Module.V2_Max = Vector2.zero.Max
Module.V2_Min = Vector2.zero.Min

Module.V2_Lerp = Vector2.zero.Lerp
function Module.V2_LerpClamp(A: Vector2, B: Vector2, T: number): Vector2
	return Module.V2_Lerp(A, B, math.clamp(T, 0, 1))
end
function Module.V2_Clamp(V: Vector2, Min: Vector2, Max: Vector2): Vector2
	return Module.V2_Min(Module.V2_Max(V, Min), Max)
end
function Module.V2_Abs(V: Vector2): Vector2
	return Module.V2_Max(V, -V)
end
function Module.V2_SafeUnit(V: Vector2)
	return if V ~= Vector2.zero then V.Unit else V
end

--
-- Array Helpers
--
function Module.ArrayRemove<T>(Table: {T}, Value: T): number?
	local Index = table.find(Table, Value)
	if Index then
		table.remove(Table, Index)
	end
	return Index
end
function Module.ArrayAppend<T>(Table: {T}, Value: T): number
	local Index = #Table+1
	Table[Index] = Value
	return Index
end
function Module.ArrayAppendOnce<T>(Table: {T}, Value: T): number
	local Index = table.find(Table, Value)
	if not Index then
		local NewIndex = #Table+1
		Table[NewIndex] = Value
		Index = NewIndex
	end
	return Index :: number
end
function Module.ArrayAppendArray<T>(A: {T}, B: {T})
	table.move(B, 1, #B, #A+1, A)
end

--
-- Weak Array Helpers
--
-- Example:
--[[
Storage.Array = Module.WeakArrayAppendOnce(Storage.Array, Value)
Storage.Array = Module.WeakArrayRemove(Storage.Array, Value)
--]]
function Module.WeakArrayAppend<T>(Array: {T}?, Value: T): {T}?
	if Value ~= nil then
		if not Array then
			Array = {Value}
		else
			Array[#Array+1] = Value
		end
	end
	return Array
end
function Module.WeakArrayAppendOnce<T>(Array: {T}?, Value: T): {T}?
	if Value ~= nil then
		if not Array then
			Array = {Value}
		elseif not table.find(Array, Value) then
			Array[#Array+1] = Value
		end
	end
	return Array
end
function Module.WeakArrayRemove<T>(Array: {T}?, Value: T): {T}?
	if Array then
		local Index = table.find(Array, Value)
		if Index then
			table.remove(Array, Index)
			if not Array[1] then
				Array = nil
			end
		end
	end
	return Array
end

--
-- Table Helpers
--
function Module.TableNestedAppend<K,V>(Table: {[K]: {V}}, Key: K, Value: V)
	local Array = Table[Key]
	if Array then
		Array[#Array+1] = Value
	else
		Table[Key] = {Value}
	end
end
function Module.TableNestedRemove<K,V>(Table: {[K]: {V}}, Key: K, Value: V)
	local Array = Table[Key]
	if Array then
		local Index = table.find(Array, Value)
		if Index then
			table.remove(Array, Index)
			if not Array[1] then
				Table[Key] = nil
			end
		end
	end
end
function Module.TableNestedGet<K,V>(Table: {[K]: {[any]: any}}, Key: K): {[any]: any}
	if not Table[Key] then
		Table[Key] = {}
	end
	return Table[Key]
end
function Module.TableFindName(Table: {[any]: any}, Value: any): string
	local Result
	for Key, This in Table do
		if This == Value then
			Result = tostring(Key)
		end
	end
	if not Result then
		Result = ("<unknown value '%s'>"):format(tostring(Value))
	end
	return Result
end
function Module.TableHas<T>(Table: {[T]: any}, Value: any): (boolean, T)
	local ResultKey = nil
	for Key, This in Table do
		if This == Value then
			ResultKey = Key
			break
		end
	end
	return ResultKey ~= nil, ResultKey
end
function Module.TableDeepCopy<T>(Table: T): T
	local Result = {
		Table = (nil :: any) :: T;
	}

	-- Duplicate references to the same table are handled correctly by caching
	-- all the new tables we create.
	local TableCache: {[any]: any} = {}
	TableCache[Table] = Result

	-- If the tables have keys that are present as values elsewhere in the tables
	-- they will also be copied, otherwise table keys will not be copied. In
	-- other words, if a table would be copied, then any uses of it as a key will
	-- also be updated.
	local Stack_ByKey: {[any]: {any}} = {}

	type Entry = {
		Source: {[any]: any};
		Parent: {[any]: any};
		Key: any;
	}
	local Stack: {Entry} = {{
		Source = Table :: any;
		Parent = Result :: any;
		Key = "Table";
	}}
	while true do
		local Entry = table.remove(Stack)
		if not Entry then
			break
		else

			local Cached = TableCache[Entry.Source]
			if Cached then
				Entry.Parent[Entry.Key] = Cached
			else

				local Clone = table.clone(Entry.Source)
				TableCache[Entry.Source] = Clone
				Entry.Parent[Entry.Key] = Clone

				for Key, Value in Clone do
					if type(Value) == "table" then
						Stack[#Stack+1] = {
							Source = Value;
							Parent = Clone;
							Key = Key;
						}
					end
					if type(Key) == "table" then
						local Array = Stack_ByKey[Key]
						if Array then
							Array[#Array+1] = Clone
						else
							Stack_ByKey[Key] = {Clone}
						end
					end
				end
			end
		end
	end

	for Key, Stack in Stack_ByKey do
		local Cached = TableCache[Key]
		if Cached then
			for _, This in Stack do
				local Value = This[Key]
				This[Key] = nil
				This[Cached] = Value
			end
		end
	end

	return Result.Table
end

--
-- Maid
--
-- This maid API supports recursion, pushing/popping descendant maids, a cleanup
-- method override option, and running function calls with arguments on
-- cleanup. See below for reference of all the datatypes that can be put into
-- the maid.

export type HasMaidClean<T> = T & { MaidClean: (T)->(); }
export type HasDestroy<T> = T & { Destroy: (T)->(); }
export type HasDestroyLower<T> = T & { destroy: (T)->(); }
export type HasDisconnect<T> = T & { Disconnect: (T)->(); }
export type HasDisconnectLower<T> = T & { disconnect: (T)->(); }
export type MaidCall<T...> = {
	Function: (T...)->();
	Args: {any};

	Destroy: (MaidCall: MaidCall<T...>)->();
}
export type Maid = {
	MaidValues: {

		-- Maids can be cleaned up recursively. Any table that has a MaidValues
		-- field will be treated as if it is a Maid.
		| Maid

		-- The standard data types that can be cleaned up.
		| RBXScriptConnection -- Will call Connection:Disconnect() on clean.
		| Instance -- Will call Instance:Destroy() on clean.
		| thread -- Will call coroutine.close(Thread) on clean.
		| ()->() -- Will directly call the function on clean.

		-- The standard methods for cleaning up objects.
		| HasDestroy<any> -- :Destroy()
		| HasDestroyLower<any> -- :destroy()
		| HasDisconnect<any> -- :Disconnect()
		| HasDisconnectLower<any> -- :disconnect()

		-- Custom cleanup method that will always be called with highest priority,
		-- taking precedence over the standard methods like Destroy().
		| HasMaidClean<any>

		-- Enables you to pass a function + arguments to a maid which will be
		-- directly called when the maid is cleaned up. Use via Maid:AddCall().
		| MaidCall<any>

		-- Some objects may have issues with the maid calling their default
		-- destroy/cleanup method, such as throwing an error if the method is
		-- called redundantly or from triggering self-recursion. There are three
		-- ways you can avoid this.
		--
		-- Option 1: Give the maid a custom scoped cleanup function rather than
		-- giving the object itself.
		--[[
		maid:Add(function()
			customCleanup(object)
		end)
		--]]
		--
		-- Option 2: Add a MaidClean method to the object and give the object to
		-- the maid.
		--[[
		object.MaidClean = customCleanup
		maid:Add(object)
		--]]
		--
		-- Option 3: Create a MaidCall and give it to the maid.
		--[[
		maid:AddCall(customCleanup, object)
		--]]

	};

	-- The parent of the maid. The maid will be removed from its parent
	-- automatically when cleaned up to prevent memory leaks.
	MaidParent: Maid?;

	-- Cleanup methods (different aliases for the same method). After calling one
	-- of these methods, the maid will be in a completely empty state as if it
	-- was just created using `Module.MaidNew()`.
	Clean: (Maid: Maid)->();
	Destroy: (Maid: Maid)->();

	-- This method will do the same thing as the above Clean/Destroy methods, but
	-- it will keep the maid's parent the same. This method is therefore the
	-- most efficient way to reset a child maid's lifetime without changing its
	-- parent. After calling this method, the maid will be in an empty state as
	-- if it was just created using `parent:Push()`.
	Refresh: (Maid: Maid)->();

	-- Adds or removes values from a Maid. It is not recommended that you add
	-- child maids this way; rather you should prefer `child = parent:Push()` or
	-- `child:SetParent(parent)`.
	--
	-- Luau's legacy type solver does not play nicely with generic packs and will
	-- cause lots of false positive errors, so use the @Typecheck:Partial type
	-- definition to fix that. Otherwise, if using the new solver you should be
	-- able to use @Typecheck:Full.
	--
	--[[ @Typecheck:Full
	Remove: <T...>(Maid: Maid, T...)->(T...);
	Add: <T...>(Maid: Maid, T...)->(T...);
	AddCall: <T...>(Maid: Maid, Function: (T...)->(), T...)->(MaidCall<T...>);
	--]]
	---[[ @Typecheck:Partial
	Remove: (Maid: Maid, ...any)->(...any);
	Add: (Maid: Maid, ...any)->(...any);
	AddCall: (Maid: Maid, Function: (...any)->(), ...any)->(MaidCall<any>);
	--]]

	-- Creates a new, unrelated Maid. Equivalent to `Module.MaidNew()`.
	New: (_: any)->();

	-- Call this on the parent! Create a child maid whose lifetime is tied to the
	-- parent Maid. The child maid will be automatically removed from the parent
	-- when the child is cleaned up.
	Push: (Parent: Maid)->(Maid);

	-- Call this on the child! Updates the parent of the child maid, and will
	-- never clean up the child maid. Returns the previous parent, if there was
	-- one.
	--
	-- Remove from a parent: `child:SetParent(nil)`.
	-- Set a new parent: `child:SetParent(parent)`.
	--
	-- If setting a new parent, if the maid had a previous parent then it will
	-- be removed from that parent first. So maids can only have one parent at
	-- a time.
	--
	SetParent: (Child: Maid, Parent: Maid?)->(Maid?);
}
do
	local MaidCallMeta: MaidCall<any> =
		(function(): any local Class = {}; Class.__index = Class; return Class; end)()
	function MaidCallMeta.Destroy(MaidCall: MaidCall<any>)
		MaidCall.Function(table.unpack(MaidCall.Args))
	end

	local MaidMeta: Maid =
		(function(): any local Class = {}; Class.__index = Class; return Class; end)()
	function MaidMeta.Remove<T...>(Maid: Maid, ...: T...): (T...)
		for Index = 1, select("#", ...) do
			local ValueIndex = table.find(Maid.MaidValues, select(Index, ...))
			if ValueIndex then
				table.remove(Maid.MaidValues, ValueIndex)
			end
		end
		return ...
	end
	function MaidMeta.Add<T...>(Maid: Maid, ...: T...): (T...)
		for Index = 1, select("#", ...) do
			Maid.MaidValues[#Maid.MaidValues+1] = select(Index, ...)
		end
		return ...
	end
	function MaidMeta.AddCall<T...>(Maid: Maid, Function: (T...)->(), ...: T...): MaidCall<T...>
		if type(Function) ~= "function" then
			error("Maid:AddCall() first argument was not a function!")
		end
		local MaidCall: MaidCall<T...> = setmetatable({
			Function = Function;
			-- This is a dumb way to pack the variadic arguments, but it's
			-- necessary to silence the typechecker. (And table.pack() adds
			-- extra fields.)
			Args = (function(...) return {...} end)(...);
		} :: MaidCall<T...>, MaidCallMeta) :: any
		Maid.MaidValues[#Maid.MaidValues+1] = MaidCall
		return MaidCall
	end

	local function MaidCleanRecursive(Maid: Maid)
		-- Cyclic maid references will be handled without infinite loops because
		-- every step will remove something. This recursive implementation is the
		-- most efficient way to clean up maids, faster even than an iterative
		-- implementation.
		while true do
			local Value = table.remove(Maid.MaidValues)
			if not Value then
				break
			elseif typeof(Value) == "RBXScriptConnection" then
				Value:Disconnect()
			elseif typeof(Value) == "Instance" then
				Value:Destroy()
			elseif type(Value) == "thread" then
				coroutine.close(Value)
			elseif type(Value) == "function" then
				Value()
			elseif type(Value) == "table" then
				if type((Value :: Maid).MaidValues) == "table" then
					local ValueMaid = Value :: Maid
					local ValueMaidParent = ValueMaid.MaidParent
					if ValueMaidParent then
						if ValueMaidParent == Maid then
							-- Avoid unnecessary searching in parent since we know that
							-- it has already been removed. This provides a small
							-- speed improvement.
							ValueMaid.MaidParent = nil
						else
							-- Remove the maid from its unrelated previous parent.
							-- Equivalent to Maid:SetParent(nil).
							local Index = table.find(ValueMaidParent.MaidValues, ValueMaid)
							if Index then
								table.remove(ValueMaidParent.MaidValues, Index)
							end
							ValueMaid.MaidParent = nil
						end
					end
					MaidCleanRecursive(ValueMaid)
				elseif type((Value :: HasMaidClean<any>).MaidClean) == "function" then
					(Value :: HasMaidClean<any>):MaidClean()
				elseif type((Value :: HasDestroy<any>).Destroy) == "function" then
					(Value :: HasDestroy<any>):Destroy()
				elseif type((Value :: HasDestroy<any>).destroy) == "function" then
					(Value :: HasDestroy<any>):destroy()
				elseif type((Value :: HasDisconnect<any>).Disconnect) == "function" then
					(Value :: HasDisconnect<any>):Disconnect()
				elseif type((Value :: HasDisconnectLower<any>).disconnect) == "function" then
					(Value :: HasDestroy<any>):disconnect()
				else
					warn(debug.traceback("Table found in Maid was not another Maid and did not have a Destroy, Disconnect, or MaidClean method."))
				end
			end
		end
	end

	function MaidMeta.Clean(Maid: Maid)
		debug.profilebegin("MaidClean")

		do -- Equivalent to Maid:SetParent(nil).
			local Parent = Maid.MaidParent
			if Parent then
				Maid.MaidParent = nil
				local Index = table.find(Parent.MaidValues, Maid)
				if Index then
					table.remove(Parent.MaidValues, Index)
				end
			end
		end

		-- The above SetParent code is only needed for the root maid because for
		-- all descendant maids their parents will be removed within the cleaning
		-- loop. Therefore we can get a small speed improvement by separating the
		-- recursive cleaning function from the root cleaning function.
		MaidCleanRecursive(Maid)

		debug.profileend()
	end
	MaidMeta.Destroy = MaidMeta.Clean

	function MaidMeta.Refresh(Maid: Maid)
		debug.profilebegin("MaidClean")
		MaidCleanRecursive(Maid)
		debug.profileend()
	end

	function MaidMeta.Push(Parent: Maid): Maid
		local Child: Maid = setmetatable({
			MaidValues = {};
			MaidParent = Parent;
		}, MaidMeta) :: any
		Parent.MaidValues[#Parent.MaidValues+1] = Child
		return Child
	end

	function MaidMeta.SetParent(Child: Maid, Parent: Maid?): Maid?
		local OldParent = Child.MaidParent
		if OldParent ~= Parent then
			if OldParent then
				local Index = table.find(OldParent.MaidValues, Child)
				if Index then
					table.remove(OldParent.MaidValues, Index)
				end
			end
			Child.MaidParent = Parent
			if Parent then
				Parent.MaidValues[#Parent.MaidValues+1] = Child
			end
		end
		return OldParent
	end

	function MaidMeta.New(_: any): Maid
		return setmetatable({
			MaidValues = {};
		}, MaidMeta) :: any
	end

	function Module.MaidNew(): Maid
		return setmetatable({
			MaidValues = {};
		}, MaidMeta) :: any
	end
end

--
-- BulkMoveTo
--
export type BulkMoveTo = {
	Index: number;
	Parts: {BasePart};
	CFrames: {CFrame};

	Add: (BMT: BulkMoveTo, Part: BasePart, MoveToCFrame: CFrame)->();
	Apply: (BMT: BulkMoveTo)->(boolean);
}
do
	local BulkMoveToMeta =
		(function(): any local Class = {}; Class.__index = Class; return Class; end)()

	function BulkMoveToMeta.Add(BMT: BulkMoveTo, Part: BasePart, MoveToCFrame: CFrame)
		BMT.Index += 1
		BMT.Parts[BMT.Index] = Part
		BMT.CFrames[BMT.Index] = MoveToCFrame
	end
	function BulkMoveToMeta.Apply(BMT: BulkMoveTo): boolean
		local DidMove = BMT.Index > 0
		if DidMove then
			workspace:BulkMoveTo(BMT.Parts, BMT.CFrames)
			BMT.Index = 0
			table.clear(BMT.Parts)
			table.clear(BMT.CFrames)
		end
		return DidMove
	end

	function Module.BMT_New(): BulkMoveTo
		return setmetatable({
			Index = 0;
			Parts = {};
			CFrames = {};
		}, BulkMoveToMeta) :: any
	end
end

--
-- AsyncTask
--
-- Example usage:
--[[
CharacterLoadTask = CharacterMaid:Add(
	Module.AsyncTaskNew():Spawn(function()
		local Root = Character:WaitForChild("HumanoidRootPart")
	end))
--]]
--
export type AsyncTask = {
	-- The thread that is currently tracked by the AsyncTask.
	-- Empty   : thread == nil                 -> IsActive() == false
	-- Finished: thread == nil                 -> IsActive() == false
	-- Failed  : status(thread) == "dead"      -> IsActive() == false
	-- Running : status(thread) == "running"   -> IsActive() == true
	-- Yielded : status(thread) == "suspended" -> IsActive() == true
	-- Normal  : status(thread) == "normal"    -> IsActive() == true
	Thread: thread?;

	-- Create a new empty AsyncTask. Equivalent to Module.AsyncTaskNew().
	New: (_: AsyncTask)->(AsyncTask);

	-- The correct way to check if there is an active thread within this
	-- AsyncTask, such that a new thread should not be added to it.
	IsActive: (AT: AsyncTask)->(boolean);

	-- Correct ways to start a new thread. Can be chained, throws an error if the
	-- AsyncTask already has a thread.
	--
	-- Luau's legacy type solver does not play nicely with generic packs and will
	-- cause lots of false positive errors, so use the @Typecheck:Partial type
	-- definition to fix that. Otherwise, if using the new solver you should be
	-- able to use @Typecheck:Full.
	--
	--[[ @Typecheck:Full
	Spawn: <T...>(AT: AsyncTask, Func: (T...)->() | thread, T...)->(AsyncTask);
	Defer: <T...>(AT: AsyncTask, Func: (T...)->() | thread, T...)->(AsyncTask);
	Delay: <T...>(At: AsyncTask, Duration: number, Func: (T...)->() | thread, T...)->(AsyncTask);
	--]]
	---[[ @Typecheck:Partial
	Spawn: (AT: AsyncTask, Func: (...any)->() | thread, ...any)->(AsyncTask);
	Defer: (AT: AsyncTask, Func: (...any)->() | thread, ...any)->(AsyncTask);
	Delay: (At: AsyncTask, Duration: number, Func: (...any)->() | thread, ...any)->(AsyncTask);
	--]]

	-- Clean up the AsyncTask by closing the thread (if it's not the currently
	-- running thread) and always untracking the thread. Can be chained, does
	-- not throw errors. The same AsyncTask can be reused afterwards.
	Close: (AT: AsyncTask)->(AsyncTask);
	Destroy: (AT: AsyncTask)->(AsyncTask);
}
do
	local AsyncTaskMeta: AsyncTask =
		(function(): any local Class = {}; Class.__index = Class; return Class; end)()

	function AsyncTaskMeta.IsActive(AT: AsyncTask): boolean
		return if AT.Thread then coroutine.status(AT.Thread) ~= "dead" else false
	end

	function AsyncTaskMeta.Close(AT: AsyncTask): AsyncTask
		local Thread = AT.Thread
		if Thread then
			AT.Thread = nil
			if coroutine.running() ~= Thread then
				coroutine.close(Thread)
			end
		end
		return AT
	end
	AsyncTaskMeta.Destroy = AsyncTaskMeta.Close

	local function AssignThread<T...>(AT: AsyncTask, Func: (T...)->() | thread)
		assert(not AT:IsActive(), "AsyncTask already has an active thread!")
		if type(Func) == "thread" then
			AT.Thread = Func
		else
			AT.Thread = coroutine.create(function(...: T...)
				Func(...)
				AT.Thread = nil
			end)
		end
	end
	function AsyncTaskMeta.Spawn<T...>(
		AT: AsyncTask, Func: (T...)->() | thread, ...: T...
	): AsyncTask
		AssignThread(AT, Func)
		task.spawn(AT.Thread :: thread, ...)
		return AT
	end
	function AsyncTaskMeta.Defer<T...>(
		AT: AsyncTask, Func: (T...)->() | thread, ...: T...
	): AsyncTask
		AssignThread(AT, Func)
		task.defer(AT.Thread :: thread, ...)
		return AT
	end
	function AsyncTaskMeta.Delay<T...>(
		AT: AsyncTask, Duration: number, Func: (T...)->() | thread, ...: T...
	): AsyncTask
		AssignThread(AT, Func)
		task.delay(Duration, AT.Thread :: thread, ...)
		return AT
	end

	function AsyncTaskMeta.New(_: AsyncTask): AsyncTask
		return setmetatable({}, AsyncTaskMeta) :: any
	end
	function Module.AsyncTaskNew(): AsyncTask
		return setmetatable({}, AsyncTaskMeta) :: any
	end
end

-- Signal
--
-- Basic signal implementation.
--
export type SignalCallback = (Connection: SignalConnection, ...any)->()
export type SignalConnection = {
	Signal: Signal;
	Connected: boolean;
	Callback: SignalCallback;
	DeferredThreads: {thread}?;

	Destroy: (Connection: SignalConnection)->();
	Disconnect: (Connection: SignalConnection)->();
}
export type Signal = {
	Connections: {SignalConnection};

	Destroy: (Signal: Signal)->();
	Fire: (Signal: Signal, ...any)->();

	-- Callbacks bound using Signal:Connect() will be called directly
	Connect: (Signal: Signal, Callback: SignalCallback)->(SignalConnection);

	-- Callbacks bound using Signal:ConnectSpawn() will be spawned as a separate
	-- thread.
	ConnectSpawn: (Signal: Signal, Callback: SignalCallback)->(SignalConnection);

	-- Callbacks bound using Signal:ConnectDefer() will be called using
	-- task.defer() and will be cancelled if the connection or signal is
	-- destroyed/disconnected up before it runs, but will not be deduplicated if
	-- the signal is fired numerous times before the first callback runs.
	ConnectDefer: (Signal: Signal, Callback: SignalCallback)->(SignalConnection);
}
do
	local ConnectionMeta: SignalConnection =
		(function(): any local c = {}; c.__index = c; return c end)()
	function ConnectionMeta.Disconnect<T>(Connection: SignalConnection)
		if Connection.Connected then
			Connection.Connected = false
			local Array = Connection.Signal.Connections
			local Index = table.find(Array, Connection)
			if Index then
				table.remove(Array, Index)
			end
			if Connection.DeferredThreads then
				for _, Thread in Connection.DeferredThreads do
					coroutine.close(Thread)
				end
				Connection.DeferredThreads = nil
			end
		end
	end
	ConnectionMeta.Destroy = ConnectionMeta.Disconnect

	local SignalMeta: Signal =
		(function(): any local c = {}; c.__index = c; return c end)()
	function SignalMeta.Fire<T>(Signal: Signal, ...)
		local Connections = table.clone(Signal.Connections)
		for Index = #Connections, 1, -1 do
			local Connection = Connections[Index]
			if Connection.Connected then
				Connection:Callback(...)
			end
		end
	end
	function SignalMeta.Connect(Signal: Signal, Callback: SignalCallback): SignalConnection
		local Connection: SignalConnection = setmetatable({
			Signal = Signal;
			Connected = true;
			Callback = Callback;
		}, ConnectionMeta) :: any
		Signal.Connections[#Signal.Connections+1] = Connection
		return Connection
	end
	function SignalMeta.ConnectSpawn(Signal: Signal, Callback: SignalCallback): SignalConnection
		return Signal:Connect(function(...)
			task.spawn(Callback, ...)
		end)
	end
	local function DeferredConnection(Connection: SignalConnection, ...)
		if Connection.DeferredThreads then
			local Index = table.find(Connection.DeferredThreads, coroutine.running())
			if Index then
				table.remove(Connection.DeferredThreads, Index)
			end
		end
		Connection:Callback(...)
	end
	function SignalMeta.ConnectDefer(
		Signal: Signal, Callback: SignalCallback
	): SignalConnection
		return Signal:Connect(function(Connection, ...)
			local Array = Connection.DeferredThreads or {}
			Array[#Array+1] = task.defer(DeferredConnection, Connection, ...)
			Connection.DeferredThreads = Array
		end)
	end
	function SignalMeta.Destroy<T...>(Signal: Signal)
		for _, Connection in Signal.Connections do
			Connection.Connected = false
			if Connection.DeferredThreads then
				for _, Thread in Connection.DeferredThreads do
					coroutine.close(Thread)
				end
				Connection.DeferredThreads = nil
			end
		end
		table.clear(Signal.Connections)
	end
	function Module.SignalNew(): Signal
		return setmetatable({Connections = {};}, SignalMeta) :: any
	end
end

--
-- Doubly Linked List
--
-- Here is the idiomatic & most efficient way to walk the linked list:
--[[
local DLL_Current = DLL_Sentinel.DLL_Next
while DLL_Current ~= DLL_Sentinel do
	local Element = DLL_Current
	DLL_Current = DLL_Current.DLL_Next

	-- It is safe to remove elements after the Current pointer has been moved to
	-- the next node.
	DLL_Remove(Element)

	-- Do other stuff with Element here.
end
--]]
export type DLL_Node<T> = T & {
	DLL_Sentinel: DLL_Node<T>;
	DLL_Next: DLL_Node<T>;
	DLL_Prev: DLL_Node<T>;
}
function Module.DLL_Create<T>(): DLL_Node<T>
	local Sentinel = {} :: DLL_Node<T>
	Sentinel.DLL_Sentinel = Sentinel
	Sentinel.DLL_Next = Sentinel
	Sentinel.DLL_Prev = Sentinel
	return Sentinel
end

-- Replaces the sentinel of all the items in the list with a new value. Can be
-- used to clear the sentinel reference if the replacement is nil. Neither sentinel
-- nodes themselves will ever be modified.
function Module.DLL_ReplaceSentinel<T>(Sentinel: DLL_Node<T>, Replacement: DLL_Node<T>?)
	local Current = Sentinel.DLL_Next
	while Current ~= Sentinel do
		Current.DLL_Sentinel = Replacement :: DLL_Node<T>
		Current = Current.DLL_Next
	end
end
-- Fast way to reset the list, relying on the garbage collector to clean up
-- the items in the list.
function Module.DLL_SentinelQuickReset<T>(Sentinel: DLL_Node<T>)
	Sentinel.DLL_Next = Sentinel
	Sentinel.DLL_Prev = Sentinel
end
-- Transfers all the items in the From list to the To list. The items will be
-- append to the end of the of the existing items in the To list.
function Module.DLL_Transfer<T>(SentinelFrom: DLL_Node<T>, SentinelTo: DLL_Node<T>)
	if SentinelFrom.DLL_Next ~= SentinelFrom then

		local First = SentinelFrom.DLL_Next
		local Last = SentinelFrom.DLL_Prev

		Module.DLL_ReplaceSentinel(SentinelFrom, SentinelTo)
		Module.DLL_SentinelQuickReset(SentinelFrom)

		First.DLL_Prev = SentinelTo.DLL_Prev
		Last.DLL_Next = SentinelTo

		SentinelTo.DLL_Prev.DLL_Next = First
		SentinelTo.DLL_Prev = Last
	end
end

-- Append a node after the given item in the list.
function Module.DLL_AppendAfter<T>(Item: DLL_Node<T>, Node: DLL_Node<T>)
	Node.DLL_Sentinel = Item.DLL_Sentinel

	Node.DLL_Next = Item.DLL_Next
	Node.DLL_Prev = Item

	Item.DLL_Next.DLL_Prev = Node
	Item.DLL_Next = Node
end
-- Append a node before the given item in the list.
function Module.DLL_AppendBefore<T>(Item: DLL_Node<T>, Node: DLL_Node<T>)
	Module.DLL_AppendAfter(Item.DLL_Prev, Node)
end
-- Append a node as the first item in the list using the sentinel.
function Module.DLL_SentinelAppendFirst<T>(Sentinel: DLL_Node<T>, Node: DLL_Node<T>)
	Module.DLL_AppendAfter(Sentinel, Node)
end
-- Append a node as the last item in the list using the sentinel.
function Module.DLL_SentinelAppendLast<T>(Sentinel: DLL_Node<T>, Node: DLL_Node<T>)
	Module.DLL_AppendBefore(Sentinel.DLL_Prev, Node)
end

-- Returns true if the nodes are inside the same list. Can take sentinels too.
function Module.DLL_AreLinked<T>(A: DLL_Node<T>, B: DLL_Node<T>): boolean
	return A.DLL_Sentinel == B.DLL_Sentinel
end
-- Returns true if the node is the sentinel of the list.
function Module.DLL_IsSentinel<T>(Node: DLL_Node<T>): boolean
	return Node.DLL_Sentinel == Node
end

-- Removes the node from any list it is in, and returns the sentinel of the list
-- it was removed from.
function Module.DLL_Remove<T>(Node: DLL_Node<T>): DLL_Node<T>?
	local Sentinel = Node.DLL_Sentinel
	if Sentinel then
		Node.DLL_Sentinel = nil :: any
		Node.DLL_Next.DLL_Prev = Node.DLL_Prev
		Node.DLL_Prev.DLL_Next = Node.DLL_Next
	end
	return Sentinel
end

--
-- ContextActionMulti
--
-- Registers the same ContextActionService action for many inputs with each
-- input registered separately so that they can be cancelled individually
-- without overriding the other inputs.
--
-- Also allows keybindings to be dynamically changed by providing a completely
-- new table of inputs. If using CAM:SetInputs(), this is done just by
-- providing the Inputs argument. If using CAM:SetBound(), this is done by
-- replacing the CAM.InputsToBind field.
--
-- Examples:
--[[

local CAM = Module.CAM_New("Name", 1, function() end)
while true do
	CAM:SetInputs({Enum.KeyCode.Left})
	task.wait(1)
	CAM:SetInputs(nil)
	task.wait(1)
end

local CAM = Module.CAM_NewBound("Name", 1, {Enum.keyCode.Left}, function() end)
while true do
	CAM:SetBound(true)
	task.wait(1)
	CAM:SetBound(false)
	task.wait(1)
end

--]]

export type ContextActionMultiCallback = (

	-- Values directly passed from the ContextActionService callback.
	Name: string,
	InputState: Enum.UserInputState,
	InputObject: InputObject,

	-- Additional values that are useful.
	Input: Enum.KeyCode|Enum.UserInputType,
	CAM: ContextActionMulti

)->(Enum.ContextActionResult?)

export type ContextActionMulti = {
	Name: string;
	Priority: number;
	Action: ContextActionMultiCallback;

	-- Set internally, these are the inputs which are actually being used by
	-- ContextActionService.
	InputsActive: {Enum.KeyCode|Enum.UserInputType}?;

	-- Normal API
	--
	-- Set the table of inputs that are currently active.
	SetInputs: (
		CAM: ContextActionMulti,
		Inputs: {Enum.KeyCode|Enum.UserInputType}?
	)->(ContextActionMulti);

	-- Alternative API
	--
	-- Populated by CAM_NewBound(), or your own usage code. Used by
	-- CAM:SetBound() to set bind/unbind these inputs.
	InputsToBind: {Enum.KeyCode|Enum.UserInputType}?;
	--
	-- Only works with CAMs created via CAMS_NewBound, or which have the
	-- InputsToBind field set.
	SetBound: (CAM: ContextActionMulti, Bound: boolean)->(ContextActionMulti);

	-- Clean up.
	Destroy: (CAM: ContextActionMulti)->(ContextActionMulti);
}
do
	local ContextActionService = game:GetService("ContextActionService")
	local CAMMeta: ContextActionMulti =
		(function(): any local Class = {}; Class.__index = Class; return Class; end)()

	function Module.CAM_New(
		Name: string,
		Priority: number,
		Action: ContextActionMultiCallback
	): ContextActionMulti

		assert(type(Name) == "string", "CAM_New(): Name must be a string")
		assert(type(Priority) == "number", "CAM_New(): Priority must be a number ")
		assert(type(Action) == "function", "CAM_New(): Action must be a function")

		return setmetatable({
			Name = Name;
			Priority = Priority;
			Action = Action;
		}, CAMMeta) :: any
	end
	function CAMMeta.SetInputs(
		CAM: ContextActionMulti,
		Inputs: {Enum.KeyCode|Enum.UserInputType}?
	)
		while true do
			if not CAM.InputsActive then
				if not Inputs then
					break
				else
					CAM.InputsActive = Inputs
					for _, Input in Inputs do
						ContextActionService:BindActionAtPriority(
							CAM.Name.."_"..tostring(Input),
							function(Name, InputState, InputObject)
								return CAM.Action(Name, InputState, InputObject, Input, CAM)
							end, false, CAM.Priority, Input)
					end
				end
			elseif CAM.InputsActive ~= Inputs then
				for _, Input in CAM.InputsActive do
					ContextActionService:UnbindAction(CAM.Name.."_"..tostring(Input))
				end
				CAM.InputsActive = nil
			else
				break
			end
		end
		return CAM
	end
	function CAMMeta.Destroy(CAM: ContextActionMulti)
		return CAM:SetInputs(nil)
	end

	function Module.CAM_NewBound(
		Name: string,
		Priority: number,
		InputsToBind: {Enum.KeyCode|Enum.UserInputType},
		Action: ContextActionMultiCallback
	): ContextActionMulti

		assert(type(Name) == "string", "CAM_NewBound(): Name must be a string")
		assert(type(Priority) == "number", "CAM_NewBound(): Priority must be a number")
		assert(type(InputsToBind) == "table", "CAM_NewBound(): InputsToBind must be a table")
		assert(type(Action) == "function", "CAM_NewBound(): Action must be a function")

		return setmetatable({
			Name = Name;
			Priority = Priority;
			InputsToBind = InputsToBind;
			Action = Action;
		}, CAMMeta) :: any
	end
	function CAMMeta.SetBound(CAM: ContextActionMulti, Bound: boolean)
		if not CAM.InputsToBind then
			warn(debug.traceback("CAM:SetBound(): CAM is missing InputsToBind field. Did you forget to call CAM_NewBound()?"))
		end
		return CAM:SetInputs(if Bound then CAM.InputsToBind else nil)
	end
end

--
-- Cache
--
-- Used for caching values sequentially. Examples:
--[[

-- RETAINED MODE USAGE

-- create
Storage.Cache = Module.CacheNew()

-- update
Storage.Cache:Begin()
local Name = if TimeRemainingSecs > 0 then "Bob" else "Sam"
if Storage.Cache:Add(Name) then
	NameLabel.Text = Name
end
if Storage.Cache:Add(TimeRemainingSecs) then
	TimeRemaining.Text = tostring(TimeRemainingSecs)
end

-- IMMEDIATE MODE USAGE

-- create & update
Storage.Cache = Module.CacheImm(Storage.Cache)
local Name = if TimeRemainingSecs > 0 then "Bob" else "Sam"
if Storage.Cache:Add(Name) then
	NameLabel.Text = Name
end
if Storage.Cache:Add(TimeRemainingSecs) then
	TimeRemaining.Text = tostring(TimeRemainingSecs)
end

-- OTHER USAGE

-- add array
if Storage.Cache:AddArray({1, 2, 3}) then ... end

-- mark dirty
Storage.Cache:Mark(LayoutDirty)
if Storage.Cache.Dirty then ... end

--]]
export type Cache = {
	-- Output field.
	Dirty: boolean;

	-- This is an internal field, but you can also check this to see if any of
	-- the values added so far in this frame are dirty, ignoring whether there
	-- are remaining values that haven't been added to the array yet (which is a
	-- factor the plain Dirty field takes into account.) This value will also
	-- be affected by the Mark method.
	DirtySoFar: boolean;

	-- Internal fields
	Array: {any};
	PrevCount: number;
	CurrCount: number;

	-- Methods.
	--
	-- All methods return whether any of the values added to the array within
	-- that particular method were dirty.

	-- Begin a new frame, moving the write cursor back to the start of the array.
	-- Optionally you can add items to the cache as well.
	Begin: (Cache: Cache, ...any)->(boolean);

	-- Add an item to the cache.
	Add: (Cache: Cache, ...any)->(boolean);
	AddArray: (Cache: Cache, {any})->(boolean);

	-- Mark cache is as being dirty if any of the input parameters are truthy.
	-- (Without affecting the contents of the cache.)
	Mark: (Cache: Cache, ...boolean)->(boolean);

	-- Important details:
	--
	-- For reliable handling of possible nil values that you wish to cache, it is
	-- recommended that you add an unchanging "sentinel" value (such as 0) at the
	-- end of the varargs list, so that the nil indices do not get skipped.
	-- e.g. Cache:Add(workspace:FindFirstChild("Part"), 0)
	--
	-- Cache:AddArray() is basically like a syntax-sugar/convenient-wrapper for
	-- Cache:Add(), equivalent to Cache:Add(table.unpack(Array)), and so has all
	-- the same limitations and concerns.
	--
	-- For caching dynamic arrays/list, it is generally recommended that you
	-- avoid using a Cache except if you need really basic "was something
	-- added/removed/changed in the array" detection. By "dynamically sized
	-- array" I mean an array which may have a different size each time AddArray
	-- is called, e.g. Cache:AddArray(game.Players:GetPlayers()).
	--
	-- In the following situations it is fine to cache an array/list:
	--
	-- 1) If the input array is statically sized (num elements of the array
	-- passed to AddArray never ever changes) then there is nothing to worry
	-- about. You may need to be cautious of nil values within the array itself
	-- though, if they affect the size! Good example:
	--
	-- Cache:AddArray({1, 2, 3, 4})
	--
	-- 2) If the Cache is exclusively dedicated to the one dynamically sized
	-- input array. Nil values within the array are no problem here. Good example:
	--
	-- Cache:Begin()
	-- Cache:AddArray(game.Players:GetPlayers())
	-- (nothing else is added to the cache after)
	--
	-- 3) If the dynamically sized input array is always the last thing added to
	-- the Cache. Nil values within the array are no problem here. Good example:
	--
	-- Cache:Begin()
	-- Cache:Add(SomeValue)
	-- Cache:AddArray(game.Players:GetPlayers())
	-- (nothing else is added to the cache after)
	--
	-- There will be problems in all other cases where a dynamically sized array
	-- is mixed in with other values. All these rules also apply if you're adding
	-- dynamic values individually e.g. from different data structure like a
	-- linked list or manually adding an array.
	--
}
do
	local CacheMeta: Cache =
		(function(): any local Class = {}; Class.__index = Class; return Class; end)()

	function Module.CacheNew(): Cache
		return setmetatable({
			Dirty = false;

			DirtySoFar = false;
			Array = {};
			PrevCount = 0;
			CurrCount = 0;

		}, CacheMeta) :: any
	end

	-- Immediate-mode wrapper for creating a cache.
	@native
	function Module.CacheImm(Cache: Cache?, ...: any): Cache
		local Result = if Cache then Cache else Module.CacheNew()
		Result:Begin(...)
		return Result
	end

	-- Begin a new frame for the cache.
	@native
	function CacheMeta.Begin(Cache: Cache, ...: any): boolean
		-- Clear out items from two frames ago that were not used in the previous
		-- frame.
		for Index = Cache.PrevCount, Cache.CurrCount+1, -1 do
			Cache.Array[Index] = nil
		end

		-- Reset dirty state.
		Cache.Dirty = false
		Cache.DirtySoFar = false
		Cache.PrevCount = Cache.CurrCount
		Cache.CurrCount = 0

		return Cache:Add(...)
	end

	-- Add data to the cache.
	@native
	function CacheMeta.Add(Cache: Cache, ...: any): boolean
		local JustDirty = false
		-- Even if ... has nils, the count will be correct.
		for Index = 1, select("#", ...) do
			local Value = select(Index, ...)
			Cache.CurrCount += 1
			if Cache.Array[Cache.CurrCount] ~= Value then
				Cache.Array[Cache.CurrCount] = Value
				Cache.DirtySoFar = true
				JustDirty = true
			end
		end
		Cache.Dirty = Cache.DirtySoFar or (Cache.CurrCount ~= Cache.PrevCount)
		return JustDirty
	end
	@native
	function CacheMeta.AddArray(Cache: Cache, Array: {any}): boolean
		local JustDirty = false
		-- Assume that #Array is correct: if not, it is the user's fault.
		for Index = 1, #Array do
			local Value = Array[Index]
			Cache.CurrCount += 1
			if Cache.Array[Cache.CurrCount] ~= Value then
				Cache.Array[Cache.CurrCount] = Value
				Cache.DirtySoFar = true
				JustDirty = true
			end
		end
		Cache.Dirty = Cache.DirtySoFar or (Cache.CurrCount ~= Cache.PrevCount)
		return JustDirty
	end

	-- Marks the cache as dirty if any of the Dirty parameters are truthy.
	@native
	function CacheMeta.Mark(Cache: Cache, ...: boolean): boolean
		local JustDirty = false
		-- Even if ... has nils, the count will be correct.
		for Index = 1, select("#", ...) do
			local Dirty = select(Index, ...)
			if Dirty then
				Cache.DirtySoFar = true
				JustDirty = true
			end
		end
		Cache.Dirty = Cache.DirtySoFar or (Cache.CurrCount ~= Cache.PrevCount)
		return JustDirty
	end
end

-- Anim
--
-- Helper for immediate-mode evaluated animations. Designed for chained usage.
--
-- Simple usage. If animation begins during this call, then after this call
-- Anim.Value will be closer to the target value than the start value.
--[[
Anim:Eval(Delta, Target)
print(Anim.Value, Anim.Dirty)
--]]
-- Change easing style based on target. Same caveat about Anim.Value being
-- closer to the target value after all this code has run.
--[[
Anim
	:SetEaseDir(if Target > 0.5 then Enum.EasingStyle.In else Enum.EasingStyle.Out)
	:Aim(Target) -- Set new animation target.
	:Compute(Delta) -- Start going there immediately.
	:Consume() -- Write to Anim.Dirty.
	--]]
-- This is the same as above, but this time the previous animation will be
-- evaluated using this frame's delta time (and using the previous easing style),
-- then the new animation to target will be at the previous animation's value
-- for this frame.
--[[
Anim
	:Compute(Delta) -- Update previous animation.
	:SetEaseDir(if Target > 0.5 then Enum.EasingStyle.In else Enum.EasingStyle.Out)
	:Aim(Target) -- Set new animation target.
	:Consume() -- Write to Anim.Dirty.
--]]
--
-- Here's how you can run the animation with constant speed. I recommend you use
-- linear (or no) easing style. The animation's Duration setting will be
-- interpreted as the speed of the animation in units per second.
--[[
Anim:Aim(Target):Compute(Delta, true)
--]]
--
export type Anim = {
	-- current value of the animation
	Value: number;
	Dirty: boolean; -- Set only when using Anim:Consume()

	-- internal state
	Duration: number;
	Start: number;
	Target: number;
	Elapsed: number?; -- only set when an animation is active
	EaseStyle: Enum.EasingStyle?;
	EaseDir: Enum.EasingDirection?;
	Cached_Value: number?;

	-- methods
	Aim: (Anim: Anim, Target: number)->(Anim);
	Compute: (Anim: Anim, Delta: number)->(Anim);
	Consume: (Anim: Anim)->(Anim);
	Eval: (Anim: Anim, Delta: number, Target: number)->(Anim);
	SetDuration: (Anim: Anim, Duration: number)->(Anim);
	SetEaseStyle: (Anim: Anim, EaseStyle: Enum.EasingStyle?)->(Anim);
	SetEaseDir: (Anim: Anim, EaseDir: Enum.EasingDirection?)->(Anim);
}
do
	local TweenService = game:GetService("TweenService")
	local TweenService_GetValue = TweenService.GetValue

	local AnimMeta: Anim =
		(function(): any local c = {}; c.__index = c; return c; end)()

	function Module.AnimNew(
		Duration: number,
		Value: number?,
		EaseStyle: Enum.EasingStyle?,
		EaseDir: Enum.EasingDirection?
	): Anim
		return setmetatable({
			Duration = Duration;
			Value = Value;
			Start = Value;
			Target = Value;
			EaseStyle = EaseStyle;
			EaseDir = EaseDir;
		} :: Anim, AnimMeta) :: any
	end

	function AnimMeta.Aim(Anim: Anim, Target: number): Anim
		if Anim.Target ~= Target then
			Anim.Target = Target
			Anim.Start = Anim.Value
			Anim.Elapsed = 0
		end
		return Anim
	end
	function AnimMeta.Compute(Anim: Anim, Delta: number, ConstantSpeed: boolean?): Anim
		if Anim.Elapsed then
			Anim.Elapsed += Delta
			local Duration =
				if ConstantSpeed then math.abs(Anim.Target - Anim.Start) / Anim.Duration
				else Anim.Duration
			local Progress = Anim.Elapsed / Duration
			-- The animation will bias towards being complete if duration is 0.
			if Progress ~= Progress then Progress = 1 end
			Progress = math.clamp(Progress, 0, 1)
			if Progress > 0 and Progress < 1 and Anim.EaseStyle then
				Progress = TweenService_GetValue(TweenService,
					Progress, Anim.EaseStyle, Anim.EaseDir or Enum.EasingDirection.Out)
			end
			Anim.Value = math.lerp(Anim.Start, Anim.Target, Progress)
			if Anim.Value == Anim.Target then
				Anim.Elapsed = nil
			end
		end
		return Anim
	end
	function AnimMeta.Eval(Anim: Anim, Delta: number, Target: number): Anim
		return Anim:Aim(Target):Compute(Delta):Consume()
	end
	function AnimMeta.Consume(Anim: Anim): Anim
		local Dirty = false
		if Anim.Cached_Value ~= Anim.Value then
			Anim.Cached_Value = Anim.Value
			Dirty = true
		end
		Anim.Dirty = Dirty
		return Anim
	end

	function AnimMeta.SetDuration(Anim: Anim, Duration: number)
		Anim.Duration = Duration
		return Anim
	end
	function AnimMeta.SetEaseDir(Anim: Anim, EaseDir: Enum.EasingDirection?)
		Anim.EaseDir = EaseDir
		return Anim
	end
	function AnimMeta.SetEaseStyle(Anim: Anim, EaseStyle: Enum.EasingStyle?)
		Anim.EaseStyle = EaseStyle
		return Anim
	end
end

return Module