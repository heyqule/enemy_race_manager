#Workflow

Processor starts when AttackGroupProcessor.exec() is called

First, it determines which attack group to spawn. Normal, Flying and dropship.  More strategies can be added later

then it tries to pick a surface. 

- When mapping method uses one race per surface/planet, it uses surface_processor to pick a surface. Refer to attack_group_surface_processor.md
- Else it's always nauvis

Once a surface is found, it calls pick_gathering_location to pick a unit spawning location.
    
- This calls ErmAttackGroupChunkProcessor.pick_spawn_location, refer to attack_group_chunk_processor.md

If both surface and spawn_location are found, it calls generate_unit_queue() to generate the attack group.

generate_unit_queue() build a queue to generate 5 units every second.  

Once the group has built, it will assign the proper attack strategy.

