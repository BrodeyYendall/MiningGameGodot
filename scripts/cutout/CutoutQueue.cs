using System.Collections.Generic;
using Godot;
using MiningGame.scripts.crack;
using MiningGame.scripts.ores;

namespace MiningGame.scripts.cutout;

public partial class CutoutQueue: Node2D
{
    [Export] public Node2D cutoutHolder;
    [Export] public Node2D fallingCutoutHolder;
    [Export] public Wall parentWall;
    
    [Signal] public delegate void OreCutoutEventHandler();
    [Signal] public delegate void RenderCutoutEventHandler(Vector2[] cutoutVertices);
    

    private Image wallImage;
    private Dictionary<int, QueueEntry> queue = new();
    private Dictionary<Crack, Cutout> cutoutMap = new();
    private int idCount = 0;
    private bool shouldDestroy = false;
    private uint collisionLayer = 1;
    
    

    public void SetCollisionLayer(uint layer)
    {
        collisionLayer = layer;
        foreach (Cutout child in cutoutHolder.GetChildren())
        {
            child.SetCollisionLayer(layer);
            child.SetCollisionMask(layer);
        }
    }

    public void QueueCutout(Vector2[] cutoutVertices, Crack[] newCracks, Crack[] allCracks, Wall _)
    {
        var cutout = Cutout.Create(cutoutVertices, [..allCracks], collisionLayer, parentWall);
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
            cutout.DestroyCrack += CrackDestroy;
            cutout.DestroyHole += HoleDestroy;
            
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
            if (cutoutFromMap != null && !cutoutsToMerge.Contains(cutoutFromMap))
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
            EmitSignalOreCutout();
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
    
    private void CheckForDestroy(int minChildren)
    {
        if (fallingCutoutHolder.GetChildren().Count <= minChildren)
        {
            QueueFree();
        }
    }
    
    private void CrackDestroy(Crack crack)
    { 
        parentWall.DestroyCrack(crack.CrackPointReferences[0], crack.CrackPointReferences[1]);
    }

    private void HoleDestroy(Hole hole)
    {
        parentWall.DestroyCracksAndHole(hole.PointNumber);
    }
    
    public void OnBackgroundImageChanged(Image image)
    {
        wallImage = image;
    }

    private partial class QueueEntry (
        Cutout cutout,
        int newCrackCount,
        int completedCrackCount
        )
    {
        public Cutout Cutout { get; set; } = cutout;
        public int NewCrackCount { get; set; } = newCrackCount;
        public int CompletedCrackCount { get; set; } = completedCrackCount;
    }
}