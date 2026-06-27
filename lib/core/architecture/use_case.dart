abstract class UseCase<R, Params> {
  const UseCase();

  Future<R> call(Params params);
}

class NoParams {
  const NoParams();
}
