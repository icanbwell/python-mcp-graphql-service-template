from typing import Any, Dict

from providersearch.providers.results_provider import ResultsProvider


class MyResultsProvider(ResultsProvider):
    def get_results(self, query_id: str) -> Dict[str, Any]:
        return {}
