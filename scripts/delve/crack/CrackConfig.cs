using Godot;

namespace MiningGame.scripts.delve.crack;

public partial class CrackConfig(
    int minWidth,
    int maxWidth,
    int crackVariance,
    int widthVariance,
    int maxVariance,
    float animationDelay,
    int segmentSize) : Node2D
{
    public static readonly CrackConfig DefaultCrackConfig = new(3, 8, 2, 1, 4, 0.04f, 10); 
    public static readonly CrackConfig UnlockTreeCrackConfig = new(4, 8, 2, 1, 4, 0.03f, 10); 
    
    public int MinWidth { get; } = minWidth;
    public int MaxWidth { get; } = maxWidth;
    public int CrackVariance { get; } = crackVariance;
    public int WidthVariance { get; } = widthVariance;
    public int MaxVariance { get; } = maxVariance;
    public float AnimationDelay { get; } = animationDelay;
    public int SegmentSize { get; } = segmentSize;
}