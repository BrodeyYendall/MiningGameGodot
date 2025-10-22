using System.Collections.Generic;
using Godot;
using MiningGame.scripts.delve.ores;

namespace MiningGame.scripts;

public partial class Game : Node2D
{
	private readonly Dictionary<string, int> oreCounts = new();
	
	public void HandleOreCutout(Ore ore)
	{
		int count = oreCounts.GetValueOrDefault(ore.Type, 0) + 1;
		oreCounts[ore.Type] = count;
		helper.SignalBus.Instance.EmitUpdateOreCount(ore.Type, count);
	}
}