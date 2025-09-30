using Godot;

namespace MiningGame.scripts.ores.factory;

public partial class ZincOreFactory : OreFactory<Ore>
{
    
    private static readonly PackedScene _attachedScene = ResourceLoader.Load<PackedScene>("res://scenes/ores/ball_ore.tscn");

    protected override PackedScene GetAttachedScene()
    {
        return _attachedScene;
    }
    
    protected override float GetBaseRadius()
    {
        return 40f;
    }
}