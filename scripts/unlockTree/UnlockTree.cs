using Godot;
using Godot.Collections;
using System.Collections.Generic;

namespace MiningGame.scripts.unlockTree;

public partial class UnlockTree : Node2D
{
	private List<(Vector2, Vector2)> linesToDraw = [];
	
	public void HandleNodePurchase(UnlockNode node)
	{
		GD.Print($"Purchased {node.Title}, {node.Description}");
	}

	public void HandleNodeUnlock(UnlockNode node)
	{
		foreach (var dependency in node.FulfilledDependencies)
		{
			linesToDraw.Add((node.Position + new Vector2(32, 32), dependency.Position + new Vector2(32, 32)));
		}
		QueueRedraw();
	}

	public override void _Draw()
	{
		foreach (var line in linesToDraw)
		{
			DrawLine(line.Item1, line.Item2, Colors.White, 8);
		}
	}
}