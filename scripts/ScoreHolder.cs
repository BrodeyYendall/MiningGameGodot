using Godot;
using System;

public partial class ScoreHolder : TextureRect
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
		score += amount;
		label.Text = score.ToString("D6");
	}
}
