using Godot;

namespace MiningGame.scripts.unlockTree;

public partial class UnlockNodeTooltip : Panel
{
	[Export] public Label Title;
	[Export] public Label Description;

	public override void _Ready()
	{
		Disable();
	}

	public void Initialize(string title, string description)
	{
		Title.Text = title;
		Description.Text = description;
	}

	public override void _Input(InputEvent @event)
	{
		if (Visible && @event is InputEventMouseMotion)
		{
			GlobalPosition = GetGlobalMousePosition();
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
}