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
    
    private int size;
    private Vector2[] oreVertices;

    public void Initialize(int size, Vector2 position, uint collision_layer)
    {
        this.size = size;

        List<Vector2> oreVerticesList = new();
        var offset = 0;

        for (int segment = 0; segment < SegmentSize; segment++)
        {
            offset = GD.RandRange(Mathf.Max(0, offset - Variance), Mathf.Min(MaxVariance, offset + Variance));

            var angle = (Mathf.Pi * 2 / SegmentSize) * segment;
            var x = offset + size * Mathf.Cos(angle);
            var y = offset + size * Mathf.Sin(angle);
            
            oreVerticesList.Add(new Vector2(x, y));
        }
        
        oreVertices = oreVerticesList.ToArray();
        GetNode<CollisionPolygon2D>("hitbox").SetPolygon(oreVertices);
        Position = position;
        SetCollisionLayer(collision_layer);
        SetCollisionMask(collision_layer);
    }

    public override void _Draw()
    { 
        var color = Colors.SaddleBrown;
        DrawColoredPolygon(oreVertices, color);
        DrawPolyline(oreVertices, color.Darkened(0.1f), 1);
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