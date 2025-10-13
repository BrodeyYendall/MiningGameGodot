using System.Collections.Generic;
using Godot;

namespace MiningGame.scripts.autoload;

public partial class CollisionLayerHelper : Node
{
    public static void SetAndPropagateCollisionLayer(Node caller, uint collisionLayer)
    {
        switch (caller)
        {
            case ICollisionObjectCreator objectCreator:
                objectCreator.SetCollisionLayer(collisionLayer);
                break;
            case CollisionObject2D collisionObject2D:
                collisionObject2D.SetCollisionLayer(collisionLayer);
                collisionObject2D.SetCollisionMask(collisionLayer);
                break;
        }

        foreach(var child in caller.GetChildren())
        {
            SetAndPropagateCollisionLayer(child, collisionLayer);
        }
    }

    public static void GetAndSetWallCollisionLayer(Wall wall)
    {
        SetAndPropagateCollisionLayer(wall, (uint)(1 << (wall.WallCount % 8)));
    }
}