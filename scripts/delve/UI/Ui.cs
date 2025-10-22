using Godot;
using MiningGame.scripts.delve.ores;

namespace MiningGame.scripts.delve.UI;

public partial class Ui : Control
{

	[Export] private ScoreHolder goldScoreHolder;
	[Export] private ScoreHolder zincScoreHolder;
	
	public void ProcessOreCutout(Ore ore)
	{
		switch (ore.Type)
		{
			case "Gold":
				goldScoreHolder.IncrementScore();
				break;
			case "Zinc":
				zincScoreHolder.IncrementScore();
				break;
		}
	}

	public void Restart()
	{
		goldScoreHolder.SetScore(0);
		zincScoreHolder.SetScore(0);
	}

	public int GetGoldScore()
	{
		return goldScoreHolder.Score;
	}

	public int GetZincScore()
	{
		return zincScoreHolder.Score;
	}
	
}