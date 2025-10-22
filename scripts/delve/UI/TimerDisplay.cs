using Godot;
using System;

public partial class TimerDisplay : TextureRect
{
	[Export] private Label timerLabel;
	
	public void UpdateTime(int remainingTime)
	{
		var timeSpan = TimeSpan.FromSeconds(remainingTime);
		timerLabel.Text = $"{timeSpan.Minutes:D2}:{timeSpan.Seconds:D2}";
	}
}
