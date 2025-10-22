using Godot;

namespace MiningGame.scripts.delve;

public partial class Countdown : Timer
{
	[Signal] public delegate void CountdownCompletedEventHandler();
	[Signal] public delegate void CountdownIncrementedEventHandler(int remainingTime);
	
	[Export] public int CountDownTime;
	
	private int count;
	
	public void Start()
	{
		count = CountDownTime;
		EmitSignalCountdownIncremented(count);
		base.Start();
	}

	public void IncrementCountdown()
	{
		count--;
		if (count == 0)
		{
			Stop();
			EmitSignalCountdownCompleted();
		}
		EmitSignalCountdownIncremented(count);
	}
	
}