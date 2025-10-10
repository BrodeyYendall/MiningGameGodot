using System;
using System.Collections.Generic;
using System.Linq;
using Godot;
using MiningGame.scripts.ores;

namespace MiningGame.scripts.cutout;

public partial class FallingCutout : Sprite2D
{
    private static readonly PackedScene _attachedScene = ResourceLoader.Load<PackedScene>("res://scenes/cutout/falling_cutout.tscn");

    [Signal]
    public delegate void CutoutOffscreenEventHandler(Ore[] ores);

    private static readonly Vector2 DropShadowOffset = new Vector2(8, 8);
    private static readonly int FallSpeed = 200;
    private static readonly float RotateSpeed = 0.5f;
    

    private Vector2[] cutoutVertices;
    private Image backgroundImage;
    private float cutoutArea;
    private float adjustedCutoutSize;

    private Vector2I initPosition;
    private Vector2I size;
    private int rotationDirection;
    private List<Ore> ores = [];

    public static FallingCutout Create(Vector2[] cutoutVertices, Image backgroundImage)
    {
        FallingCutout fallingCutout = _attachedScene.Instantiate<FallingCutout>();
        fallingCutout.Initialize(cutoutVertices, backgroundImage);
        return fallingCutout;
    }

    public void Initialize(Vector2[] cutoutVertices, Image backgroundImage)
    {
        this.cutoutVertices = cutoutVertices;
        this.backgroundImage = backgroundImage;
        
        CalculateCutoutBoundingBox();
    }

    public override void _Ready()
    {
        if (cutoutVertices == null)
        {
            throw new InvalidOperationException("cutoutVertices is null, was Initialize() called?");
        }

        rotationDirection = GD.RandRange(0, 1) == 0 ? -1 : 1;
        cutoutArea = CalculateArea();
        adjustedCutoutSize = cutoutArea / 20000;
        adjustedCutoutSize = Mathf.Min(2f, Mathf.Max(0.75f, adjustedCutoutSize));

        Image image = Image.CreateEmpty(size.X, size.Y, false, Image.Format.Rgba8);
        for (int y = 0; y < size.Y; y++)
        {
            for (int x = 0; x < size.X; x++)
            {
                Vector2I worldPosition = new Vector2I(x, y) + new Vector2I(initPosition.X, initPosition.Y);
                if (Geometry2D.IsPointInPolygon(worldPosition, cutoutVertices))
                {
                    Color color = backgroundImage.GetPixelv(worldPosition);
                    image.SetPixel(x, y, color);
                }
                else
                {
                    image.SetPixel(x, y, new Color(0, 0, 0, 0)); // Set pixels outside the polygon as transparent.
                }
            }
        }

        Texture = ImageTexture.CreateFromImage(image);
        
        Vector2I halfSize = size / 2;
        Position = initPosition + halfSize;

        FallingCutoutShadow fallingCutoutShadow = GetNode<FallingCutoutShadow>("drop_shadow");
        fallingCutoutShadow.PrepareShadow(cutoutVertices, initPosition);
        fallingCutoutShadow.Position = -halfSize + DropShadowOffset;
    }

    public override void _Process(double delta)
    {
        Position = new Vector2(Position.X, Position.Y + (float)(FallSpeed * delta));
        Rotation += (float) (RotateSpeed * delta * rotationDirection) / adjustedCutoutSize;

        if (Position.Y > Constants.ScreenHeight + Mathf.Max(size.X, size.Y))
        {
            QueueFree();
            EmitSignalCutoutOffscreen(ores.ToArray());
        }
    }

    public void CalculateCutoutBoundingBox()
    {
        int minX = (int) cutoutVertices[0].X;
        int maxX =  (int) cutoutVertices[0].X;
        int minY = (int) cutoutVertices[0].Y;
        int maxY =  (int) cutoutVertices[0].Y;

        foreach (Vector2 vector in cutoutVertices)
        {
            if (vector.X < minX)
            {
                minX = (int) vector.X;
            }
            else
            {
                maxX = Mathf.Max((int) vector.X, maxX);
            }

            if (vector.Y < minY)
            {
                minY = (int) vector.Y;
            }
            else
            {
                maxY = Mathf.Max((int) vector.Y, maxY);
            }
        }
        
        initPosition = new Vector2I(minX, minY);
        size = new Vector2I(maxX - minX, maxY - minY);
    }

    private float CalculateArea()
    {
        float area = 0f;

        for (int i = 0; i < cutoutVertices.Length; i++)
        {
            int j = (i + 1) % cutoutVertices.Length;
            area += cutoutVertices[i].X * cutoutVertices[j].Y;
            area -= cutoutVertices[j].X * cutoutVertices[i].Y;
        }

        area = Mathf.Abs(area) / 2f;
        return area;
    }

    public void AddOre(Ore ore)
    {
        ores.Add(ore);
        ore.ChangeParent(this);
        ore.Position -= initPosition + (size / 2);
        ore.QueueRedraw();
    }

    public void SetBackgroundImage(Image image)
    {
        backgroundImage = image;
    }

}