using System.Threading.Tasks;
using Godot;
using MiningGame.scripts.delve.ores;
using MiningGame.scripts.helper;
using MiningGame.scripts.delve.UI;

namespace MiningGame.scripts.delve;

public partial class DelveManager : Node2D
{
    [Signal] public delegate void OreCutoutEventHandler(Ore ore);
    
    [Export] public WallManager WallManager;
    [Export] public Countdown Countdown;
    [Export] public GameOverDialogBox GameOverDialogBox;

    public async override void _Ready()
    {
        await Restart();
    }

    public void RestartHandler() { Restart(); }
    public async Task Restart()
    {
        await WallManager.Start();
        GameOverDialogBox.Hide();

        await WallManager.Restart();

        InputManager.Instance.NextWall += WallManager.RemoveFrontWallHandler;
        InputManager.Instance.CreateHole += WallManager.ProcessCreateHole;
        
        Countdown.Start();
    }
    
    public void CountdownCompleted()
    {
        InputManager.Instance.NextWall -= WallManager.RemoveFrontWallHandler;
        InputManager.Instance.CreateHole -= WallManager.ProcessCreateHole;
        GameOverDialogBox.Show(WallManager.TopWallNumber); 
    }

    public void AcceptOreCutout(Ore ore)
    {
        EmitSignalOreCutout(ore);
    }
}