using System.Collections.Generic;
using Godot;

namespace MiningGame.scripts.autoload;

public partial class MetadataHandler : Node
{
    private static MetadataHandler _instance;
    public static MetadataHandler Instance => _instance;
    
    private readonly Dictionary<Node, Dictionary<string, string>> metadata = new();

    public override void _EnterTree()
    {
        if (_instance != null)
        {
            QueueFree();
        }

        _instance = this;
    }

    public void SetMetadataValue(Node caller, string key, string value)
    {
       var objectMetadata = metadata.GetValueOrDefault(caller, new Dictionary<string, string>());
        objectMetadata.Add(key, value);
        metadata.Add(caller, objectMetadata);
    }
    
    public void SetAndPropagateMetadataValue(Node caller, string key, string value)
    {
        SetMetadataValue(caller, key, value);
        foreach (var child in caller.GetChildren())
        {
            SetAndPropagateMetadataValue(child, key, value);
        }
    }

    public Dictionary<string, string> GetMetadata(Node caller)
    {
        return metadata.GetValueOrDefault(caller, new Dictionary<string, string>());
    }

    public string GetMetadataValue(Node caller, string key)
    {
        return GetMetadata(caller).GetValueOrDefault(key, null);
    }
}