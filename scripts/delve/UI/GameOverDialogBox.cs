using Godot;

namespace MiningGame.scripts.delve.UI;

public partial class GameOverDialogBox : Node2D
{
	[Signal] public delegate void RestartDelveEventHandler();
	
	[Export] private ScoreHolder goldScoreHolder;
	[Export] private ScoreHolder zincScoreHolder;
	[Export] private Label depthLabel;

	public new void Hide()
	{
		Visible = false;
	}
	
	public void Show(int goldScore, int zincScore, int depth)
	{
		goldScoreHolder.SetScore(goldScore);
		zincScoreHolder.SetScore(zincScore);
		depthLabel.Text = depth.ToString();
		Visible = true;
	}

	public void AgainButtonPressed()
	{
		EmitSignalRestartDelve();
	}
}