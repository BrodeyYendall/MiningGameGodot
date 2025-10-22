using Godot;
using MiningGame.scripts.helper;

namespace MiningGame.scripts.delve.UI;

public partial class Ui : Control
{
	[Export] private ScoreHolder goldScoreHolder;
	[Export] private ScoreHolder zincScoreHolder;

	public override void _Ready()
	{
		SignalBus.Instance.UpdateOreCount += UpdateOreCount;
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
}