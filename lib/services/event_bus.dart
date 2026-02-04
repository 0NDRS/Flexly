import 'dart:async';

class EventBus {
  static final EventBus _instance = EventBus._internal();

  factory EventBus() {
    return _instance;
  }

  EventBus._internal();

  final _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get stream => _controller.stream;

  void fire(dynamic event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

class UserFollowEvent {}

class NotificationsReadEvent {}

class AnalysisDeletedEvent {
  final String analysisId;
  AnalysisDeletedEvent(this.analysisId);
}

class AnalysisCreatedEvent {
  final Map<String, dynamic> analysis;
  AnalysisCreatedEvent(this.analysis);
}

class UnitsPreferenceChangedEvent {
  final String units;
  UnitsPreferenceChangedEvent(this.units);
}

class ProfileUpdatedEvent {}

class TrainingPlanCreatedEvent {
  final Map<String, dynamic> plan;
  TrainingPlanCreatedEvent(this.plan);
}
