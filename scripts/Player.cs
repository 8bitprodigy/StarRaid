using Godot;
using System;

public class Player : Spatial
{
    const float MAX_SPEED = 100;
    const float ENGINE_VOLUME = -10;

    float speed = 40; // m/s
    float throttle = 50; // Out of 100
    float pitch_add = 0.9f;
    float roll_add = 2f;
    float yaw_add = 0.2f;

    
}
