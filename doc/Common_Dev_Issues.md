#### Enemy entities with auto place controls 'xxx' on surface 'xxx' have different collision masks.
This happen when an entity that use auto place controls have different collision masks than the other entities.
The simple fix is set "collision_mask" to nil and let the game handle it.  Otherwise, you define your collsion mask to use same set for that auto place control. 