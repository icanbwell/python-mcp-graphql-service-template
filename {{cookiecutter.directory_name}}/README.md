# helix.providersearch

To run it locally:

```
git clone
make devsetup
make up
```

Then navigate to: http://localhost:5000/graphql

## Example Queries

You can enter the following GraphQL query to test:

1a. Basic Search by name (exact term match)

```graphql
query getProviders {
    providers(search: "Paul", fuzzy: { fuzziness: "0" }) {
        total_count
        log
        results {
            content
            location {
                address {
                    line
                    city
                    state
                }
            }
            specialty {
                display
            }
        }
    }
}
```   

1b. Using specialty (exact term match)

```graphql
query getProviders {
    providers(search: "Internal", fuzzy: { fuzziness: "0" }) {
        total_count
        log
        results {
            content
            location {
                address {
                    line
                    city
                    state
                }
            }
            specialty {
                display
            }
        }
    }
}
```

2. Search ONLY for specialty (exact match)

```graphql
query getProviders {
    providers(specialty: [
        {
            display:"Internal Medicine"
        }
    ]) {
        total_count
        log
        results {
            content
            location {
                address {
                    line
                    city
                    state
                }
            }
            specialty {
                display
            }
        }
    }
}
```   

3. Search for name/specialty (fuzzy match)

```graphql
query getProviders {
    providers(search: "Internap", fuzzy: { fuzziness: "AUTO"}) {
        total_count
        log
        results {
            content
            location {
                address {
                    line
                    city
                    state
                }
            }
            specialty {
                display
            }
        }
    }
}
```   

4. Search by specialty and location (fuzzy match)

```graphql
query getProviders {
    providers(
        search: "Internap"
        search_position: {
            distance: 15
            lat: 39.406215
            lon: -76.450524
        }
    ) {
        total_count
        log
        results {
            content
            location {
                address {
                    line
                    city
                    state
                }
                position {
                    lat
                    lon
                }
            }
            specialty {
                display
            }
        }
    }
}
```

5. Type-ahead only

```graphql
query getProviders {
    providers(
        user: {
            id: "imran@icanbwell.com"
            app_id: "medstar"
            session_id: "2021-05-19"
            request_id: "testing_scoring"
        }
        search: "Foot doctor"
        search_position: { distance: 20, lat: 39.406215, lon: -76.450524 }
        limit: 20
        search_as_you_type:{}
    ) {
        total_count
        search_as_you_type {
            field
            text
            score
            photo {
                url
            }
            type
        }
    }
}
```   

6. Search-as-you-type (AND type-ahead)
```graphql
query getProviders {
    providers(
        user: {
            id: "imran@icanbwell.com"
            app_id: "medstar"
            session_id: "2021-05-19"
            request_id: "testing_scoring"
        }
        search: "Foot doctor"
        search_position: { distance: 20, lat: 39.406215, lon: -76.450524 }
        limit: 20
        search_as_you_type:{}
    ) {
        total_count
        results {
            score
            content
            explanation
            id
            photo {
                url
            }
        }
        search_as_you_type {
            field
            text
            score
            photo {
                url
            }
            type
        }
    }
}
```   

7. Search only practices

```graphql
query getProviders {
    providers(
        index: [practice]
        search: "Paul"
        search_position: {
            distance: 15
            lat: 39.406215
            lon: -76.450524
        }
        search_as_you_type: {
            field: content
        }
    ) {
        total_count
        search_as_you_type {
            text
            score
        }
        results {
            content
            location {
                address {
                    line
                    city
                    state
                }
            }
            specialty {
                display
            }
        }
    }
}
```

8. Filter values (aka dynamic filters)

```graphql
query getProviders {
    providers(
        index: [ practitioner]
        user: {
            id: "imran",
            session_id: "bar"
            request_id: "bar2"
            referring_url: "http://www.cnn.com/"
        }
        search: "Internal"
        limit: 10
        filter_values: [language, gender]
    ) {
        log
        total_count
        filter_values {
            field
            values {
                value
                count
            }
        }
        results {
            id
            score
            npi
            type
            content
            last_name
            specialty {
                display
                system
            }
        }
    }
}
```

9. Use smart scoring

```graphql
query getProviders {
    providers(
        index: [ practitioner]
        user: {
            id: "imran",
            session_id: "bar"
            request_id: "bar2"
            referring_url: "http://www.cnn.com/"
        }
        search: "Foot Doctor"
        search_position: {
            lat: 39.406215
            lon: -76.450524
        }
        limit: 10
        scoring: {
            smart: true
            relevance_weight: 0.1
            distance_weight: 0.9
            distance_decay: 0.5
        }
    ) {
        log
        total_count
        results {
            id
            score
            npi
            type
            content
            last_name
            location {
                address {
                    line
                    city
                    state
                }
                position {
                    lat
                    lon
                }
            }
            specialty {
                display
                system
            }
        }
    }
}
```

10. Call PSS when user clicks on a result item (request_id should match a previous search request)

```graphql
mutation {
    interacted(user: {id: "Cool", request_id: "Me"}, interaction: clicked, result_id: "12345")
}
```

11. Return distance in miles

```graphql
query getProviders {
    providers(
        search: "Internap"
        search_position: {
            distance: 15
            lat: 39.406215
            lon: -76.450524
        }
    ) {
        total_count
        log
        results {
            content
            location {
                address {
                    line
                    city
                    state
                }
                position {
                    lat
                    lon
                }
                distanceInMiles
            }
            specialty {
                display
            }
        }
    }
}
```

12. Get explanation of scoring

```graphql
query getProviders {
    providers(
        search: "Internap"
        search_position: {
            distance: 15
            lat: 39.406215
            lon: -76.450524
        }
        explain: {
            all: true
        }
    ) {
        total_count
        log
        results {
            content
            explanation
            location {
                address {
                    line
                    city
                    state
                }
                position {
                    lat
                    lon
                }
                distanceInMiles
            }
            specialty {
                display
            }
        }
    }
}
```

13. Mega query (pulls back all fields)

```graphql
query getProviders {
    providers(
        user: {
            id: "dave@medstar.org"
            app_id: "medstar"
            session_id: "2021-05-19"
            request_id: "testing_scoring"
        }
        search: "Babu"
        search_position: { distance: 15, lat: 39.406215, lon: -76.450524 }
        scoring: {
            smart: true
            relevance_weight: 0.5
            distance_weight: 0.5
            distance_decay: 0.5
            boost_mode: sum
        }
        explain: {
            all: true
        }
    ) {
        total_count
        log
        log_id
        log_url
        results {
            id
            score
            content
            explanation
            name {
                text
                family
                given
                prefix
                suffix
            }
            gender
            insurance {
                system
                display
                code
            }
            npi
            location {
                name
                address {
                    line
                    city
                    state
                }
                telecom {
                    system
                    value
                }
                position {
                    lat
                    lon
                }
                distanceInMiles
            }
            specialty {
                display
                code
                system
            }
            language
            practice
            next_available_slot {
                appointmentType
                start
            }
            photo {
               url
            }
            availability_score {
                system
                value
                comparator
            }
            ages_accepted {
                years {
                    gte
                    gt
                    lt
                    lte
                }
            }
            rating {
                system
                value
                comparator
                display
            }
            bookable {
                online
                phone
            }
            contact {
                system
                value
                rank
            }
            qualification {
                system
                code
                display
            }
            type
        }
    }
}
```

## Writing end to end tests

1. Right-click the "end_to_end" folder in Pycharm and choose New "End to End Test"
2. Type in name of the test
3. Create an index folder and copy in the practitioner-en and practice-en indexes as needed. You can get these from any
   PSS Elasticsearch server by query `<index name>/_search`
   e.g., `https://vpc-helix-elasticsearch-xeiyn2datxvmwhcxpcfykztv4a.us-east-1.es.amazonaws.com/practitioner-en/_search`
4. Create a graphql folder and create a query.gql file in there and paste in the graphql query (You can get this from
   the PSS graphql testing UI: `https://provider-search.dev.bwell.zone/graphql`)
5. Create an expected folder and store a .json file in there with what you expect as the result.  (You can start with an
   existing result from PSS and edit it to be what you expect)
6. That's it. Now when you run the test, it will create an index, run your graphql query and compare the result with
   your expected result

You can look at existing end-to-end tests for more info.

#### Multi scenario end to end tests

The test framework supports testing multiple scenarios per end to end test. This is done by adding files to the graphql
and expected directories that have the same name. This is helpful when you want to setup the index one time and test
multiple test cases. For example testing filtering by distance using multiple values for distance,
[that example is here](https://github.com/icanbwell/helix.providersearch/tree/main/tests/end_to_end/test_filter_by_distance)
.



