using Godot;
using Godot.Collections;

namespace MiningGame.scripts.helper;

public partial class RaycastHelper: Node2D
{
    private static RaycastHelper _instance;
    public static RaycastHelper Instance => _instance;
    
    private PhysicsDirectSpaceState2D space;
    public PhysicsDirectSpaceState2D  Space => space;

    public override void _EnterTree()
    {
        if (_instance != null)
        {
            QueueFree();
        }

        _instance = this;
    }
    
    public override void _Ready()
    {
        space = GetWorld2D().DirectSpaceState;
    }

    public Dictionary RaycastLine(Vector2 start, Vector2 end, uint collisionLayer)
    {
        var query = new PhysicsRayQueryParameters2D();
        query.SetFrom(start);
        query.SetTo(end);
        query.CollideWithAreas = true;
        query.CollisionMask = collisionLayer;

        return space.IntersectRay(query);
    }

    public Array<Dictionary> RaycastShape(Vector2 point, Shape2D shape, uint collisionLayer, int maxResults = 1)
    {
        var query = new PhysicsShapeQueryParameters2D();
        query.Shape = shape;
        query.CollideWithAreas = true;
        query.CollisionMask = collisionLayer;

        var transform = query.Transform;
        transform.Origin = point;
        query.Transform = transform;
        
        return space.IntersectShape(query, maxResults);
    }

    public Array<Dictionary> RaycastCircle(Vector2 point, int radius, uint collisionLayer, int maxResults = 1)
    {
        CircleShape2D circle = new CircleShape2D();
        circle.Radius = radius;
        
        return RaycastShape(point, circle, collisionLayer, maxResults);
    }
}