extends DisposableBase
class_name BooleanDisposable

var is_disposed : bool
var lock : RLock

func _init():
	self.is_disposed = false
	self.lock = RLock.new()
	
	super._init()

func dispose():
	self.is_disposed = true

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(obj : Object) -> DisposableBase:
	AutoDisposer.Add(obj, self)
	return self
