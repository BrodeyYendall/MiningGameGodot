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
    public int MinWidth { get; } = minWidth;
    public int MaxWidth { get; } = maxWidth;
    public int CrackVariance { get; } = crackVariance;
    public int WidthVariance { get; } = widthVariance;
    public int MaxVariance { get; } = maxVariance;
    public float AnimationDelay { get; } = animationDelay;
    public int SegmentSize { get; } = segmentSize;
}