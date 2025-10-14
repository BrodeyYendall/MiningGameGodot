using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Godot;
using MiningGame.scripts.autoload;
using MiningGame.scripts.crack;
using MiningGame.scripts.cutout;
using MiningGame.scripts.helper;

namespace MiningGame.scripts;

public partial class Wall: Node2D, ICollisionObjectCreator
{
    private static readonly PackedScene _attachedScene = ResourceLoader.Load<PackedScene>("res://scenes/wall.tscn");
    
    private static readonly int CrackDistance = 200;
    private static readonly int NewHoleHitbox = 20;
    
    [Export] private Node2D holeHolder;
    [Export] private Node2D crackHolder;
    [Export] private CutoutQueue cutoutQueue;
    [Export] private Node2D contents;
    [Export] private Background background;

    [Signal] public delegate void GenerateBackgroundEventHandler(int wallCount);
    [Signal] public delegate void CycleFormedEventHandler(Vector2[] cutoutVertices, Crack[] newCracks, Crack[] allCracks, Wall wall);
    [Signal] public delegate void OreCutoutEventHandler(int wallReference);

    private uint collisionLayer = 0;
    public uint CollisionLayer => collisionLayer;
    
    private Dictionary<int, Dictionary<int, Crack>> cracks = new();
    private Dictionary<int, Hole>  holes = new();
    private int currentHoleId = 0;
    private AStar2D pathfinder = new();
    
    private int wallNumber = 1;
    public int WallNumber => wallNumber;
    private Node2D fallingCutoutHolder;

    public static Wall Create(int wallCount, Node2D fallingCutoutHolder)
    {
        Wall wall = _attachedScene.Instantiate<Wall>();
        
        wall.Initialize(wallCount, fallingCutoutHolder);
        return wall;
    }
    
    public void Initialize(int wallCount, Node2D fallingCutoutHolder)
    {
        this.wallNumber = wallCount;
        this.fallingCutoutHolder = fallingCutoutHolder;
    }
    
    public override void _Ready()
    {
        cutoutQueue.fallingCutoutHolder = fallingCutoutHolder;
        CollisionLayerHelper.GetAndSetWallCollisionLayer(this);
        SetProcessInput(false);
        
        background.Initialize();
        EmitSignalGenerateBackground(wallNumber);
    }

    public void CreateHole(Vector2 position)
    {
        if (!RaycastHelper.Instance.RaycastCircle(position, NewHoleHitbox, collisionLayer).Any())
        {
            GD.Print($"Hole {currentHoleId} created @ {position}");
            pathfinder.AddPoint(currentHoleId, position);

            (List<int>, List<Crack>) newCracks = CreateNewCracks(currentHoleId);

            if (newCracks.Item1.Count >= 2)
            {
                CheckForCycle(newCracks.Item1, newCracks.Item2, Position);
            }

            foreach (int newConnectionId in newCracks.Item1)
            {
                pathfinder.ConnectPoints(currentHoleId, newConnectionId);
            }

            CreateHoleObject(position);
            QueueRedraw();
        }
    }

    private (List<int>, List<Crack>) CreateNewCracks(int newPointId)
    {
        Vector2 newPointPosition = pathfinder.GetPointPosition(newPointId);

        List<int> newConnections = [];
        List<Crack> newCracks = [];

        foreach (int id in holes.Keys)
        {
            if (CanGenerateCrack(newPointPosition, holes[id]))
            {
                var crack = Crack.Create(holes[id].Position, newPointPosition, collisionLayer, [id, currentHoleId]);
                crackHolder.AddChild(crack);
                
                newConnections.Add(id);
                newCracks.Add(crack);
                
                AddToCrackMap(id, currentHoleId, crack);
            }
        }
        
        return (newConnections, newCracks);
    }

    private bool CanGenerateCrack(Vector2 start, Hole end)
    {
        if (end.Position.DistanceTo(start) > CrackDistance)
        {
            return false;
        }

        // Return true if the object hit is the target hole. This means that nothing else was in the way.
        // We do not exclude the target circle because cutouts attached to it will get in the way
        Godot.Collections.Dictionary result = RaycastHelper.Instance.RaycastLine(start, end.Position, collisionLayer);
        return result.TryGetValue("rid", out var raycastRid) && raycastRid.As<Rid>().Equals(end.GetRid());
    }

    private void CheckForCycle(List<int> newConnections, List<Crack> newCracks, Vector2 newHole)
    {
        List<List<long>> cycles = [];
        for (int i = 0; i < newConnections.Count; i++)
        {
            for (int j = i + 1; j < newConnections.Count; j++)
            {
                long[] path = pathfinder.GetIdPath(newConnections[i], newConnections[j]);
                if (path.Length > 0)
                {
                    cycles.Add([..path]);
                }
            }
        }
        cycles.Sort((a, b) => a.Count.CompareTo(b.Count));

        HashSet<long> pointsUsed = [];
        foreach(List<long> cycle in cycles)
        {
            cycle.Insert(0, currentHoleId);
            cycle.Add(currentHoleId);

            Vector2 cycleCentre = CalculateCutoutCentre(cycle);
            bool containsUniquePoints = false;
            List<Vector2> pathVertices = [];
            List<Crack> cracksInCutout = [];

            for (int i = 1; i < cycle.Count; i++)
            {
                long currentPoint = cycle[i];
                if (!pointsUsed.Contains(i))
                {
                    containsUniquePoints = true;
                    pointsUsed.Add(currentPoint);
                }

                long prevPoint = cycle[i - 1];
                (Crack, Vector2[]) crack = GetFromCrackMap((int) prevPoint, (int) currentPoint, cycleCentre);
                cracksInCutout.Add(crack.Item1);

                List<Vector2> crackVertices = new List<Vector2>(crack.Item2);
                if (i != crackVertices.Count)
                {
                    crackVertices = crackVertices.Slice(0, crackVertices.Count -1);
                }
                pathVertices.AddRange(crackVertices);
            }

            if (containsUniquePoints)
            {
                EmitSignalCycleFormed(pathVertices.ToArray(), newCracks.ToArray(), cracksInCutout.ToArray(), this);
            }
        }

    }
    
    public Vector2 CalculateCutoutCentre(List<long> cutoutHoles)
    {
        var total = new Vector2(0, 0);
        foreach (long hole in cutoutHoles)
        {
            Vector2 pointPosition = pathfinder.GetPointPosition(hole);
            total += pointPosition;
        }

        return total / cutoutHoles.Count;
    }


    private void AddToCrackMap(int firstId, int secondId, Crack crack)
    {
        GD.Print($"Adding {firstId} -> {secondId} = {crack} to map"); // TODO Replace prints with logging?
        var submap = cracks.GetValueOrDefault(firstId, new Dictionary<int, Crack>());
        submap[secondId] = crack;
        cracks[firstId] = submap;
    }
    
    private (Crack, Vector2[]) GetFromCrackMap(int firstId, int secondId, Vector2 cutoutCentre)
    {
        Crack crack = cracks.GetValueOrDefault(firstId, new Dictionary<int, Crack>()).GetValueOrDefault(secondId, null);
        if (crack == null)
        {
            crack = cracks.GetValueOrDefault(secondId, new Dictionary<int, Crack>()).GetValueOrDefault(firstId, null);
            Vector2[] backwards = crack.GetNearestCrackLine(cutoutCentre);
            Array.Reverse(backwards);

            return (crack, backwards);
        }

        return (crack, crack.GetNearestCrackLine(cutoutCentre));
    }

    private Hole CreateHoleObject(Vector2 holePosition)
    {
        var hole = Hole.Create(currentHoleId, holePosition, collisionLayer);
        hole.DestroyHole += DestroyCracksAndHole;
        
        holeHolder.AddChild(hole);
        holes[currentHoleId] = hole;
        currentHoleId++;
        return hole;
    }

    private void EmitOreCutout()
    {
        EmitSignalOreCutout(wallNumber);
    }

    public void Destroy()
    {
        contents.Visible = false;
        contents.QueueFree();
        cutoutQueue.Destroy();
    }

    public void DestroyCracksAndHole(int pointId) // Make Wall responsible for managing the destruction of Cutouts/Cracks/Holes
    {
        foreach (int connection in pathfinder.GetPointConnections(pointId))
        {
            DestroyCrack(connection, pointId);
        }
    }

    public void DestroyCrack(int start, int end)
    {
        GD.Print($"Destroying {start} <-> {end}");
        pathfinder.DisconnectPoints(start, end);

        RemovePointFromCrackMap(start, end);
        RemovePointFromCrackMap(end, start);
    }

    private void RemovePointFromCrackMap(int start, int end)
    {
        if (cracks.TryGetValue(start, out var subDict))
        {
            if (subDict.TryGetValue(end, out var dest))
            {
                dest.Destory();
                subDict.Remove(end);
            }
        }
        if (pathfinder.GetPointConnections(start).Length == 0)
        {
            DestroyPoint(start);
        }
        else
        {
            GD.Print($"{start} connects to {pathfinder.GetPointConnections(start)}");
        }
    }

    private void DestroyPoint(int pointId)
    {
        GD.Print($"Destroying {pointId}");
        cracks.Remove(pointId);
        holes[pointId].Destroy();
        holes.Remove(pointId);
        pathfinder.RemovePoint(pointId);
    }
    

    public async Task Render()
    {
        await background.WaitForRender();
    }

    public void SetCollisionLayer(uint collisionLayer)
    {
        this.collisionLayer = collisionLayer;
    }
}