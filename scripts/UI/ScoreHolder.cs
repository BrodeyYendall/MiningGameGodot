using Godot;

namespace MiningGame.scripts.UI;

public partial class ScoreHolder : Node
{

	[Export] private Texture2D spriteTexture;
	[Export] private Rect2 spriteRegion;

	[Export] private Sprite2D oreSprite;
	[Export] private Label label;

	public int Score => score;
	private int score;
	
	public override void _Ready()
	{
		oreSprite.Texture = spriteTexture;
		oreSprite.RegionRect = spriteRegion;
	}

	public void IncrementScore(int amount = 1)
	{
		SetScore(score + amount);
	}

	public void SetScore(int amount)
	{
		score = amount;
		label.Text = score.ToString("D6");
	}
}