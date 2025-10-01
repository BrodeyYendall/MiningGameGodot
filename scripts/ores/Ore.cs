using System.Collections.Generic;
using Godot;
using Vector2 = Godot.Vector2;

namespace MiningGame.scripts.ores;

public partial class Ore : Area2D
{
    private static readonly int Variance = 2;
    private static readonly int MaxVariance = 6;
    private static readonly int SegmentSize = 16;
    private static readonly int TotalRadius = 64;
    
    private Vector2[] oreVertices;

    public void Initialize(int scale, Vector2 position, uint collision_layer)
    {
        SelectRandomSprite();
        CollisionLayer = collision_layer;
        CollisionMask = collision_layer;
        Position = position;
        Scale = new Vector2(scale, scale);
    }

    private void SelectRandomSprite()
    {
        var sprite = GetNode<Sprite2D>("Sprite");
        var spriteRegion = sprite.RegionRect;
        
        int horizontalCount = sprite.Texture.GetWidth() / (int) spriteRegion.Size.X;
        int verticalCount = sprite.Texture.GetHeight() / (int) spriteRegion.Size.Y;

        int x = GD.RandRange(0, horizontalCount - 1) * (int) spriteRegion.Size.X;
        int y = GD.RandRange(0, verticalCount - 1) * (int) spriteRegion.Size.Y;

        spriteRegion.Position = new Vector2(x, y);
        sprite.RegionRect = spriteRegion;
    }

    public override void _Ready()
    {
        AreaEntered +=  OnAreaEntered;
    }

    private void OnAreaEntered(Area2D area)
    {
        // TODO If area is Cutout. Requires Cutout to be migrated to C# too.
        if (area.Call("point_is_inside", Position).AsBool())
        {
            area.Call("add_ore", this);
            AreaEntered -= OnAreaEntered;
        }
        
    }
    
    
}