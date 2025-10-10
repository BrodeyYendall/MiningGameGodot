using System.Collections.Generic;
using Godot;
using MiningGame.scripts.crack;
using MiningGame.scripts.ores;

namespace MiningGame.scripts.cutout;

public partial class CutoutQueue: Node2D
{
    [Export]
    public Node2D cutoutHolder;

    [Export]
    public Node2D fallingCutoutHolder;


    [Signal]
    public delegate void OreCutoutEventHandler();
    
    [Signal]
    public delegate void RenderCutoutEventHandler(Vector2[] cutoutVertices);
    

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

    public void QueueCutout(Vector2[] cutoutVertices, Crack[] newCracks, Crack[] allCracks) // TODO Change the signature after Wall is migrated.
    {
        var cutout = Cutout.Create(cutoutVertices, [..allCracks], collisionLayer);
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

    public void destroy() // TODO Rename to Destroy after all code is migrated
    {
        shouldDestroy = true;
        CheckForDestroy(0);
    }
    
    private void CheckForDestroy(int minChildren)
    {
        if (fallingCutoutHolder.GetChildren().Count <= minChildren)
        {
            GetParent().QueueFree();
            
        }
    }
    
    private void CrackDestroy(Crack crack)
    {
        Node2D wall = GetParent<Node2D>();
        wall.Call("destroy_crack", crack.CrackPointReferences[0], crack.CrackPointReferences[1]);
    }

    private void HoleDestroy(Node2D hole)
    {
        Node2D wall = GetParent<Node2D>();
        wall.Call("_destroy_cracks_and_hole", hole.Get("point_number"));
    }

    public override void _Ready()
    {
        int wallCount = GetParent().Get("wall_count").AsInt32(); // TODO Find a better way to do this
        collisionLayer = (uint)(1 << (wallCount % 8)); // TODO Move collision layer management  to an autoload/singleton
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