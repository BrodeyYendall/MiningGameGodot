using Godot;

namespace MiningGame.scripts.delve.cutout;

public partial class FallingCutoutShadow : Node2D
{

    private Vector2[] shadowVertices;
    
    public void PrepareShadow(Vector2[] parentVertices, Vector2 minVector)
    {
        shadowVertices = RemoveOffset(parentVertices, minVector);
    }

    private Vector2[] RemoveOffset(Vector2[] vertices, Vector2 offset)
    {
        Vector2[] verticesCopy = new  Vector2[vertices.Length];
        vertices.CopyTo(verticesCopy, 0);

        for (int i = 0; i < verticesCopy.Length; i++)
        {
            verticesCopy[i] = vertices[i] - offset;
        }
        
        return verticesCopy;
    }

    public override void _Draw()
    {
        DrawColoredPolygon(shadowVertices, Colors.Black);
    }
}