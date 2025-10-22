using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;
using Godot.Collections;
using MiningGame.scripts.crack;
using MiningGame.scripts.cutout;
using MiningGame.scripts.helper;
using MiningGame.scripts.UI;

namespace MiningGame.scripts;

public partial class WallManager : Node2D
{
    [Export] public int WallQueueSize = 4;
    [Export] public int InitialWallsRendered = 2;
    [Export] public int CutoutEdgeBuffer = 15;
    [Export] public Node2D FallingCutoutHolder;
    [Export] public Node2D WallContainer;
    [Export] public Ui Ui;
    [Export] public Countdown Countdown;
    [Export] public GameOverDialogBox GameOverDialogBox;
    
    private int topWallNumber = 1;

    private readonly List<Wall> activeWalls = [];
    private readonly Queue<Wall> wallQueue = new();

    public async override void _Ready()
    {
        await Restart();
    }

    public void RestartHandler() { Restart(); }
    public async Task Restart()
    {
        Ui.Restart();
        GameOverDialogBox.Hide();
        topWallNumber = 1;

        for (int i = 0; i < activeWalls.Count;)
        {
            activeWalls[i].Destroy();
            activeWalls.RemoveAt(i);
        }

        while (wallQueue.TryDequeue(out var wall))
        {
            wall.Destroy();   
        }
        
        for (var i = 0; i < WallQueueSize; i++)
        {
            wallQueue.Enqueue(CreateNewWall(i + 1));
        }

        for (var i = 0; i < InitialWallsRendered; i++)
        {
            await ActivateNextWall();
        }

        InputManager.Instance.NextWall += RemoveFrontWallHandler;
        InputManager.Instance.CreateHole += ProcessCreateHole;
        
        Countdown.Start();
    }

    private async Task ActivateNextWall()
    {
        Wall nextWall = wallQueue.Dequeue();
        await nextWall.Render();
        nextWall.CycleFormed += FirstCutoutInWall;
        activeWalls.Add(nextWall);
        wallQueue.Enqueue(CreateNewWall(wallQueue.Peek().WallNumber + 1));
    }

    private void RemoveFrontWallHandler() { RemoveFrontWall(); }
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
        wall.OreCutout += Ui.ProcessOreCutout;
        WallContainer.AddChild(wall);
        WallContainer.MoveChild(wall, 0); // Ensure the wall is at the back.
        return wall;
    }

    private void ProcessCreateHole(Vector2 point)
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

    public void CountdownCompleted()
    {
        InputManager.Instance.NextWall -= RemoveFrontWallHandler;
        InputManager.Instance.CreateHole -= ProcessCreateHole;
        GameOverDialogBox.Show(Ui.GetGoldScore(), Ui.GetZincScore(), topWallNumber); 
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