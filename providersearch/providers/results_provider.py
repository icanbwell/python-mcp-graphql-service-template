from typing import Any, Dict


class ResultsProvider:
    def get_results(
        self, *, param1: str  # force keyword only args from this point forward
    ) -> Dict[str, Any]:
        raise NotImplementedError
