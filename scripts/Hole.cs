using System.Linq;
using Godot;
using MiningGame.scripts.cutout;

namespace MiningGame.scripts;

public partial class Hole : Area2D
{
    private static readonly PackedScene _attachedScene = ResourceLoader.Load<PackedScene>("res://scenes/hole.tscn");

    
    [Signal]
    public delegate void DestroyHoleEventHandler(int pointId);

    private int pointNumber;
    public int PointNumber => pointNumber;
    
    private Vector2[] squareWrapper;

    public static Hole Create(int pointNumber, Vector2 position, uint collisionLayer)
    {
        Hole hole = _attachedScene.Instantiate<Hole>();
        hole.Initialize(pointNumber, position, collisionLayer);
        return hole;
    }
    
    public void Initialize(int pointNumber, Vector2 position, uint collisionLayer)
    {
        this.pointNumber = pointNumber;
        Position = position;
        CollisionLayer = collisionLayer;
        CollisionMask = collisionLayer;
    }
    
    public override void _Ready()
    {
        CircleShape2D shape = (CircleShape2D) GetNode<CollisionShape2D>("hitbox").Shape;
        shape.Radius = Constants.HoleSize;
    }

    public override void _Draw()
    {
        DrawCircle(new Vector2(0, 0), Constants.HoleSize, Colors.Black);
        DrawString(ThemeDB.FallbackFont, new Vector2(-2, 3), pointNumber.ToString(), 0, -1, 12);
    }
    
    private void OnAreaEntered(Area2D area)
    {
        if (area is Cutout cutout)
        {
            // We check if the hole is now inside a cutout. If it is then we move ownership of the hole to the cutout
            // which will destroy it when the cutout falls out. This is to improve performance and prevent cracks from 
            // forming in parts of the wall that have already been cutout. 
            if (!Geometry2D.ClipPolygons(GetSquareWrapper(), cutout.cutoutVertices).Any())
            {
                cutout.AddHole(this);
            }
        }
    }

    /// <summary>
    /// Used to determine if a hole is completely surrounded by a cutout. A square "hitbox" is used for
    /// optimisation and to be sure that it is surrounded. 
    /// </summary>
    /// <returns>The vectors representing a square around the hole</returns>
    private Vector2[] GetSquareWrapper()
    {
        if (squareWrapper == null)
        {
            Vector2 holeSizeVector = new Vector2(Constants.HoleSize, Constants.HoleSize);
            
            Vector2 negative = Position - holeSizeVector;
            Vector2 positive = Position + holeSizeVector;

            squareWrapper = new Vector2[4];
            squareWrapper[0] = new Vector2(negative.X, negative.Y);
            squareWrapper[1] = new Vector2(negative.X, positive.Y);
            squareWrapper[2] = new Vector2(positive.X, positive.Y);
            squareWrapper[3] = new Vector2(positive.X, negative.Y);
        }

        return squareWrapper;
    }

    public void Destroy()
    {
        QueueFree();
    }
}