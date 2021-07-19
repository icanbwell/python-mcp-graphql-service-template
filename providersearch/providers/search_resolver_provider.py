from typing import Any, Dict

from graphql import GraphQLResolveInfo

from providersearch.providers.results_provider import ResultsProvider


class SearchResolverProvider:
    def __init__(self, results_provider: ResultsProvider):
        self.results_provider = results_provider

    def resolve_providers(
        self,
        obj: Any,
        info: GraphQLResolveInfo,
        *,  # force keyword only args from this point forward
        param1: str,
    ) -> Dict[str, Any]:
        return self.results_provider.get_results(param1=param1)
