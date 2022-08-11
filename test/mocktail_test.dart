import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

import 'rewards_membership_summary_query.ast.gql.dart'
    as rewards_membership_summary_query;

class SomeCubit extends Cubit<int> {
  final GraphQLClient client;

  SomeCubit(this.client) : super(0);

  void doSomething() {
    ObservableQuery _rewardsMembershipQuery = client.watchQuery(
      WatchQueryOptions(
        operationName: 'RewardsMembershipSummary',
        document: rewards_membership_summary_query.document,
        fetchPolicy: FetchPolicy.noCache,
        fetchResults: true,
      ),
    );

    emit(1);
  }
}

class MockGraphQLClient extends Mock implements GraphQLClient {}

class MockObservableQuery extends Mock implements ObservableQuery {}

class MockWatchQueryOptions extends Mock implements WatchQueryOptions {}

void main() {
  late MockGraphQLClient graphQLClient;
  final rewardsObservableQuery = MockObservableQuery();

  setUp(() {
    graphQLClient = MockGraphQLClient();
    registerFallbackValue(MockWatchQueryOptions());
  });

  blocTest<SomeCubit, int>(
    'initial state is RewardsLoadInProgress',
    build: () {
      when(
        () => graphQLClient.watchQuery(any()),
      ).thenReturn(rewardsObservableQuery);
      return SomeCubit(graphQLClient);
    },
    act: (cubit) => cubit.doSomething(),
    expect: () => const [1],
  );
}
