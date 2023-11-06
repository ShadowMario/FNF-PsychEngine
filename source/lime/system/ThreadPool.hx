package lime.system;

import haxe.Constraints.Function;
import lime.app.Application;
import lime.app.Event;
#if sys
#if haxe4
import sys.thread.Deque;
import sys.thread.Thread;
#elseif cpp
import cpp.vm.Deque;
import cpp.vm.Thread;
#elseif neko
import neko.vm.Deque;
import neko.vm.Thread;
#end
#end
#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class ThreadPool
{
	public var currentThreads(default, null):Int;
	public var doWork = new Event<Dynamic->Void>();
	public var maxThreads:Int;
	public var minThreads:Int;
	public var onComplete = new Event<Dynamic->Void>();
	public var onError = new Event<Dynamic->Void>();
	public var onProgress = new Event<Dynamic->Void>();
	public var onRun = new Event<Dynamic->Void>();

	#if (cpp || neko)
	@:noCompletion private var __synchronous:Bool;
	@:noCompletion private var __workCompleted:Int;
	@:noCompletion private var __workIncoming = new Deque<ThreadPoolMessage>();
	@:noCompletion private var __workQueued:Int;
	@:noCompletion private var __workResult = new Deque<ThreadPoolMessage>();
	#end

	public function new(minThreads:Int = 0, maxThreads:Int = 1)
	{
		this.minThreads = minThreads;
		this.maxThreads = maxThreads;

		currentThreads = 0;

		#if (cpp || neko)
		__workQueued = 0;
		__workCompleted = 0;
		#end

		#if (emscripten || force_synchronous)
		__synchronous = true;
		#end
	}

	// public function cancel (id:String):Void {
	//
	//
	//
	// }
	// public function isCanceled (id:String):Bool {
	//
	//
	//
	// }
	public function queue(state:Dynamic = null):Void
	{
		#if (cpp || neko)
		// TODO: Better way to handle this?

		if (Application.current != null && Application.current.window != null && !__synchronous)
		{
			__workIncoming.add(new ThreadPoolMessage(WORK, state));
			__workQueued++;

			if (currentThreads < maxThreads && currentThreads < (__workQueued - __workCompleted))
			{
				currentThreads++;
				Thread.create(__doWork);
			}

			if (!Application.current.onUpdate.has(__update))
			{
				Application.current.onUpdate.add(__update);
			}
		}
		else
		{
			__synchronous = true;
			runWork(state);
		}
		#else
		runWork(state);
		#end
	}

	public function sendComplete(state:Dynamic = null):Void
	{
		#if (cpp || neko)
		if (!__synchronous)
		{
			__workResult.add(new ThreadPoolMessage(COMPLETE, state));
			return;
		}
		#end

		onComplete.dispatch(state);
	}

	public function sendError(state:Dynamic = null):Void
	{
		#if (cpp || neko)
		if (!__synchronous)
		{
			__workResult.add(new ThreadPoolMessage(ERROR, state));
			return;
		}
		#end

		onError.dispatch(state);
	}

	public function sendProgress(state:Dynamic = null):Void
	{
		#if (cpp || neko)
		if (!__synchronous)
		{
			__workResult.add(new ThreadPoolMessage(PROGRESS, state));
			return;
		}
		#end

		onProgress.dispatch(state);
	}

	@:noCompletion private function runWork(state:Dynamic = null):Void
	{
		#if (cpp || neko)
		if (!__synchronous)
		{
			__workResult.add(new ThreadPoolMessage(WORK, state));
			doWork.dispatch(state);
			return;
		}
		#end

		onRun.dispatch(state);
		doWork.dispatch(state);
	}

	#if (cpp || neko)
	@:noCompletion private function __doWork():Void
	{
		while (true)
		{
			var message = __workIncoming.pop(true);

			if (message.type == WORK)
			{
				runWork(message.state);
			}
			else if (message.type == EXIT)
			{
				break;
			}
		}
	}

	@:noCompletion private function __update(deltaTime:Float):Void
	{
		if (__workQueued > __workCompleted)
		{
			var message = __workResult.pop(false);

			while (message != null)
			{
				switch (message.type)
				{
					case WORK:
						onRun.dispatch(message.state);

					case PROGRESS:
						onProgress.dispatch(message.state);

					case COMPLETE, ERROR:
						__workCompleted++;

						if ((currentThreads > (__workQueued - __workCompleted) && currentThreads > minThreads)
							|| currentThreads > maxThreads)
						{
							currentThreads--;
							__workIncoming.add(new ThreadPoolMessage(EXIT, null));
						}

						if (message.type == COMPLETE)
						{
							onComplete.dispatch(message.state);
						}
						else
						{
							onError.dispatch(message.state);
						}

					default:
				}

				message = __workResult.pop(false);
			}
		}
		else
		{
			// TODO: Add sleep if keeping minThreads running with no work?

			if (currentThreads == 0 && minThreads <= 0 && Application.current != null)
			{
				Application.current.onUpdate.remove(__update);
			}
		}
	}
	#end
}

private enum ThreadPoolMessageType
{
	COMPLETE;
	ERROR;
	EXIT;
	PROGRESS;
	WORK;
}

private class ThreadPoolMessage
{
	public var state:Dynamic;
	public var type:ThreadPoolMessageType;

	public function new(type:ThreadPoolMessageType, state:Dynamic)
	{
		this.type = type;
		this.state = state;
	}
}
