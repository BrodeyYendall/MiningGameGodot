using System.Linq;
using Godot;
using MiningGame.scripts.helper;

namespace MiningGame.scripts.delve.ores;

public abstract partial class OreFactory<T>: Node2D
    where T : Ore
{
    public bool CanGenerateAt(Vector2 location, float scale, uint collisionLayer)
    {
        Shape2D shape = GetOreRaycastShape(scale);
        return !RaycastHelper.Instance.RaycastShape(location, shape, collisionLayer).Any();
    }

    public virtual T CreateOre(Vector2 location, float scale, uint collisionLayer)
    {
        var ore = GetAttachedScene().Instantiate<T>();
        ore.Initialize((int) scale, location, collisionLayer);
        return ore;
    }

    protected virtual Shape2D GetOreRaycastShape(float scale)
    {
        var shape = new RectangleShape2D();

        float width = GetBaseWidth() * scale;
        shape.Size = new Vector2(width, width);
        return shape;
    }

    protected virtual float GetBaseWidth()
    {
        throw new System.NotImplementedException("Either implement GetOreRaycastShape or GetBaseRadius.");
    }

    protected virtual PackedScene GetAttachedScene()
    {
        throw new System.NotImplementedException("Either implement CreateOre or GetAttachedScene.");
    }
}