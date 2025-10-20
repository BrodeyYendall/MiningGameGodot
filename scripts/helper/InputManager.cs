using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using Godot;

namespace MiningGame.scripts.helper;

public partial class InputManager : Node
{
    private static readonly string SaveLocation = "res://scenarios/most_recent.jsonl";
    private static readonly string LoadScenario = "res://scenarios/most_recent.jsonl";

    private static InputManager _instance;
    public static InputManager Instance => _instance;

    [Signal]
    public delegate void CreateHoleEventHandler(Vector2 point);

    [Signal]
    public delegate void NextWallEventHandler();

    private List<InputRecord> events = [];
    private bool saveEvents = true;
    private int eventIndex = 0;
    private ulong prevHoleCreatedAt = 0;
    private FileAccess saveFile;

    public override void _Ready()
    {
        if (LoadScenario == "")
        {
            SetProcess(false);

            ulong newSeed = GD.Randi();
            GD.Seed(newSeed);
            AddEvent(new InputRecord("seed", 0, new Dictionary<string, string>
            {
                {"seed", newSeed.ToString()}
            }));
        }
        else
        {
            saveEvents = false;
            SetProcessInput(false);
            FileAccess loadFile = FileAccess.Open(LoadScenario, FileAccess.ModeFlags.Read);
            
            string line = loadFile.GetLine();
            while (line != "")
            {
                events.Add(JsonSerializer.Deserialize<InputRecord>(line));
                line = loadFile.GetLine();
            }

            GD.Seed(ulong.Parse(events[0].AdditionalData["seed"]));
            eventIndex++;
        }
    }
    
    public override void _Input(InputEvent inputEvent)
    {
        ProcessInput(inputEvent);
    }

    private void ProcessInput(InputEvent inputEvent)
    {
        ulong currentTime = Time.GetTicksMsec();
        if (inputEvent is InputEventMouseButton inputMouseEvent && inputEvent.IsPressed())
        {
            if (currentTime - prevHoleCreatedAt >= (ulong) Constants.DelayBetweenHoles)
            {
                prevHoleCreatedAt = currentTime;
                EmitSignalCreateHole(inputMouseEvent.Position);
                AddEvent(new InputRecord("create_hole", currentTime, new Dictionary<string, string>()
                {
                    {"x", inputMouseEvent.Position.X.ToString()},
                    {"y", inputMouseEvent.Position.Y.ToString()},
                }));
            } 
        } else if (inputEvent is InputEventKey inputKeyEvent && inputEvent.IsPressed() && !inputEvent.IsEcho())
        {
            switch (inputKeyEvent.Keycode)
            {
                case Key.Space:
                    EmitSignalNextWall();
                    AddEvent(new InputRecord("next_wall", currentTime, new Dictionary<string, string>()));
                    break;
            }
        }
    }

    private void AddEvent(InputRecord inputRecord)
    {
        if (saveEvents)
        {
            if (saveFile == null)
            {
                saveFile = FileAccess.Open(SaveLocation, FileAccess.ModeFlags.Write);
            }

            saveFile.StoreLine(JsonSerializer.Serialize(inputRecord));
            saveFile.Flush();

        }
    }

    public override void _Process(double delta)
    {
        ulong currentTime = Time.GetTicksMsec();
        InputRecord currentEvent = events[eventIndex];
        
        if (currentTime >= currentEvent.Timestamp)
        {
            switch (currentEvent.Type)
            {
                case "create_hole":
                    var inputMouseEvent = new InputEventMouseButton();
                    float x = float.Parse(currentEvent.AdditionalData.GetValueOrDefault("x", ""));
                    float y = float.Parse(currentEvent.AdditionalData.GetValueOrDefault("y", ""));
                    
                    
                    inputMouseEvent.Position = new Vector2(x, y);
                    inputMouseEvent.Pressed = true;
                    
                    ProcessInput(inputMouseEvent);
                    break;
                case "next_wall":
                    var inputKeyEvent = new InputEventKey();
                    inputKeyEvent.Keycode = Key.Space;
                    inputKeyEvent.Pressed = true;
                    ProcessInput(inputKeyEvent);
                    break;
            }
            eventIndex++;
        }

        if (eventIndex == events.Count)
        {
            SetProcess(false);
        }
    }
    
    public override void _EnterTree()
    {
        if (_instance != null)
        {
            QueueFree();
        }

        _instance = this;
    }

    public class InputRecord(string type, ulong timestamp, Dictionary<string, string> additionalData)
    {
        public string Type => type;
        public ulong Timestamp => timestamp;
        public Dictionary<string, string> AdditionalData => additionalData;
    }
}