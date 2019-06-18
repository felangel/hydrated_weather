import 'dart:async';

import 'package:meta/meta.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {}

class TemperatureUnitsToggled extends SettingsEvent {
  @override
  String toString() => 'TemperatureUnitsToggled';
}

enum TemperatureUnits { fahrenheit, celsius }

class SettingsState extends Equatable {
  final TemperatureUnits temperatureUnits;

  SettingsState({@required this.temperatureUnits})
      : assert(temperatureUnits != null),
        super([temperatureUnits]);

  @override
  String toString() => 'SettingsState { temperatureUnits: $temperatureUnits }';
}

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  @override
  SettingsState get initialState =>
      super.initialState ??
      SettingsState(temperatureUnits: TemperatureUnits.celsius);

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is TemperatureUnitsToggled) {
      yield SettingsState(
        temperatureUnits:
            currentState.temperatureUnits == TemperatureUnits.celsius
                ? TemperatureUnits.fahrenheit
                : TemperatureUnits.celsius,
      );
    }
  }

  @override
  SettingsState fromJson(Map<String, dynamic> json) {
    return SettingsState(
      temperatureUnits:
          TemperatureUnits.values[json['temperatureUnits'] as int],
    );
  }

  @override
  Map<String, dynamic> toJson(SettingsState state) {
    return {'temperatureUnits': state.temperatureUnits.index};
  }
}
