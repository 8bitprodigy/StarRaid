using Godot;
using System;

public class Truck : KinematicBody, IEntity
{
    const float SPEED = 15;

    Material destroyedMat;

    bool dead = false;
    float health = 50;
    Vector3 velocity = new Vector3(-1, 0, 0) * SPEED;

    public float GetHealth() => health;
    public bool IsDead() => dead;

    public override void _Ready()
    {
        destroyedMat = (Material)ResourceLoader.Load("res://graphics/truck/truck_exploded.tres.material");

        SetPhysicsProcess(true);
    }

    public override void _PhysicsProcess(float delta)
    {
        MoveAndSlide(velocity);
    }

    public void Hit(float damage)
    {
        if (!dead)
        {
            health -= damage;

            if (health <= 0)
            {
                // Effects
                ((MeshInstance)GetNode("truck")).MaterialOverride = destroyedMat;
                ((Sprite3D)GetNode("ExplosionSplat")).Visible = true;
                ((AnimationPlayer)GetNode("AnimationPlayer")).Play("explode");
                ((Particles)GetNode("ExplosionParticles")).Emitting = true;
                ((Particles)GetNode("SmokeParticles")).Emitting = true;

                SetPhysicsProcess(false);

                Godot.GD.Print("Truck destroyed!");
                dead = true;

                // Signals
                ((Player)GetTree().GetNodesInGroup("player")[0]).resetLeftDisplayDelay = 3; // Wait 3 seconds to switch display
            }
        }
    }
}
