using System.Collections.Generic;
using Godot;
using MiningGame.scripts.cutout;
using Vector2 = Godot.Vector2;

namespace MiningGame.scripts.ores;

public partial class Ore : Area2D
{
    [Export] private Sprite2D sprite;
    
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
        var spriteRegion = sprite.RegionRect;
        
        int horizontalCount = sprite.Texture.GetWidth() / (int) spriteRegion.Size.X;
        int verticalCount = sprite.Texture.GetHeight() / (int) spriteRegion.Size.Y;

        int x = GD.RandRange(0, horizontalCount - 1) * (int) spriteRegion.Size.X;
        int y = GD.RandRange(0, verticalCount - 1) * (int) spriteRegion.Size.Y;

        spriteRegion.Position = new Vector2(x, y);
        sprite.RegionRect = spriteRegion;
    }

    private void OnAreaEntered(Area2D area)
    {
        if (area is Cutout cutout)
        {
            if (cutout.PointIsInside(Position))
            {
                cutout.AddOre(this);
                SetDeferred("Monitoring", false);
                SetDeferred("Monitorable", false);
            }
        }
    }

    public void ChangeParent(Node parent)
    {
        GetParent().RemoveChild(this);
        parent.AddChild(this);
    }
    
    
}