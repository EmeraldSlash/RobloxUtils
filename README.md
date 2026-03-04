RobloxUtils is a single module containing reusable code that I find myself needing in many different projects on Roblox.

This module is only a single file so that it can be diffed and copied easily. It also reduces module `require()` clutter.

Some of the code in this module is subject to the following trade-off: some reusable code can noticeably simplify and reduce LOC in usage code, but the boilerplate of defining & importing that code can often negate any benefits one would get. Having all the reusable code be in a single module keeps that code net favourable. It's an economy of scale.

In addition to many trivial/isolated utilities such as table & array operations, doubly-linked-list operations, and math operations, the module contains some more significant structural utilities such as Maids, Signals, AsyncTasks, Arbiters, Caches, and Anims, as well as some utilities that focus on Roblox APIs such as ContextActionMulti, TextMetrics, SafeAreaMetrics, OpacityGroup, a RemoteEvent creation helper, and Instance/object creation helpers.
