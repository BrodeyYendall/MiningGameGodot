using System.Threading.Tasks;
using Godot;
using MiningGame.scripts.helper;
using MiningGame.scripts.UI;

namespace MiningGame.scripts;

public partial class DelveManager : Node2D
{
    [Export] public WallManager WallManager;
    [Export] public Ui Ui;
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
        Ui.Restart();
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
        GameOverDialogBox.Show(Ui.GetGoldScore(), Ui.GetZincScore(), WallManager.TopWallNumber); 
    }
}