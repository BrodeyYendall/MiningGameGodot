using GdUnit4;
using Godot;
using MiningGame.scripts.delve.ores;
using Moq;
using static GdUnit4.Assertions;

namespace MiningGame.tests;

[TestSuite]
public class OreTest
{
    // Ore is created with random sprite
    [TestCase]
    [RequireGodotRuntime]
    public void OreIsInitialized()
    {
        int scale = 5;
        var position = new Vector2(6, 7);
        uint collisionLayer = 1;

        var sprite = AutoFree(new Sprite2D());
        sprite.RegionRect = new Rect2(new Vector2(-1, -1), new Vector2(1, 1));
        var texture = ImageTexture.CreateFromImage(Image.CreateEmpty(4, 8, false, Image.Format.Rgba8));
        sprite.Texture = texture;
        
        var ore = AutoFree(new Ore());
        ore.Sprite = sprite;
        ore.Initialize(scale, position, collisionLayer);
        AssertThat(ore.CollisionLayer).IsEqual(collisionLayer);
        AssertThat(ore.CollisionMask).IsEqual(collisionLayer);
        AssertThat(ore.Position).IsEqual(position);
        AssertThat(ore.Scale).IsEqual(new Vector2(scale, scale));
        
        AssertThat(sprite.RegionRect.Position).IsNotEqual(new Vector2(-1, 1));
    }
    
    // OnAreaEntered that isnt a cutout
    // OnAreaEntered with cutout that doesnt cover the centre
    // OnAreaEntered with cutout that does cover the centre
    
    // Ore changes parent from ore holder to falling cutout
}