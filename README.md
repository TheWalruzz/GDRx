# GodotRx - Reactive Extensions for the Godot Game Engine version 4 (GDRx)

## Warning
**Untested** While this is almost a direct port of RxPY, this library has not 
yet been fully tested in action. Proceed with caution!

## What is GodotRx?
GodotRx (short: GDRx) is a full implementation of ReactiveX for the Godot Game 
Engine 4. The code was originally ported from RxPY (see: 
https://github.com/ReactiveX/RxPY) as Python shares a lot of similarities with 
GDScript.

**Why Rx?** ReactiveX allows a more declarative programming style working on 
observable data streams. It encourages high cohesion 
and low coupling rendering the code more easily readable and extendable.

The Godot Engine brings a well thought-out event system as well as
a nice implementation of coroutines to the table. It allows you to easily 
implement asynchronous code execution, meaning basically that code is not run in
the sequence order which it is written in. A so-called Observer listens to an 
Observable event which fires when something important happens in the program 
resulting in side-effects for the connected instances, this can be e.g. a player
attacking an enemy or an item which is picked up.

Rx extends this idea by turning all forms of data within the program like 
GD-signals, GD-lifecycle events, callbacks, data structures, coroutines etc. 
into observable data streams which emit items. These data streams, refered to as 
Observables, can be transformed using concepts from the world of functional 
programming. (Say hello to Flat-Map, Reduce and friends!)

## Installation
You can add GDRx to your Godot 4 project as followed:

1. Download this repository as an archive.
2. Navigate to your project root folder.
3. Extract GDRx into your project. The folder should be named `res://reactivex/`.
4. Add the singleton script with name 'GDRx' to autoload (`res://reactivex//__gdrxsingleton__.gd`)
5. GDRx should now be ready to use. Try creating a simple Observable using:

```csharp
GDRx.just(42).subscribe(func(i): print("The answer: " + str(i)))
```

## Usage
### Coroutines
Assume we have a coroutine which executes code, awaits a signal and then continues
by calling a second coroutine (in another instance for example) if a condition
is met.

```csharp
var _reference

func _ready():
	coroutine1()

func coroutine1():
	# ... 
	print("Do something.")
	# ...
	await get_tree().create_timer(1.0).timeout
	# ...
	print("Do something.")
	# ...
	if self._reference != null:
		await self._reference.coroutine2()
	await coroutine3()

func coroutine3():
	await get_tree().create_timer(1.0).timeout
	print("Done.")
```
Following a good coding style, each of these three coroutines execute one 
specific task, however, the first coroutine is also tasked with handling control
flow (null check of self._reference). GDRx allows us to easily coordinate 
these program parts by providing a declarative execution plan.

```csharp
var _reference

func _ready():
	GDRx.concat_streams([
		GDRx.from_coroutine(coroutine1),
		GDRx.if_then(
			func(): return self._reference != null,
			GDRx.from_coroutine(func(): await self._reference.coroutine2())
		),
		GDRx.from_coroutine(coroutine3),
	]).subscribe()

func coroutine1():
	# ... 
	print("Do something.")
	# ...
	await get_tree().create_timer(1.0).timeout
	# ...
	print("Do something.")
	# ...

func coroutine3():
	await get_tree().create_timer(1.0).timeout
	print("Done.")
```
As you can see, coroutine1() now only contains code bound to the task it should
run. Remember: In good code design, each function should execute a single 
computational step only.
