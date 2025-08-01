# Digital Agent Freight (DAF) Packages

This directory is for your custom or downloaded Digital Agent Freight (DAF) packages. DAFs contain all configurations, knowledge, and memory snapshots for a JIVAS AI agent.

## Instructions

1. **Create Your DAF Packages**: Place your custom or downloaded DAF packages in this folder.
2. **Naming Convention**: Use clear and descriptive names for your DAF packages to ensure they are easily identifiable.
3. **Permissions**: Ensure your packages have the appropriate permissions to be accessed and executed.

## Creating a Starter DAF Package with jvcli

To create a new DAF package using `jvcli`, follow these steps:

1. **Run the Command**: Use the following command to create a new DAF package:
    ```sh
    jvcli create agent --name your_agent_name --description "Your agent description"
    ```
    Replace `your_agent_name` with the desired name for your agent in snake_case.

2. **Options**: You can customize the creation process with various options:
    - `--version`: Specify the version of the agent. Default is `0.0.1`.
    - `--jivas_version`: Specify the version of Jivas. Default is `2.1.0`.
    - `--path`: Directory to create the agent folder in. Default is `./daf`.
    - `--namespace`: Namespace for the agent. Defaults to the username in the token.

3. **Example**:
    ```sh
    jvcli create agent --name my_agent --description "My custom JIVAS AI agent"
    ```

For more information, refer to the project's documentation.

## Notes

- DAF packages should be thoroughly tested before deployment.
- Follow best practices for configuration and error handling.

For more information, refer to the project's documentation.