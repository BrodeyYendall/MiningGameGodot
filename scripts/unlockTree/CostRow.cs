using Godot;

namespace MiningGame.scripts.unlockTree;

public partial class CostRow : HBoxContainer
{
	private static readonly PackedScene _attachedScene = ResourceLoader.Load<PackedScene>("res://scenes/unlockTree/CostRow.tscn");

	[Export] public TextureRect IconTextureRect;
	[Export] public Label CostLabel;

	public static CostRow Create(OreTypes oreType, int cost)
	{
		CostRow costRow = _attachedScene.Instantiate<CostRow>();
        
		costRow.Initialize(oreType, cost);
		return costRow;
	}

	public void Initialize(OreTypes oreType, int cost)
	{
		IconTextureRect.Texture = OreType.GetTexture(oreType);
		SetCost(cost);
	}

	public void SetCost(int cost)
	{
		CostLabel.Text = cost.ToString();
	}
}