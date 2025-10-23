using System.Collections.Generic;
using Godot;
using Godot.Collections;

namespace MiningGame.scripts.unlockTree;

public partial class UnlockNode : Control
{
	[Signal] public delegate void NodePurchasedEventHandler(UnlockNode unlockNode);
	[Signal] public delegate void NodeUnlockedEventHandler(UnlockNode node);
	
	
	[Export] public int MaxCount;
	[Export] public string Title;
	[Export] public string Description;
	[Export] public Array<UnlockNode> Dependencies;

	[Export] public BaseButton Button;
	[Export] public UnlockNodeTooltip Tooltip;
	

	public int Count => count;
	private int count;

	public HashSet<UnlockNode> FulfilledDependencies => fulfilledDependencies;
	private HashSet<UnlockNode> fulfilledDependencies = new();
	private HashSet<UnlockNode> pendingDependencies = new();

	public override void _Ready()
	{
		Tooltip.Initialize(Title, Description, MaxCount);

		Visible = CheckDependencies();
	}

	private bool CheckDependencies()
	{
		foreach(UnlockNode dependency in Dependencies)
		{
			if (dependency.Count == 0)
			{
				pendingDependencies.Add(dependency);
				dependency.NodePurchased += DependencyFulfilled;
			}
			else
			{
				fulfilledDependencies.Add(dependency);
			}
		}

		return pendingDependencies.Count == 0;
	}

	public void DependencyFulfilled(UnlockNode dependency)
	{
		dependency.NodePurchased -= DependencyFulfilled;
		pendingDependencies.Remove(dependency);
		fulfilledDependencies.Add(dependency);

		if (pendingDependencies.Count == 0)
		{
			EmitSignalNodeUnlocked(this);
		}
	}

	public void DisplayNode()
	{
		Visible = true;
	}

	public void ProcessButtonPressed()
	{
		count++;
		if (count == 1)
		{
			EmitSignalNodePurchased(this);
		}
		UpdateCount();
	}

	private void UpdateCount()
	{
		Tooltip.IncrementCount();
		if (count == MaxCount)
		{
			Button.Disabled = true;
			Modulate = Colors.DimGray;
		}
	}

	public void HandleMouseEntered()
	{
		Tooltip.Enable();
	}

	public void HandleMouseExited()
	{
		Tooltip.Disable();
	}

	public Vector2 GetButtonSize()
	{
		return Button.Size;
	}
}