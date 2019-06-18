import 'dart:async';

import 'package:meta/meta.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_weather/repositories/repositories.dart';
import 'package:flutter_weather/models/models.dart';

abstract class WeatherEvent extends Equatable {
  WeatherEvent([List props = const []]) : super(props);
}

class FetchWeather extends WeatherEvent {
  final String city;

  FetchWeather({@required this.city})
      : assert(city != null),
        super([city]);

  @override
  String toString() => 'FetchWeather { city: $city }';
}

class RefreshWeather extends WeatherEvent {
  final String city;

  RefreshWeather({@required this.city})
      : assert(city != null),
        super([city]);

  @override
  String toString() => 'RefreshWeather { city: $city }';
}

abstract class WeatherState extends Equatable {
  WeatherState([List props = const []]) : super(props);
}

class WeatherEmpty extends WeatherState {
  @override
  String toString() => 'WeatherEmpty';
}

class WeatherLoading extends WeatherState {
  @override
  String toString() => 'WeatherEmpty';
}

class WeatherLoaded extends WeatherState {
  final Weather weather;

  WeatherLoaded({@required this.weather})
      : assert(weather != null),
        super([weather]);

  @override
  String toString() => 'WeatherLoaded { weather: $weather }';
}

class WeatherError extends WeatherState {
  @override
  String toString() => 'WeatherError';
}

class WeatherBloc extends HydratedBloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({@required this.weatherRepository})
      : assert(weatherRepository != null);

  @override
  WeatherState get initialState => super.initialState ?? WeatherEmpty();

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
    if (event is FetchWeather) {
      yield WeatherLoading();
      try {
        final Weather weather = await weatherRepository.getWeather(event.city);
        yield WeatherLoaded(weather: weather);
      } catch (_) {
        yield WeatherError();
      }
    }

    if (event is RefreshWeather) {
      try {
        final Weather weather = await weatherRepository.getWeather(event.city);
        yield WeatherLoaded(weather: weather);
      } catch (_) {
        yield currentState;
      }
    }
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) {
    return WeatherLoaded(
      weather: Weather(
        condition: WeatherCondition.values[json['condition'] as int],
        formattedCondition: json['formattedCondition'],
        minTemp: json['minTemp'],
        temp: json['temp'],
        maxTemp: json['maxTemp'],
        locationId: json['locationId'],
        created: json['created'],
        lastUpdated: DateTime.parse(json['lastUpdated']),
        location: json['location'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(WeatherState state) {
    if (state is WeatherLoaded) {
      return {
        'condition': state.weather.condition.index,
        'formattedCondition': state.weather.formattedCondition,
        'minTemp': state.weather.minTemp,
        'temp': state.weather.temp,
        'maxTemp': state.weather.maxTemp,
        'locationId': state.weather.locationId,
        'created': state.weather.created,
        'lastUpdated': state.weather.lastUpdated.toIso8601String(),
        'location': state.weather.location,
      };
    }
    return null;
  }
}
