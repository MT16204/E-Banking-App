abstract class AnalyticsEvent {
  const AnalyticsEvent();
}

class AnalyticsStarted extends AnalyticsEvent {
  const AnalyticsStarted();
}

class AnalyticsRefreshed extends AnalyticsEvent {
  const AnalyticsRefreshed();
}
