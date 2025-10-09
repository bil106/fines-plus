abstract class CarInfoStatus {}

class CarInfoInitialStatus extends CarInfoStatus {}

class CarInfoLoadingStatus extends CarInfoStatus {}

class CarInfoLoadedStatus extends CarInfoStatus {
  final List<Map<String, dynamic>> fines;
  CarInfoLoadedStatus(this.fines);
}

class CarInfoErrorStatus extends CarInfoStatus {
  final String message;
  CarInfoErrorStatus(this.message);
}


class CarInfoUnauthorizedStatus extends CarInfoStatus {}
