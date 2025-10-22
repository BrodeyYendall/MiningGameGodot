using Godot;

namespace MiningGame.scripts.delve.UI;

public partial class ScoreHolder : Node
{

	[Export] private Texture2D spriteTexture;
	[Export] private Rect2 spriteRegion;

	[Export] private Sprite2D oreSprite;
	[Export] private Label label;
	
	public override void _Ready()
	{
		oreSprite.Texture = spriteTexture;
		oreSprite.RegionRect = spriteRegion;
	}

	public void SetScore(int amount)
	{
		label.Text = amount.ToString("D6");
	}
}