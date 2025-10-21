using System.Collections.Generic;
using Godot;
using MiningGame.scripts.autoload;
using MiningGame.scripts.crack;
using MiningGame.scripts.ores;

namespace MiningGame.scripts.cutout;

public partial class CutoutManager: Node2D, ICollisionObjectCreator
{
    [Export] public Node2D cutoutHolder;
    [Export] public Node2D fallingCutoutHolder;
    [Export] public Wall parentWall;
    
    [Signal] public delegate void OreCutoutEventHandler(Ore ore);
    [Signal] public delegate void RenderCutoutEventHandler(Vector2[] cutoutVertices);
    

    private Image wallImage;
    private Dictionary<int, QueueEntry> queue = new();
    private Dictionary<Crack, Cutout> cutoutMap = new();
    private int idCount = 0;
    private bool shouldDestroy = false;
    private uint collisionLayer = 1;
    
    public void CreateCutout(Vector2[] cutoutVertices, Crack[] newCracks, Crack[] allCracks, Wall _)
    {
        var cutout = Cutout.Create(cutoutVertices, [..allCracks], collisionLayer, this);
        cutoutHolder.AddChild(cutout);
        cutout.Visible = false;
          
        queue.Add(idCount, new QueueEntry(cutout, newCracks.Length, 0));

        foreach (Crack crack in newCracks)
        {
            crack.AddParent(idCount);

            if (!crack.IsConnected(Crack.SignalName.CrackComplete, Callable.From<int>(CrackCompleted)))
            {
                crack.CrackComplete += CrackCompleted;
            }
        }

        idCount++;
    }

    void CrackCompleted(int cutoutId)
    {
        QueueEntry queueEntry = queue.GetValueOrDefault(cutoutId, null);
        if (queueEntry == null) return;
        queueEntry.CompletedCrackCount += 1;

        if (queueEntry.CompletedCrackCount == queueEntry.NewCrackCount)
        {
            Cutout cutout = queueEntry.Cutout;
            FallingCutout fallingCutout = FallingCutout.Create(cutout.cutoutVertices, wallImage);
            cutout.AddFallingCutoutReference(fallingCutout);
            fallingCutout.CutoutOffscreen += FallingCutoutOffscreen;
            fallingCutoutHolder.AddChild(fallingCutout);
            
            EmitSignalRenderCutout(cutout.cutoutVertices);
            CheckForCutoutMerge(cutout);

            queue[cutoutId] = null;
        }
    }

    private void CheckForCutoutMerge(Cutout cutout)
    {
        HashSet<Cutout> cutoutsToMerge = new();
        foreach (Crack crack in cutout.cracks)
        {
            Cutout cutoutFromMap = cutoutMap.GetValueOrDefault(crack, null);
            if (cutoutFromMap != null)
            {
                cutoutsToMerge.Add(cutoutFromMap);
            }
        }

        foreach (Cutout existingCutout in cutoutsToMerge)
        {
            existingCutout.MergeCutout(cutout);
            cutout = existingCutout;
        }

        if (cutoutsToMerge.Count == 0)
        {
            cutout.Visible = true;
        }

        foreach (Crack crack in cutout.cracks)
        {
            cutoutMap[crack] = cutout;
        }
    }

    private void FallingCutoutOffscreen(Ore[] ores)
    {
        foreach (Ore ore in ores)
        {
            EmitSignalOreCutout(ore);
        }

        if (shouldDestroy)
        {
            CheckForDestroy(1);
        }
    }

    public void Destroy()
    {
        shouldDestroy = true;
        CheckForDestroy(0);
    }

    public void DestroyCracksAndHole(int holeNumber)
    {
        parentWall.DestroyCracksAndHole(holeNumber);
    }

    public void DestroyCrack(Crack crack)
    {
        parentWall.DestroyCrack(crack);
        cutoutMap.Remove(crack);
    }
    
    private void CheckForDestroy(int minChildren)
    {
        if (fallingCutoutHolder.GetChildren().Count <= minChildren)
        {
            QueueFree();
        }
    }
    
    /// <summary>
    /// Updates the background image to use when generating falling cutouts
    /// Through <see cref="Background.ImageChangeEventHandler"/> at <see cref="Background.WaitForRender"/> 
    /// </summary>
    /// <param name="image">The new background image</param>
    private void OnBackgroundImageChanged(Image image)
    {
        wallImage = image;
    }
    
    public void SetCollisionLayer(uint layer)
    {
        collisionLayer = layer;
    }


    private class QueueEntry (
        Cutout cutout,
        int newCrackCount,
        int completedCrackCount
        )
    {
        public Cutout Cutout { get; } = cutout;
        public int NewCrackCount { get; } = newCrackCount;
        public int CompletedCrackCount { get; set; } = completedCrackCount;
    }
}