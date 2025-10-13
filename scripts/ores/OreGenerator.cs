using System;
using System.Linq;
using Godot;

namespace MiningGame.scripts.ores;

public partial class OreGenerator : Node2D, ICollisionObjectCreator
{
    private static readonly int OreBorderBuffer = 50;
    private static readonly int OreGenFailCount = 10;
    private static readonly int OreGenSuccessCount = 10;

    private uint collisionLayer;
    
    private void GenerateOres(int level)
    {
	    OreTable oreTable = GetOreTableForCurrentLevel(level);

	    int failCount = 0;
	    int successCount = 0;

	    while (failCount <= OreGenFailCount && successCount < OreGenSuccessCount)
	    {
		    var randomLocation = new Vector2(
			    GD.RandRange(OreBorderBuffer, Constants.ScreenWidth - OreBorderBuffer),
			    GD.RandRange(OreBorderBuffer, Constants.ScreenHeight - OreBorderBuffer));

		    OreFactory<Ore> targetOreFactory = SelectOreFromTable(oreTable);
		    
		    if (targetOreFactory.CanGenerateAt(randomLocation, 1f, collisionLayer))
		    {
			    successCount++;
			    Ore ore = targetOreFactory.CreateOre(randomLocation, 1f, collisionLayer);
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

    public void SetCollisionLayer(uint collisionLayer)
    {
	    this.collisionLayer = collisionLayer;
    }
}