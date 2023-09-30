import ast
import json
import os
import pprint

from forge.sdk import (
    Agent,
    AgentDB,
    Step,
    StepRequestBody,
    Workspace,
    ForgeLogger,
    Task,
    TaskRequestBody,
    PromptEngine,
    chat_completion_request,
)
import openai

LOG = ForgeLogger(__name__)


class ForgeAgent(Agent):
    """
    The goal of the Forge is to take care of the boilerplate code so you can focus on
    agent design.

    There is a great paper surveying the agent landscape: https://arxiv.org/abs/2308.11432
    Which I would highly recommend reading as it will help you understand the possabilities.

    Here is a summary of the key components of an agent:

    Anatomy of an agent:
         - Profile
         - Memory
         - Planning
         - Action

    Profile:

    Agents typically perform a task by assuming specific roles. For example, a teacher,
    a coder, a planner etc. In using the profile in the llm prompt it has been shown to
    improve the quality of the output. https://arxiv.org/abs/2305.14688

    Additionally baed on the profile selected, the agent could be configured to use a
    different llm. The possabilities are endless and the profile can be selected selected
    dynamically based on the task at hand.

    Memory:

    Memory is critical for the agent to acculmulate experiences, self-evolve, and behave
    in a more consistent, reasonable, and effective manner. There are many approaches to
    memory. However, some thoughts: there is long term and short term or working memory.
    You may want different approaches for each. There has also been work exploring the
    idea of memory reflection, which is the ability to assess its memories and re-evaluate
    them. For example, condensting short term memories into long term memories.

    Planning:

    When humans face a complex task, they first break it down into simple subtasks and then
    solve each subtask one by one. The planning module empowers LLM-based agents with the ability
    to think and plan for solving complex tasks, which makes the agent more comprehensive,
    powerful, and reliable. The two key methods to consider are: Planning with feedback and planning
    without feedback.

    Action:

    Actions translate the agents decisions into specific outcomes. For example, if the agent
    decides to write a file, the action would be to write the file. There are many approaches you
    could implement actions.

    The Forge has a basic module for each of these areas. However, you are free to implement your own.
    This is just a starting point.
    """

    def __init__(self, database: AgentDB, workspace: Workspace):
        """
        The database is used to store tasks, steps and artifact metadata. The workspace is used to
        store artifacts. The workspace is a directory on the file system.

        Feel free to create subclasses of the database and workspace to implement your own storage
        """
        super().__init__(database, workspace)

    async def create_task(self, task_request: TaskRequestBody) -> Task:
        """
        The agent protocol, which is the core of the Forge, works by creating a task and then
        executing steps for that task. This method is called when the agent is asked to create
        a task.

        We are hooking into function to add a custom log message. Though you can do anything you
        want here.
        """
        task = await super().create_task(task_request)
        LOG.info(
            f"📦 Task created: {task.task_id} input: {task.input[:40]}{'...' if len(task.input) > 40 else ''}"
        )
        return task

    async def execute_step(self, task_id: str, step_request: StepRequestBody) -> Step:
        """
        For a tutorial on how to add your own logic please see the offical tutorial series:
        https://aiedge.medium.com/autogpt-forge-e3de53cc58ec

        The agent protocol, which is the core of the Forge, works by creating a task and then
        executing steps for that task. This method is called when the agent is asked to execute
        a step.

        The task that is created contains an input string, for the bechmarks this is the task
        the agent has been asked to solve and additional input, which is a dictionary and
        could contain anything.

        If you want to get the task use:

        ```
        task = await self.db.get_task(task_id)
        ```

        The step request body is essentailly the same as the task request and contains an input
        string, for the bechmarks this is the task the agent has been asked to solve and
        additional input, which is a dictionary and could contain anything.

        You need to implement logic that will take in this step input and output the completed step
        as a step object. You can do everything in a single step or you can break it down into
        multiple steps. Returning a request to continue in the step output, the user can then decide
        if they want the agent to continue or not.
        """
        # An example that
        step = await self.db.create_step(
            task_id=task_id, input=step_request, is_last=True
        )
        import openai

        # Set up the OpenAI API key
        openai.api_key = os.getenv("OPENAI_API_KEY")

        # Start a conversation with the model
        prompt = f"""
{step_request.input}
Pick one command amongst these:
write_to_file("example.txt", "Hello World")


For example, if I ask you to write a file to my_gift.txt, and to write the things you would suggest to buy for
my little sister, you would write:
write_to_file("my_gift.txt", "I would suggest her to buy her flowers")
"""
        print(prompt)
        response = openai.ChatCompletion.create(
          model="gpt-4",
          messages=[
                {"role": "user", "content": prompt}
            ]
        )

        # Extract the model's response
        answer = response.choices[0].message.content
        # answer = transform_content(answer)
        print(answer)
        data = parse_command_using_ast(answer)

        command = data["command"]
        if command == "write_to_file":
            filename = data["arg_1"]
            content = data["arg_2"]
            self.workspace.write(task_id=task_id, path=filename, data=content.encode())


            await self.db.create_artifact(
                task_id=task_id,
                step_id=step.step_id,
                file_name=filename,
                relative_path="",
                agent_created=True,
            )

            step.output = answer

            LOG.info(f"\t✅ Final Step completed: {step.step_id}")

            return step


# def transform_content(content: str) -> str:
#     # Remove the "python" word
#     transformed = content.replace("python", "")
#
#     # Add \n at the beginning
#     transformed = "\\n" + transformed
#
#     return transformed
#
# import ast

def parse_command_using_ast(code):
    try:
        parsed = ast.parse(code)
    except SyntaxError:
        return None

    if not isinstance(parsed, ast.Module):
        return None

    if not parsed.body or not isinstance(parsed.body[0], ast.Expr):
        return None

    call_node = parsed.body[0].value

    if not isinstance(call_node, ast.Call):
        return None

    command = call_node.func.id
    args = [arg.s for arg in call_node.args if isinstance(arg, ast.Str)]

    result = {"command": command}
    for idx, arg in enumerate(args, 1):
        result[f"arg_{idx}"] = arg

    return result
