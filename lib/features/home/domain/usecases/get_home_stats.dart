import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/home_stats.dart';
import '../repositories/home_repository.dart';

class GetHomeStats implements UseCase<HomeStats, GetHomeStatsParams> {
  final HomeRepository repository;

  GetHomeStats(this.repository);

  @override
  Future<Either<Failure, HomeStats>> call(GetHomeStatsParams params) {
    return repository.getStats(topLimit: params.topLimit);
  }
}

class GetHomeStatsParams extends Equatable {
  final int topLimit;

  const GetHomeStatsParams({this.topLimit = 5});

  @override
  List<Object> get props => [topLimit];
}
