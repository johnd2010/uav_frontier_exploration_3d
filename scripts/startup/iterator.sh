#!/bin/bash

NUM_RUNS=10
SLEEP_IN_BETWEEN_RUN_TIME=30
SLEEP_TIME=300  #1800 fo 60x60 forest

for i in $(seq 1 $NUM_RUNS); do
    echo "▶️ Run $i starting..."
    
    rm -f /tmp/sim_done_flag
    
    # /home/colorfulcraze/Documents/GiG/src/SLAM/ALOCUS/src/locus/triggers/single_uav_locus/start.sh&
    gnome-terminal -- bash -c "/home/colorfulcraze/Documents/Baseline/Frontiers/src/uav_frontier_exploration_3d/scripts/startup/start.sh; exec bash"
    
    sleep 10
    
    for attempt in $(seq 1 $SLEEP_TIME); do
        if rostopic list > /dev/null 2>&1; then
            echo "Exploring for $attempt seconds"
        else
            break
        fi
        sleep 1
    done

    # Loop until all processes are gone
    while true; do
        echo "Attempting to kill simulation processes..."

        tmux -L mrs kill-session -t simulation 2>/dev/null
        killall -q mavros_node
        killall -q px4
        killall -q gzserver
        pkill -f tmux:
        rosclean purge -y

        sleep 5

        # Check if any of them are still running
        pgrep -f mavros_node >/dev/null || \
        pgrep -f px4 >/dev/null || \
        pgrep -f gzserver >/dev/null || \
        pgrep -f tmux: >/dev/null

        if [ $? -ne 0 ]; then
            echo "All targeted processes have been successfully killed."
            break
        else
            echo "Some processes are still running. Retrying..."
        fi
    done

    cp /home/colorfulcraze/Documents/Logs/ROS/latest/rosout.log /home/colorfulcraze/Documents/Logs/Tugbot/larics/$i.log 

    sleep $SLEEP_IN_BETWEEN_RUN_TIME

    echo "✅ Run $i done."
done

echo "✅ All runs complete."
