import 'package:banking_app/data/models/models.dart';

abstract class AnalyticsState {
  const AnalyticsState();
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final List<TransactionModel> transactions;

  const AnalyticsLoaded(this.transactions);
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);
}
