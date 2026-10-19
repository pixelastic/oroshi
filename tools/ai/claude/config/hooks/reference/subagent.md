# Subagents

How the hooks tell subagents apart from the main agent.

## Language

**subagent injection**: Marking a command as run by a subagent, so the command
can tell it apart from one run by the main agent. _Avoid_: subagent detection,
agent env var, subagent flag

**pending subagent**: A subagent still running when the Stop hook fires. Its
presence makes the Stop hook skip the notification. _Avoid_: running subagent,
active agent, live subagent

## Relationships

- A Stop with at least one **pending subagent** never notifies; any other
  `background_tasks` entry never blocks it.
