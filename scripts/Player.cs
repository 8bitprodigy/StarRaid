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

    PackedScene bullet;
    PackedScene missile;
    Spatial gyroscope;

    float resetLeftDisplayDelay = 0;

    float cannonDelay = 0; // Do not change this one
    float missileDelay = 0;
    bool nextIsRight = true;
    Gun gun = Gun.Cannon;
    float lockOnTimer = 0;
    public Spatial lockOnTarget;

    public override void _Ready()
    {
        bullet = GD.Load<PackedScene>("res://scenes/Bullet.tscn");
        missile = GD.Load<PackedScene>("res://scenes/Missile.tscn");
        gyroscope = GetNode<Spatial>("cockpit/gimbal/gyroscope");

        SetProcess(true);
    }

    public override void _Process(float delta)
    {
        if (Input.IsKeyPressed((int)KeyList.Escape))
            GetTree().Quit();
        
        if (Input.IsActionPressed("speed_up"))
        {
            SetThrottle(speed + 1);
        }
        if (Input.IsActionPressed("speed_down"))
        {
            SetThrottle(speed - 1);
        }
        if (Input.IsActionPressed("pitch_up"))
        {
            RotateObjectLocal(new Vector3(1,0,0), pitch_add * delta);
            gyroscope.Rotate(new Vector3(1,0,0), -pitch_add * delta);
        }
        if (Input.IsActionPressed("pitch_down"))
        {
            RotateObjectLocal(new Vector3(1,0,0),-pitch_add * delta);
            gyroscope.Rotate(new Vector3(1,0,0), pitch_add * delta);
        }
        if (Input.IsActionPressed("roll_right"))
        {
            RotateObjectLocal(new Vector3(0,0,1), -roll_add * delta);
            gyroscope.Rotate(new Vector3(0,0,1), roll_add * delta);
        }
        if (Input.IsActionPressed("roll_left"))
        {
            RotateObjectLocal(new Vector3(0,0,1), roll_add * delta);
            gyroscope.Rotate(new Vector3(0,0,1), -roll_add * delta);
        }
        // if Input.is_action_pressed("yaw_right"):
        //     rotate_object_local(Vector3(0,1,0), -yaw_add * delta)
        //     gyroscope.rotate(Vector3(0,1,0), yaw_add * delta)
        // if Input.is_action_pressed("yaw_left"):
        //     rotate_object_local(Vector3(0,1,0), yaw_add * delta)
        //     gyroscope.rotate(Vector3(0,1,0), -yaw_add * delta)

        // Move
        TranslateObjectLocal(new Vector3(0, 0, -speed * delta));

        if (Input.IsActionJustPressed("change_gun"))
        {
            switch (gun) {
            case Gun.Cannon: gun = Gun.ASM; break;
            case Gun.ASM: gun = Gun.AAM; break;
            case Gun.AAM: gun = Gun.Cannon; break;
            default: break;
            }

            
        }
    }
}
