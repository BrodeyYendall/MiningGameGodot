using Godot;

namespace MiningGame.scripts.ores.factory;

public partial class ZincOreFactory : OreFactory<Ore>
{
    
    private static readonly PackedScene _attachedScene = ResourceLoader.Load<PackedScene>("res://scenes/ores/ZincOre.tscn");

    protected override PackedScene GetAttachedScene()
    {
        return _attachedScene;
    }
    
    protected override float GetBaseWidth()
    {
        return 32f;
    }
}