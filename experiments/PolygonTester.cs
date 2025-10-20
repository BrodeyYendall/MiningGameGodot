using System.Collections.Generic;
using Godot;

namespace MiningGame.experiments;

public partial class PolygonTester : Node2D
{
    private static readonly List<List<(double, double)>> VerticesList = [
        [(153.33334, 122),(138.66101, 131.0642),(128.84683, 134.983),(120.03264, 138.9018),(111.21845, 141.82059),(100.40427, 143.73938),(90.59008, 144.65817),(80.775894, 147.57697),(70.96171, 147.49576),(61.147522, 149.41455),(49.333336, 142.33334),(54.875885, 133.7706),(61.418434, 126.207855),(66.96098, 118.64511),(73.50353, 110.08237),(79.04608, 101.51962),(86.58863, 94.95688),(93.13118, 87.394135),(98.67373, 78.83139),(105.21628, 71.26865),(112.75883, 64.7059),(119.30138, 57.14316),(125.843925, 50.58042),(133.38647, 43.01768),(141.92902, 37.45494),(147.66667, 28.666668),(148.2727, 38.64829),(146.87874, 48.62991),(148.48477, 58.61153),(148.0908, 68.59315),(146.69684, 78.57477),(149.30287, 88.55639),(147.9089, 98.53801),(150.51494, 108.51963)],
        [(153.33334, 122),(143.51494, 108.51963),(141.9089, 98.53801),(144.30287, 88.55639),(142.69684, 78.57477),(145.0908, 68.59315),(145.48477, 58.61153),(142.87874, 48.62991),(145.2727, 38.64829),(147.66667, 28.666668),(157.66264, 28.950241),(167.65862, 30.233814),(177.65459, 29.517387),(187.65056, 29.80096),(197.64653, 28.084534),(207.6425, 26.368107),(217.63847, 28.65168),(227.63445, 28.935253),(241.66667, 31.333334),(235.68837, 39.495968),(227.71007, 45.6586),(219.73177, 51.82123),(213.75346, 59.983864),(206.77516, 67.1465),(200.79686, 75.309135),(192.81856, 81.47177),(186.84026, 89.63441),(179.86195, 96.79704),(172.88365, 103.95968),(166.90535, 112.122314)],
        [(153.33334, 122),(138.66101, 131.0642),(128.84683, 134.983),(120.03264, 138.9018),(111.21845, 141.82059),(100.40427, 143.73938),(90.59008, 144.65817),(80.775894, 147.57697),(70.96171, 147.49576),(61.147522, 149.41455),(49.333336, 142.33334),(54.875885, 133.7706),(61.418434, 126.207855),(66.96098, 118.64511),(73.50353, 110.08237),(79.04608, 101.51962),(86.58863, 94.95688),(93.13118, 87.394135),(98.67373, 78.83139),(105.21628, 71.26865),(112.75883, 64.7059),(119.30138, 57.14316),(125.843925, 50.58042),(133.38647, 43.01768),(141.92902, 37.45494),(147.66667, 28.666668),(157.66264, 28.950241),(167.65862, 30.233814),(177.65459, 29.517387),(187.65056, 29.80096),(197.64653, 28.084534),(207.6425, 26.368107),(217.63847, 28.65168),(227.63445, 28.935253),(241.66667, 31.333334),(235.68837, 39.495968),(227.71007, 45.6586),(219.73177, 51.82123),(213.75346, 59.983864),(206.77516, 67.1465),(200.79686, 75.309135),(192.81856, 81.47177),(186.84026, 89.63441),(179.86195, 96.79704),(172.88365, 103.95968),(166.90535, 112.122314)]
    ];

    private List<List<Vector2>> translatedList = [];

    private static readonly List<Color> Colours =
    [
        Colors.Green,
        Colors.Blue,
        Colors.Orange,
        Colors.Purple
    ];

    private HashSet<Vector2> alreadyExists = new();
    private int iteration = 0;
    
    public override void _Ready()
    {
        foreach(var vertices in VerticesList)
        {
            List<Vector2> translated = [];
            foreach(var tuple in vertices)
            {
                translated.Add(new Vector2((float)tuple.Item1, (float)tuple.Item2));
            }
            translatedList.Add(translated);
            
            // TranslateVertices(vertices);
        }
    }

    private void TranslateVertices(List<Vector2> vertices)
    {
        Vector2 minVector = vertices[0];
        foreach(var vector in vertices)
        {
            if (vector.X < minVector.X)
            {
                minVector.X = vector.X;
            }

            if (vector.Y < minVector.Y)
            {
                minVector.Y = vector.Y;
            }
        }

        minVector -= new Vector2(10, 10); // Give a little buffer
        for(int i = 0; i < vertices.Count; i++)
        {
            vertices[i] -= minVector;
        }
    }
    
    public override void _Draw()
    {
        int total = 0;
        for (int i = 0; i < translatedList.Count; i++)
        {
            DrawPoint(translatedList[i][0]);
            for (int j = 1; j < translatedList[i].Count; j++)
            {
                DrawPoint(translatedList[i][j]);
                DrawLine(translatedList[i][j - 1], translatedList[i][j], Colours[i], 1);
                total++;
                if (total > iteration)
                {
                    return;
                }
            }
            DrawLine(translatedList[i][translatedList[i].Count - 1], translatedList[i][0], Colours[i], 1);
        }

        alreadyExists.Clear();
    }

    private void DrawPoint(Vector2 point)
    {
        Color color = !alreadyExists.Add(point) ? Colors.Yellow : Colors.White;
        DrawCircle(point, 2, color);
    }

    public override void _Input(InputEvent @event)
    {
        if (@event is InputEventKey keyEvent && keyEvent.IsPressed())
        {
            if (keyEvent.Keycode == Key.Tab)
            {
                iteration++;
                QueueRedraw();
            } else if (keyEvent.Keycode == Key.Space)
            {
                GetTree().ReloadCurrentScene();
            }
        }
    }

    
}