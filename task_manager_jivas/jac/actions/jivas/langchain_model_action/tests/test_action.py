"""Tests for LangChainModelAction."""

import os


class TestLangChainModelAction:
    """Tests for LangChainModelAction."""

    def test_langchain_model_action(self) -> None:
        """Test LangChainModelAction."""

        from jaclang import jac_import
        from jaclang.runtimelib.context import ExecutionContext

        os.environ["JACPATH"] = "./"

        # load the JAC application
        jctx = ExecutionContext.create()

        filename = os.path.join(
            os.path.dirname(__file__),
            "..",
            "langchain_model_action.jac",
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
