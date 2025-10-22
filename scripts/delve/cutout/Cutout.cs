using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices.JavaScript;
using Godot;
using Godot.Collections;
using MiningGame.scripts.delve.crack;
using MiningGame.scripts.delve.ores;

namespace MiningGame.scripts.delve.cutout;

public partial class Cutout : Area2D
{
    private static readonly PackedScene _attachedScene = ResourceLoader.Load<PackedScene>("res://scenes/delve/cutout/Cutout.tscn");
    [Export] private CollisionPolygon2D hitbox;
    
    public Vector2[] cutoutVertices;
    public List<Crack> cracks;
    private CutoutManager parent;
    private FallingCutout relatedFallingCutout;
    private List<Ore> oresInCutout = new();
    private List<Hole> holesInCutout = new();

    public static Cutout Create(Vector2[] cutoutVertices, List<Crack> cracks, uint collisionLayer, CutoutManager parent)
    {
        Cutout cutout = _attachedScene.Instantiate<Cutout>();
        
        cutout.Initialize(cutoutVertices, cracks, collisionLayer, parent);
        return cutout;
    }
    
    public void Initialize(Vector2[] cutoutVertices, List<Crack> cracks, uint collisionLayer, CutoutManager parent)
    {
        this.cutoutVertices = cutoutVertices;
        this.cracks = cracks;
        this.parent = parent;
        
        CollisionLayer = collisionLayer;
        CollisionMask = collisionLayer;
        
        hitbox.SetPolygon(cutoutVertices);
        GD.Print("Set vertices");
    }

    public override void _Draw()
    {
        DrawColoredPolygon(cutoutVertices, new Color(Colors.Black, 0.2f));
    }

    public void AddOre(Ore ore)
    {
        if (relatedFallingCutout == null)
        {
            // This will be added to the falling cutout when add_falling_cutout_reference is called
            oresInCutout.Add(ore);
        }
        else
        {
            // If the cracks are fast enough then the falling cutout can generate before ore signals its in the cutout.
            // The following line adds the ore retroactively in this scenario. 
            relatedFallingCutout.CallDeferred("AddOre", ore);
        }
    }

    public void AddHole(Hole hole)
    {
        holesInCutout.Add(hole);
    }

    public void AddFallingCutoutReference(FallingCutout fallingCutout)
    {
        relatedFallingCutout = fallingCutout;

        foreach (Ore ore in oresInCutout)
        {
            fallingCutout.AddOre(ore);
        }

        foreach (Hole hole in holesInCutout)
        {
            parent.DestroyCracksAndHole(hole.PointNumber);
        }
    }

    public bool PointIsInside(Vector2 point)
    {
        return Geometry2D.IsPointInPolygon(point, cutoutVertices);
    }

    public void MergeCutout(Cutout cutoutToMerge)
    {
        Array<Vector2[]> merge = Geometry2D.MergePolygons(cutoutToMerge.cutoutVertices, cutoutVertices);

        List<Crack> cracksToRemove = new();
        foreach (Crack crack in cracks)
        {
            if (cutoutToMerge.cracks.Contains(crack)) // Both cutouts share the crack
            {
                cracksToRemove.Add(crack);
            }
        }
        
        // Add each crack from the other cutout which is not also in this crack.
        List<Crack> newCutoutCracks = new List<Crack>(cutoutToMerge.cracks);
        foreach (Crack crack in cracksToRemove)
        {
            newCutoutCracks.Remove(crack);
            cracks.Remove(crack);
            
            parent.DestroyCrack(crack);
        }
        cracks.AddRange(newCutoutCracks);
        
        Initialize(merge[0], cracks, CollisionLayer, parent);
        QueueRedraw();

        cutoutToMerge.Destroy();
    }

    public void Destroy()
    {
        QueueFree();
    }

    public int GetParentWallCount()
    {
        return parent.parentWall.WallNumber;
    }
}