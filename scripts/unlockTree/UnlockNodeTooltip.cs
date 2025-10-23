using System.Diagnostics.Tracing;
using Godot;

namespace MiningGame.scripts.unlockTree;

public partial class UnlockNodeTooltip : PanelContainer
{
	[Export] public Label Title;
	[Export] public Label Description;

	[Export] public Control Contents;

	private string title;
	private int maxCount;
	private int currentCount = 0;

	public override void _Ready()
	{
		Disable();
	}

	public void Initialize(string title, string description, int maxCount, Godot.Collections.Dictionary<OreTypes, int> costs)
	{
		Description.Text = description;
		this.title = title;
		this.maxCount = maxCount;
		UpdateTitleLabel();

		foreach (var entry in costs)
		{
			AddCost(entry.Key, entry.Value);
		}
	}

	public override void _Input(InputEvent @event)
	{
		if (Visible && @event is InputEventMouseMotion)
		{
			Rect2 viewportRect = GetViewportRect();
			Vector2 newPosition = GetGlobalMousePosition();
			
			if (newPosition.X + Size.X > viewportRect.End.X)
			{
				newPosition.X -= Size.X;
			}
			if (newPosition.Y + Size.Y > viewportRect.End.Y)
			{
				newPosition.Y -= Size.Y;
			}
			
			GlobalPosition = newPosition;
		}
	}

	public void Enable()
	{
		SetProcessInput(true);
		Visible = true;
	}

	public void Disable()
	{
		SetProcessInput(false);
		Visible = false;
	}

	public void IncrementCount()
	{
		currentCount++;
		UpdateTitleLabel();
	}

	public void AddCost(OreTypes costType, int cost)
	{
		Contents.AddChild(CostRow.Create(costType, cost));
	}

	private void UpdateTitleLabel()
	{
		Title.Text = title + $" ({currentCount}/{maxCount})";
	}
}