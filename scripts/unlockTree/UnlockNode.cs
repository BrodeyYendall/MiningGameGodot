using System.Collections.Generic;
using Godot;
using Godot.Collections;

namespace MiningGame.scripts.unlockTree;

public partial class UnlockNode : TextureButton
{
	[Signal] public delegate void NodePurchasedEventHandler(UnlockNode unlockNode);
	[Signal] public delegate void NodeUnlockedEventHandler(UnlockNode node);
	
	
	[Export] public int MaxCount;
	[Export] public string Title;
	[Export] public string Description;

	[Export] public Label CountLabel;
	[Export] public UnlockNodeTooltip Tooltip;
	[Export] public Array<UnlockNode> Dependencies;

	public int Count => count;
	private int count;

	public HashSet<UnlockNode> FulfilledDependencies => fulfilledDependencies;
	private HashSet<UnlockNode> fulfilledDependencies = new();
	private HashSet<UnlockNode> pendingDependencies = new();

	public override void _Ready()
	{
		UpdateCount();
		Tooltip.Initialize(Title, Description);

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
			Visible = true;
			EmitSignalNodeUnlocked(this);
		}
		QueueRedraw();
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
		CountLabel.Text = $"{count}/{MaxCount}";
		if (count == MaxCount)
		{
			Disabled = true;
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
}