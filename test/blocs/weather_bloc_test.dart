import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_weather/repositories/weather_repository.dart';
import 'package:flutter_weather/models/weather.dart';
import 'package:flutter_weather/blocs/weather_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockHydratedBlocStorage extends Mock implements HydratedBlocStorage {}

main() {
  group('WeatherBloc', () {
    final weather = Weather(
      condition: WeatherCondition.clear,
      formattedCondition: 'Clear',
      minTemp: 15,
      maxTemp: 20,
      locationId: 0,
      location: 'Chicago',
      lastUpdated: DateTime(2019),
    );

    HydratedBlocStorage hydratedBlocStorage;
    WeatherRepository weatherRepository;
    WeatherBloc weatherBloc;

    setUp(() {
      hydratedBlocStorage = MockHydratedBlocStorage();
      BlocSupervisor.delegate = HydratedBlocDelegate(hydratedBlocStorage);
      weatherRepository = MockWeatherRepository();
      weatherBloc = WeatherBloc(weatherRepository: weatherRepository);
    });

    tearDown(() {
      weatherBloc?.close();
    });

    test('has a correct initialState', () {
      expect(weatherBloc.initialState, WeatherEmpty());
    });

    group('FetchWeather', () {
      blocTest(
        'emits [WeatherLoading, WeatherLoaded] when weather repository returns weather',
        build: () async {
          when(weatherRepository.getWeather('chicago')).thenAnswer(
            (_) => Future.value(weather),
          );
          return WeatherBloc(weatherRepository: weatherRepository);
        },
        act: (bloc) async => bloc.add(FetchWeather(city: 'chicago')),
        expect: [
          WeatherLoading(),
          WeatherLoaded(weather: weather),
        ],
      );

      blocTest(
        'emits [WeatherLoading, WeatherError] when weather repository throws error',
        build: () async {
          when(weatherRepository.getWeather('chicago'))
              .thenThrow('Weather Error');
          return WeatherBloc(weatherRepository: weatherRepository);
        },
        act: (bloc) async => bloc.add(FetchWeather(city: 'chicago')),
        expect: [
          WeatherLoading(),
          WeatherError(),
        ],
      );
    });

    group('RefreshWeather', () {
      blocTest(
        'emits [WeatherLoaded] when weather repository returns weather',
        build: () async {
          when(weatherRepository.getWeather('chicago')).thenAnswer(
            (_) => Future.value(weather),
          );
          return WeatherBloc(weatherRepository: weatherRepository);
        },
        act: (bloc) async => bloc.add(RefreshWeather(city: 'chicago')),
        expect: [
          WeatherLoaded(weather: weather),
        ],
      );

      blocTest(
        'emits nothing when weather repository throws error',
        build: () async {
          when(weatherRepository.getWeather('chicago'))
              .thenThrow('Weather Error');
          return WeatherBloc(weatherRepository: weatherRepository);
        },
        act: (bloc) async => bloc.add(RefreshWeather(city: 'chicago')),
        expect: [],
      );
    });
  });
}
