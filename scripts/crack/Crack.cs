using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Runtime.InteropServices.JavaScript;
using Godot;
using Vector2 = Godot.Vector2;

namespace MiningGame.scripts.crack;

public partial class Crack : Area2D
{
    private static readonly PackedScene _attachedScene = ResourceLoader.Load<PackedScene>("res://scenes/crack.tscn");
    
    private static readonly CrackConfig CutoutCrackConfig = new(3, 8, 2, 1, 4, 0.04f, 10); 
    
    [Signal]
    public delegate void CrackCompleteEventHandler(int parent);
    
    private CrackConfig config;
    private Vector2 start;
    private Vector2 end;
    private Vector2 direction;
    private Vector2 perpendicularDirection;
    private int iteration = 2;
    private double deltaTotal = 0; // Keeps track of the delta so we can increment at the animation threshold.
    
    public int[] CrackPointReferences; // TODO Refactor so that this isnt stored here. 

    private readonly List<Vector2> innerLine = [];
    private readonly List<Vector2> outerLine = [];
    private readonly List<int> parentCutouts = [];
    
    public static Crack Create(Vector2 start, Vector2 end, uint collisionLayer, int[] crackPointReferences)
    {
        Crack crack = _attachedScene.Instantiate<Crack>();
        
        crack.Initialize(start, end, collisionLayer, crackPointReferences);
        return crack;
    }
    
    public void Initialize(Vector2 start, Vector2 end, uint collisionLayer, int[] crackPointReferences)
    {
        this.start = start;
        this.end = end;
        CrackPointReferences = crackPointReferences;
        direction = start.DirectionTo(end);
        config = CutoutCrackConfig;
        
        GenerateCrackVertices(start.DistanceTo(end));
        
        GetNode<CollisionPolygon2D>("hitbox").SetPolygon(GetHitboxPolygon());
        SetCollisionLayer(collisionLayer);
        SetCollisionMask(collisionLayer);
    }
    
    public override void _Draw()
    {
        DrawColoredPolygon(GetShortenedPolygon(iteration).ToArray(), Colors.Black);
    }

    public override void _Process(double delta)
    {
        deltaTotal += delta;
        if (deltaTotal > config.AnimationDelay)
        {
            deltaTotal -= config.AnimationDelay;
            iteration++;
            QueueRedraw();
    
            if (iteration >= innerLine.Count)
            {
                SetProcess(false); // Animation is done so we stop this processing.
                
                foreach (var parent in parentCutouts)
                {
                    EmitSignal(SignalName.CrackComplete, parent);
                }
            }
        }
        
        base._Process(delta);
    }

    public Vector2[] GetNearestCrackLine(Vector2 vector)
    {
        var nearestCrackLine = new List<Vector2> {start};

        nearestCrackLine.AddRange(vector.DistanceSquaredTo(start - perpendicularDirection) <
                                  vector.DistanceSquaredTo(start + perpendicularDirection)
            ? outerLine
            : innerLine);

        nearestCrackLine.Add(end);
        return nearestCrackLine.ToArray();
    }

    public void Destory()
    {
        QueueFree();
    }
    
    public void AddParent(int parent)
    {
        parentCutouts.Add(parent);
    }
    
    private void GenerateCrackVertices(float distance)
    {
        perpendicularDirection = new Vector2(-direction.Y, direction.X).Normalized();

        int offset = GD.RandRange(-config.CrackVariance, config.CrackVariance);
        int crackWidth = GD.RandRange(config.MinWidth, config.MaxWidth);
        Vector2 rootPoint = start;

        while (distance > config.SegmentSize * 2)
        {
            rootPoint += (direction * config.SegmentSize);

            offset = GD.RandRange(Mathf.Max(-config.MaxVariance, offset - config.CrackVariance),
                Mathf.Min(config.MaxVariance, offset + config.CrackVariance));
            crackWidth = GD.RandRange(Mathf.Max(config.MinWidth, crackWidth - config.WidthVariance),
                Mathf.Min(config.MaxWidth, crackWidth + config.WidthVariance));

            var innerPoint = rootPoint + (perpendicularDirection * offset).Round();
            var outerPoint = innerPoint + (perpendicularDirection * crackWidth).Round();

            innerLine.Add(innerPoint);
            outerLine.Add(outerPoint);

            distance -= config.SegmentSize;
        }
    }

    /**
     * Gets the crack as a polygon but does not include the start and end vertex.
     * This is to prevent hitbox overlaps I think.
     * TODO See if I should add start/end to this polygon. 
     */
    private Vector2[] GetHitboxPolygon()
    {
        var vertices = new List<Vector2>(innerLine);
        var outerLineCopy = new List<Vector2>(outerLine);
        outerLineCopy.Reverse();
        vertices.AddRange(outerLineCopy);
        return vertices.ToArray();
    }

    private List<Vector2> GetShortenedPolygon(int count)
    {
        var vertices = new List<Vector2> { start };

        var targetLength = Mathf.Min(count, innerLine.Count);
        var shortInner = innerLine.Slice(0, targetLength);
        vertices.AddRange(shortInner);
        
        var shortOuter = outerLine.Slice(0, targetLength);
        shortOuter.Reverse();

        Vector2 shortEnd;
        if (iteration >= innerLine.Count)
        {
            shortEnd = end;
        }
        else
        {
            shortEnd = (shortInner.Last() + shortOuter.First()) / 2; 
        }
        
        vertices.Add(shortEnd);
        vertices.AddRange(shortOuter);
        return vertices;
    }
}