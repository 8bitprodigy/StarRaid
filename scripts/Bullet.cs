using Godot;
using System;

public class Bullet : KinematicBody
{
    const float SPEED = 3;

    float life = 5; // In seconds
    Vector3 velocity;

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
        KinematicCollision collision = MoveAndCollide(velocity * SPEED);
        if (collision != null)
        {
            // Send "hit by this bullet" message to receiver
            if ((collision.Collider as Node).IsInGroup("enemy"))
                (collision.Collider as Truck).Hit(4);

            QueueFree();
        }
    }
}
