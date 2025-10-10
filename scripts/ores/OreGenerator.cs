using System;
using System.Linq;
using Godot;

namespace MiningGame.scripts.ores;

public partial class OreGenerator : Node2D
{
    private static readonly int OreBorderBuffer = 50;
    private static readonly int OreGenFailCount = 10;
    private static readonly int OreGenSuccessCount = 10;

    private PhysicsDirectSpaceState2D space;
    
    public override void _Ready()
    {
	    space = GetWorld2D().DirectSpaceState;
    }

    
    private void GenerateOres(int level)
    {
	    OreTable oreTable = GetOreTableForCurrentLevel(level);
	    uint collisionLayer = (uint)(1 << (level % 8)); // TODO Move collision layer management  to an autoload/singleton

	    int failCount = 0;
	    int successCount = 0;

	    while (failCount <= OreGenFailCount && successCount < OreGenSuccessCount)
	    {
		    var randomLocation = new Vector2(
			    GD.RandRange(OreBorderBuffer, Constants.ScreenWidth - OreBorderBuffer),
			    GD.RandRange(OreBorderBuffer, Constants.ScreenHeight - OreBorderBuffer));
		    
		    var scale = 1f; // TODO Randomize scaling?

		    OreFactory<Ore> targetOreFactory = SelectOreFromTable(oreTable);
		    targetOreFactory.Space = space;
		    
		    if (targetOreFactory.CanGenerateAt(randomLocation, scale))
		    {
			    successCount++;
			    Ore ore = targetOreFactory.CreateOre(randomLocation, scale, collisionLayer);
			    AddChild(ore);
		    }
		    else
		    {
			    failCount++;
		    }

	    }
    }

    private OreTable GetOreTableForCurrentLevel(int wallCount)
    {
	    foreach (OreTable oreTable in OreTable.AllOreTables)
	    {
		    if (wallCount <= oreTable.WallCountThreshold)
		    {
			    return oreTable;
		    }
	    }
	    return OreTable.AllOreTables.Last();
    }

    private OreFactory<Ore> SelectOreFromTable(OreTable oreTable)
    {
	    int random = GD.RandRange(0, 100);
	    foreach (var ratio in oreTable.OreRatios)
	    {
		    if (random <= ratio.Weight)
		    {
			    return ratio.OreFactory;
		    }
		    random -= ratio.Weight;
	    }

	    throw new InvalidOperationException("Ore ratios do not sum to 100 or no valid ore could be selected.");
    }
}