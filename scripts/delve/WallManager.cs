using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;
using Godot.Collections;
using MiningGame.scripts.delve.crack;
using MiningGame.scripts.delve.cutout;
using MiningGame.scripts.helper;
using MiningGame.scripts.delve.ores;

namespace MiningGame.scripts.delve;

public partial class WallManager : Node2D
{
    [Signal]
    public delegate void OreCutoutEventHandler(Ore ore);
    
    [Export] public int WallQueueSize;
    [Export] public int InitialWallsRendered;
    [Export] public int CutoutEdgeBuffer;
    [Export] public Node2D FallingCutoutHolder;
    [Export] public Node2D WallHolder;

    public int TopWallNumber => topWallNumber;
    private int topWallNumber = 1;

    private readonly List<Wall> activeWalls = [];
    private readonly Queue<Wall> wallQueue = new();

    public async Task Restart()
    {
        Clear();
        await Start();
    }
    
    public void Clear()
    {
        for (int i = 0; i < activeWalls.Count;)
        {
            activeWalls[i].Destroy();
            activeWalls.RemoveAt(i);
        }

        while (wallQueue.TryDequeue(out var wall))
        {
            wall.Destroy();   
        }
        topWallNumber = 1;
    }
    
    public async Task Start()
    {
        for (var i = 0; i < WallQueueSize; i++)
        {
            wallQueue.Enqueue(CreateNewWall(i + 1));
        }

        for (var i = 0; i < InitialWallsRendered; i++)
        {
            await ActivateNextWall();
        }
    }

    private async Task ActivateNextWall()
    {
        Wall nextWall = wallQueue.Dequeue();
        await nextWall.Render();
        nextWall.CycleFormed += FirstCutoutInWall;
        activeWalls.Add(nextWall);
        wallQueue.Enqueue(CreateNewWall(wallQueue.Peek().WallNumber + 1));
    }

    public void RemoveFrontWallHandler() { RemoveFrontWall(); }
    private async Task RemoveFrontWall()
    {
        Wall frontWall = activeWalls[0];
        activeWalls.RemoveAt(0);
        
        frontWall.Destroy();
        await ActivateNextWall();
        topWallNumber++;
    }

    private Wall CreateNewWall(int wallCount)
    {
        Wall wall = Wall.Create(wallCount, FallingCutoutHolder);
        wall.OreCutout += AcceptOreCutoutSignal;
        WallHolder.AddChild(wall);
        WallHolder.MoveChild(wall, 0); // Ensure the wall is at the back.
        return wall;
    }

    public void ProcessCreateHole(Vector2 point)
    {
        Array<Dictionary> raycastResults = RaycastHelper.Instance.RaycastCircle(point, 1, 0xFFFFFFFF, 32);
        int deepestWall = topWallNumber;

        foreach (var raycastItem in raycastResults)
        {
            if (raycastItem["collider"].AsGodotObject() is Cutout cutout)
            {
                int cutoutWallCount = cutout.GetParentWallCount();
                deepestWall = Math.Max(deepestWall, cutoutWallCount + 1);
            }
        }
        int targetWall = deepestWall - topWallNumber;

        if (targetWall > 0)
        {
            Array<Dictionary> objectsOnLayerAbove = RaycastHelper.Instance.RaycastCircle(point, CutoutEdgeBuffer, activeWalls[targetWall - 1].CollisionLayer, 2);
            foreach (var objectOnLayerAbove in objectsOnLayerAbove)
            {
                if (objectOnLayerAbove["collider"].GetType() != typeof(Cutout)) return;
            }
        }
        
        activeWalls[targetWall].CreateHole(point);
    }
    
    public void AcceptOreCutoutSignal(Ore ore)
    {
        EmitSignalOreCutout(ore);
    }

    /// <summary>
    /// Called when the first cutout is created in a wall. This method actives the next wall to ensure constant loading.
    /// </summary>
    /// <param name="cutoutVertices">Not used, side effect of using the CycleFormed signal</param>
    /// <param name="cracks">Not used, side effect of using the CycleFormed signal</param>
    /// <param name="allCracks">Not used, side effect of using the CycleFormed signal</param>
    /// <param name="caller">The wall that has had its first cutout</param>
    private void FirstCutoutInWall(Vector2[] cutoutVertices, Crack[] cracks, Crack[] allCracks, Wall caller)
    {
        caller.CycleFormed -= FirstCutoutInWall;
        ActivateNextWall();
    }
}