using Godot;
using System.Collections.Generic;
using MiningGame.scripts.delve;
using MiningGame.scripts.delve.crack;
using MiningGame.scripts.helper;

namespace MiningGame.scripts.unlockTree;

public partial class UnlockTree : Node2D
{
	[Export] private Background background;
	[Export] private Node2D crackHolder;

	public async override void _Ready()
	{
		background.Initialize();
		await background.WaitForRender();
	}

	public void HandleNodePurchase(UnlockNode node)
	{
		GD.Print($"Purchased {node.Title}, {node.Description}");
	}

	public void HandleNodeUnlock(UnlockNode node)
	{
		foreach (var dependency in node.FulfilledDependencies)
		{
			Crack crack = Crack.Create(dependency.Position, node.Position,
				CollisionLayerHelper.UnlockTreeCollisionLayer, [], CrackConfig.UnlockTreeCrackConfig);
			crack.CrackComplete += (_) => HandleCrackCompleted(node);
			crackHolder.AddChild(crack);
		}
	}

	private void HandleCrackCompleted(UnlockNode destination)
	{
		destination.DisplayNode();
	}
}