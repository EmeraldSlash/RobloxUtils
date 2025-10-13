--!strict

--
-- Various utilities that are useful in Roblox.
--
-- Created by Rio Manson-Hay (@EmeraldSlash)
--
-- Version 1 (2025-10-13)
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
-- .PropsApply()
-- .I()
-- .C()
-- .ObjectPropsApply()
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
-- Maid:Remove()
-- Maid:Clean/Destroy()
-- Maid:Push()
-- Maid:SetParent()
--
-- type BulkMoveTo
-- .BMT_New()
-- BulkMoveTo:Add()
-- BulkMoveTo:Apply()
--
-- type AsyncTask
-- .AsyncTaskSpawn()
-- .AsyncTaskDefer()
-- .AsyncTaskDelay()
-- AsyncTask:IsRunning()
-- AsyncTask:Destroy()
--
-- type DLL_Node
-- .DLL_Create()
-- .DLL_ClearSentinelReferences()
-- .DLL_ClearLinks()
-- .DLL_Append()
-- .DLL_AppendFirst()
-- .DLL_IsInside()
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
   local PropsTables: {Props} = {...}
   for _, ThisProps in PropsTables do
      for Key, Value in ThisProps do
         Props[Key] = Value
      end
   end
   return Props
end
function Module.PropsApply(TargetInstance: Instance, ...: Props): Instance

   local PropsTables: {Props} = {...}
   if PropsTables[1] then

      local Props
      if not PropsTables[2] then
         Props = PropsTables[1]
      else
         Props = {}
         for _, ThisProps in PropsTables do
            for Key, Value in ThisProps do
               Props[Key] = Value
            end
         end
      end

      for Key, Value in Props do
         if Key ~= "Parent" then
            (TargetInstance :: any)[Key] = Value
         end
      end
      if Props.Parent then
         TargetInstance.Parent = Props.Parent
      end

   end

   return TargetInstance
end

-- Helper functions for quickly creating and cloning instances.
function Module.I(ClassName: string, ...: Props)
   local NewInstance = Instance.new(ClassName)
   Module.PropsApply(NewInstance, ...)
   return NewInstance
end
function Module.C<T>(TemplateInstance: T & Instance, ...: Props): T
   local NewInstance = TemplateInstance:Clone()
   Module.PropsApply(NewInstance, ...)
   return NewInstance
end

-- Similar to PropsApply, but used for any kind of object which may not be an
-- instance (such as RaycastParams and OverlapParams).
function Module.ObjectPropsApply<T>(Object: T, ...: Props): T

   local PropsTables: {Props} = {...}
   if PropsTables[1] then

      local Props
      if not PropsTables[2] then
         Props = PropsTables[1]
      else
         Props = {}
         for _, ThisProps in PropsTables do
            for Key, Value in ThisProps do
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
   return Module.ObjectPropsApply(RaycastParams.new(), ...)
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
   return Module.ObjectPropsApply(OverlapParams.new(), ...)
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
-- This maid can take all the usual data types (Instances, functions, threads,
-- connections), tables with Destroy or Disconnect methods (Destroy method will
-- always be preferred over Disconnect method), and other Maids (tables that do
-- not have the aforementioned methods but which have a Values table field will
-- be treated as if they are a Maid).
export type HasDestroy<T> = T & {
   Destroy: (T)->();
}
export type HasDisconnect<T> = T & {
   Disconnect: (T)->();
}
export type Maid = {
   MaidValues: {
      -- These are the kinds of things you can add to a Maid.
      | RBXScriptConnection
      | Instance
      | thread
      | ()->()
      | HasDestroy<any>
      | HasDisconnect<any>
      | Maid
   };
   MaidParent: Maid?;

   -- Adds or removes values from a Maid.
   Add: <T...>(Maid: Maid, T...)->(T...);
   Remove: <T...>(Maid: Maid, T...)->(T...);

   -- Cleanup methods (different aliases for the same method)
   Clean: (Maid: Maid)->();
   Destroy: (Maid: Maid)->();

   -- Creates a new, unrelated Maid. Equivalent to Module.MaidNew().
   New: (_: any)->();

   -- Call this on the parent! Create a child maid whose lifetime is tied to the
   -- parent Maid. The child maid will be automatically removed from the parent
   -- when the child is cleaned up.
   Push: (Parent: Maid)->(Maid);

   -- Call this on the child! Updates the parent of the child maid, and will
   -- never affect the child's lifetime. Returns the previous parent, if there
   -- was one.
   --
   -- Remove from from a parent, like Child:SetParent(nil).
   -- Set a new parent, like Child:SetParent(Parent).
   --
   -- If setting a new parent, if the maid had a previous parent then it will
   -- be removed from that parent first.
   --
   SetParent: (Child: Maid, Parent: Maid?)->(Maid?);
}
do
   local MaidMeta: Maid =
      (function(): any local Class = {}; Class.__index = Class; return Class; end)()

   local function MakeArray(...: any): {any}
      return {...}
   end

   function MaidMeta.Add<T...>(Maid: Maid, ...: T...): (T...)
      for _, Value in MakeArray(...) do
         Maid.MaidValues[#Maid.MaidValues+1] = Value
      end
      return ...
   end

   function MaidMeta.Remove<T...>(Maid: Maid, ...: T...): (T...)
      for _, Value in MakeArray(...) do
         local Index = table.find(Maid.MaidValues, Value)
         if Index then
            table.remove(Maid.MaidValues, Index)
         end
      end
      return ...
   end

   function MaidMeta.Clean(Maid: Maid)
      -- Recursive references will also be handled without infinite loops because
      -- every step will remove something. However it will be inefficient in time
      -- and memory usage as tables will be redundantly pushed to the stack, but I
      -- don't think that's bad enough to to be worth storing a lookup table of
      -- tables that have already been seen.
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
      local MaidStack: {Maid} = {Maid}
      while true do
         local CurrentMaid = MaidStack[#MaidStack]
         local Value = table.remove(CurrentMaid.MaidValues)
         if not Value then
            MaidStack[#MaidStack] = nil
            if not MaidStack[1] then
               break
            end
         elseif typeof(Value) == "RBXScriptConnection" then
            Value:Disconnect()
         elseif typeof(Value) == "Instance" then
            Value:Destroy()
         elseif type(Value) == "thread" then
            coroutine.close(Value)
         elseif type(Value) == "function" then
            task.spawn(Value)
         elseif type(Value) == "table" then
            if type((Value :: HasDestroy<any>).Destroy) == "function" then
               (Value :: HasDestroy<any>):Destroy()
            elseif type((Value :: HasDisconnect<any>).Disconnect) == "function" then
               (Value :: HasDisconnect<any>):Disconnect()
            elseif type((Value :: Maid).MaidValues) == "table" then
               local ValueMaid = Value :: Maid
               local ValueMaidParent = ValueMaid.MaidParent
               if ValueMaidParent then
                  if ValueMaidParent == CurrentMaid then
                     -- Reduce unnecessary searching in parent by clearing here
                     ValueMaid.MaidParent = nil
                  else
                     -- Remove the maid from it's previous parent.
                     -- Equivalent to Maid:SetParent(nil).
                     local Index = table.find(ValueMaidParent.MaidValues, Maid)
                     if Index then
                        table.remove(ValueMaidParent.MaidValues, Index)
                     end
                  end
               end
               MaidStack[#MaidStack+1] = ValueMaid
            else
               warn(debug.traceback("Table found in Maid was not another Maid and did not have a Destroy or Disconnect method."))
            end
         end
      end
      debug.profileend()
   end
   MaidMeta.Destroy = MaidMeta.Clean

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
export type AsyncTask = {
   Thread: thread?;

   IsRunning: (AT: AsyncTask)->(boolean);
   Destroy: (AT: AsyncTask)->();
}
do
   local AsyncTaskMeta: AsyncTask =
      (function(): any local Class = {}; Class.__index = Class; return Class; end)()

   function AsyncTaskMeta.IsRunning(AT: AsyncTask): boolean
      return if AT.Thread then coroutine.status(AT.Thread) ~= "dead" else false
   end

   function AsyncTaskMeta.Destroy(AT: AsyncTask)
      local Thread = AT.Thread
      if Thread then
         AT.Thread = nil
         if coroutine.running() ~= Thread then
            coroutine.close(Thread)
         end
      end
   end

   function Module.AsyncTaskSpawn(Func: ()->()): AsyncTask
      local AT: AsyncTask = setmetatable({}, AsyncTaskMeta) :: any
      AT.Thread = coroutine.create(function()
         Func()
         AT.Thread = nil
      end)
      task.spawn(AT.Thread :: any)
      return AT
   end
   function Module.AsyncTaskDefer(Func: ()->()): AsyncTask
      local AT: AsyncTask = setmetatable({}, AsyncTaskMeta) :: any
      AT.Thread = coroutine.create(function()
         Func()
         AT.Thread = nil
      end)
      task.defer(AT.Thread :: any)
      return AT
   end
   function Module.AsyncTaskDelay(Duration: number, Func: ()->()): AsyncTask
      local AT: AsyncTask = setmetatable({}, AsyncTaskMeta) :: any
      AT.Thread = coroutine.create(function()
         Func()
         AT.Thread = nil
      end)
      task.delay(Duration, AT.Thread :: any)
      return AT
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
   local DLL = {} :: DLL_Node<T>
   DLL.DLL_Sentinel = DLL
   DLL.DLL_Next = DLL
   DLL.DLL_Prev = DLL
   return DLL
end
function Module.DLL_ClearSentinelReferences<T>(DLL: DLL_Node<T>)
   local Current = DLL.DLL_Next
   while Current ~= DLL do
      Current.DLL_Sentinel = nil :: any
      Current = Current.DLL_Next
   end
end
function Module.DLL_ClearLinks<T>(DLL: DLL_Node<T>)
   DLL.DLL_Next = DLL
   DLL.DLL_Prev = DLL
end
function Module.DLL_Append<T>(DLL: DLL_Node<T>, Node: DLL_Node<T>)
   Node.DLL_Sentinel = DLL
   Node.DLL_Next = DLL
   Node.DLL_Prev = DLL.DLL_Prev

   DLL.DLL_Prev.DLL_Next = Node
   DLL.DLL_Prev = Node
end
function Module.DLL_AppendFirst<T>(DLL: DLL_Node<T>, Node: DLL_Node<T>)
   Node.DLL_Sentinel = DLL.DLL_Sentinel
   Node.DLL_Next = DLL.DLL_Next
   Node.DLL_Prev = DLL
   
   DLL.DLL_Next.DLL_Prev = Node
   DLL.DLL_Next = Node
end
function Module.DLL_IsInside<T>(DLL: DLL_Node<T>, Node: DLL_Node<T>): boolean
   return Node.DLL_Sentinel == DLL
end
function Module.DLL_IsSentinel<T>(Node: DLL_Node<T>): boolean
   return Node.DLL_Sentinel == Node
end
function Module.DLL_Remove<T>(Node: DLL_Node<T>)
   if Node.DLL_Sentinel then
      Node.DLL_Sentinel = nil :: any
      Node.DLL_Next.DLL_Prev = Node.DLL_Prev
      Node.DLL_Prev.DLL_Next = Node.DLL_Next
   end
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
-- replacing the CAM.Inputs field.
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
   -- Only works with CAMs created via CAMS_NewBound, or which have the Inputs
   -- field set.
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
      assert(type(InputsToBind) == "table", "CAM_NewBound(): Inputs to bind must be a table")
      assert(type(Action) == "function", "CAM_NewBound(): Action must be a function")

      return setmetatable({
         Name = Name;
         Priority = Priority;
         InputsToBind = InputsToBind;
         Action = Action;
      }, CAMMeta) :: any
   end
   function CAMMeta.SetBound(CAM: ContextActionMulti, Bound: boolean)
      assert(CAM.InputsToBind, "CAM:SetBound(): CAM is missing InputsToBind field. Did you forget to call CAM_NewBound()?")
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
      local Array = {...} -- even if ... has nils, #Array will be correct.
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
   @native
   function CacheMeta.AddArray(Cache: Cache, Array: {any}): boolean
      local JustDirty = false
      for Index = 1, #Array do -- assume that #Array is correct: if not, it is the user's fault.
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
      local Array = {...} -- even if ... has nils, #Array will be correct.
      for Index = 1, #Array do
         local Dirty = Array[Index]
         if Dirty then
            Cache.DirtySoFar = true
            JustDirty = true
         end
      end
      Cache.Dirty = Cache.DirtySoFar or (Cache.CurrCount ~= Cache.PrevCount)
      return JustDirty
   end
end

return Module