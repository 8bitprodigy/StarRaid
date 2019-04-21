public interface IEntity
{
    float GetHealth();
    bool IsDead();
    void Hit(float damage);
}
