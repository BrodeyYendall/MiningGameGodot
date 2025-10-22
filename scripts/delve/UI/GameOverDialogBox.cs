using Godot;
using MiningGame.scripts.helper;

namespace MiningGame.scripts.delve.UI;

public partial class GameOverDialogBox : Node2D
{
	[Signal] public delegate void RestartDelveEventHandler();
	
	[Export] private ScoreHolder goldScoreHolder;
	[Export] private ScoreHolder zincScoreHolder;
	[Export] private Label depthLabel;

	public override void _Ready()
	{
		SignalBus.Instance.UpdateOreCount += UpdateOreCount;
	}

	public new void Hide()
	{
		Visible = false;
	}
	
	private void UpdateOreCount(string type, int oreCount)
	{
		switch (type)
		{
			case "Gold":
				goldScoreHolder.SetScore(oreCount);
				break;
			case "Zinc":
				zincScoreHolder.SetScore(oreCount);
				break;
		}
	}
	
	public void Show(int depth)
	{
		depthLabel.Text = depth.ToString();
		Visible = true;
	}

	public void AgainButtonPressed()
	{
		EmitSignalRestartDelve();
	}
}