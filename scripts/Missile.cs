using Godot;
using System;

public class Missile : KinematicBody
{
    const float SPEED = 3;

    float life = 5; // In seconds
    Vector3 velocity;

    Player owner;

    public override void _Ready()
    {
        SetProcess(true);
        SetPhysicsProcess(true);
    }

    public override void _Process(float delta)
    {
        life -= delta;
        if (life <= 0)
            QueueFree();
    }

    public override void _PhysicsProcess(float delta)
    {
        // Target locating
        if (owner != null && owner.lockOnTarget != null)

        KinematicCollision collision = MoveAndCollide(velocity * SPEED);
        if (collision != null)
        {
            QueueFree();
        }
    }
}
