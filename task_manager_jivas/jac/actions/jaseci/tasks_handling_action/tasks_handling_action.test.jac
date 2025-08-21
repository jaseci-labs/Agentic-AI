# Importing the JIVAS graph nodes
import from jivas.agent.core.agents { Agents }
import from jivas.agent.core.agent { Agent }
import from jivas.agent.action.action { Action }
import from jivas.agent.action.actions { Actions }
import from jivas.agent.memory.memory { Memory }

# Import the walkers to execute the each functionality
# import from sample_walker_1 { sample_walker_1 }
# import from sample_walker_2 { sample_walker_2 }


# -----------------------------------------------------------------------
# creating the graph here first
# -----------------------------------------------------------------------
with entry {
    agents = root ++> Agents();
    agent = agents[0] ++> Agent();
    memory = agent[0] ++> Memory();
    actions = agent[0] ++> Actions();
    action = actions[0] ++> Action(label='TasksHandlingAction');
    action[0].agent_id = agent[0].id;
}


# -----------------------------------------------------------------------
# Implement the test cases here
# -----------------------------------------------------------------------

# test sample_test_case_1 {
#
# }

# test sample_test_case_2 {
#
# }