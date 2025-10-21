using Godot;
using System;
using Godot.Collections;
using MiningGame.scripts.ores;

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
	
}
