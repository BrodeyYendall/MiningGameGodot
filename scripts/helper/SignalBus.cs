using Godot;

namespace MiningGame.scripts.helper;

public partial class SignalBus : Node
{
    private static SignalBus _instance;
    public static SignalBus Instance => _instance;
    public override void _EnterTree()
    {
        if (_instance != null)
        {
            QueueFree();
        }

        _instance = this;
    }
    
    [Signal] public delegate void UpdateOreCountEventHandler(string oreType, int newCount);

    public void EmitUpdateOreCount(string oreType, int newCount) { EmitSignalUpdateOreCount(oreType, newCount); }
}