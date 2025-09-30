using System.Linq;
using Godot;

namespace MiningGame.scripts.ores;

public abstract partial class OreFactory<T>: Node2D
    where T : Ore
{
    protected PhysicsDirectSpaceState2D space;
    public PhysicsDirectSpaceState2D Space { 
        get => space;
        set => space = value;
    }
    
    public bool CanGenerateAt(Vector2 location, float scale)
    {
        var query = new PhysicsShapeQueryParameters2D();
        query.Shape = GetOreRaycastShape(scale);
        query.CollideWithAreas = true;
        query.CollisionMask = 0xFFFFFFFF;

        var transform = query.Transform;
        transform.Origin = location;
        query.Transform = transform;
        
        return !space.IntersectShape(query, 1).Any();
    }

    public virtual T CreateOre(Vector2 location, float scale, uint collisionLayer)
    {
        var ore = GetAttachedScene().Instantiate<T>();
        ore.Initialize((int) (GetBaseRadius() * scale), location, collisionLayer);
        return ore;
    }

    protected virtual Shape2D GetOreRaycastShape(float scale = 1)
    {
        var shape = new CircleShape2D();
        shape.Radius = GetBaseRadius() * scale;
        return shape;
    }

    protected virtual float GetBaseRadius()
    {
        throw new System.NotImplementedException("Either implement GetOreRaycastShape or GetBaseRadius.");
    }

    protected virtual PackedScene GetAttachedScene()
    {
        throw new System.NotImplementedException("Either implement CreateOre or GetAttachedScene.");
    }
}