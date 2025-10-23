using System.Collections.Generic;
using Godot;

namespace MiningGame.scripts;

public enum OreTypes
{
    Gold = 0, 
    Zinc = 1
}

public partial class OreType(): Node
{
    private static readonly Texture2D GoldIcon = ResourceLoader.Load<Texture2D>("res://resources/ores/goldIcon.tres");
    
    private static readonly Dictionary<OreTypes, Texture2D> TextureMap = new()
    {
        { OreTypes.Gold, GoldIcon}
    };
    
    public static Texture2D GetTexture(OreTypes oreTypes)
    {
        return TextureMap[oreTypes];
    }
}