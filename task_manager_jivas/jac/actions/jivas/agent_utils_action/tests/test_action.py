"""Tests for AgentUtilsAction."""

import os


class TestAgentUtilsAction:
    """Tests for AgentUtilsAction."""

    def test_agent_utils_action(self) -> None:
        """Test AgentUtilsAction."""

        from jaclang import jac_import
        from jaclang.runtimelib.context import ExecutionContext

        os.environ["JACPATH"] = "./"

        # load the JAC application
        jctx = ExecutionContext.create()

        filename = os.path.join(
            os.path.dirname(__file__),
            "..",
            "agent_utils_action.jac",
        )

        base, mod = os.path.split(filename)
        base = base if base else "./"
        mod = mod[:-4]

        jac_import(
            target=mod,
            base_path=base,
            cachable=True,
            override_name="__main__",
        )

        jctx.close()

        del os.environ["JACPATH"]
