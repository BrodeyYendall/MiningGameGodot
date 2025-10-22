using Godot;

namespace MiningGame.scripts.delve.ores.factory;

public partial class CopperOreFactory : OreFactory<Ore>
{
    
    private static readonly PackedScene _attachedScene = ResourceLoader.Load<PackedScene>("res://scenes/ores/GoldOre.tscn");

    protected override PackedScene GetAttachedScene()
    {
        return _attachedScene;
    }
    
    protected override float GetBaseWidth()
    {
        return 32f;
    }
}