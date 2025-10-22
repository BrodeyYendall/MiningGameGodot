using System.Collections.Generic;
using System.Collections.Immutable;
using Godot;
using MiningGame.scripts.delve.ores.factory;

namespace MiningGame.scripts.delve.ores;

public partial class OreTable (
    int wallCountThreshold,
    int maxFails,
    int maxCount,
    List<(OreFactory<Ore> OreFactory, int Weight)> oreRatios) : Resource
{
    
    public int WallCountThreshold { get; } = wallCountThreshold;
    public int MaxFails { get; } = maxFails;
    public int MaxCount { get; } = maxCount;
    public List<(OreFactory<Ore> OreFactory, int Weight)> OreRatios { get; } = oreRatios;

    public static readonly ImmutableArray<OreTable> AllOreTables =
    [
        new OreTable(1, 100, 20, [(new CopperOreFactory(), 100)]),
        new OreTable(3, 100, 20, [
            (new CopperOreFactory(), 95),
            (new ZincOreFactory(), 5),
        ]),

        new OreTable(5, 100, 20, [
            (new CopperOreFactory(), 90),
            (new ZincOreFactory(), 10),
        ]),

        new OreTable(8, 100, 20, [
            (new CopperOreFactory(), 80),
            (new ZincOreFactory(), 20),
        ]),

        new OreTable(10, 100, 20, [
            (new CopperOreFactory(), 70),
            (new ZincOreFactory(), 30),
        ])
    ];
    
}