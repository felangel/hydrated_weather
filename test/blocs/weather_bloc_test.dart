import 'dart:async';

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
      test(
          'emits [WeatherEmpty, WeatherLoading, WeatherLoaded] when weather repository returns weather',
          () {
        final Weather weather = Weather(
          condition: WeatherCondition.clear,
          formattedCondition: 'Clear',
          minTemp: 15,
          maxTemp: 20,
          locationId: 0,
          location: 'Chicago',
          lastUpdated: DateTime(2019),
        );
        when(weatherRepository.getWeather('chicago')).thenAnswer(
          (_) => Future.value(weather),
        );
        expectLater(
          weatherBloc,
          emitsInOrder([
            WeatherEmpty(),
            WeatherLoading(),
            WeatherLoaded(weather: weather),
          ]),
        );
        weatherBloc.add(FetchWeather(city: 'chicago'));
      });

      test(
          'emits [WeatherEmpty, WeatherLoading, WeatherError] when weather repository throws error',
          () {
        when(weatherRepository.getWeather('chicago'))
            .thenThrow('Weather Error');
        expectLater(
          weatherBloc,
          emitsInOrder([
            WeatherEmpty(),
            WeatherLoading(),
            WeatherError(),
          ]),
        );
        weatherBloc.add(FetchWeather(city: 'chicago'));
      });
    });

    group('RefreshWeather', () {
      test(
          'emits [WeatherEmpty, WeatherLoaded] when weather repository returns weather',
          () {
        final Weather weather = Weather(
          condition: WeatherCondition.clear,
          formattedCondition: 'Clear',
          minTemp: 15,
          maxTemp: 20,
          locationId: 0,
          location: 'Chicago',
          lastUpdated: DateTime(2019),
        );
        when(weatherRepository.getWeather('chicago')).thenAnswer(
          (_) => Future.value(weather),
        );
        expectLater(
          weatherBloc,
          emitsInOrder([
            WeatherEmpty(),
            WeatherLoaded(weather: weather),
          ]),
        );
        weatherBloc.add(RefreshWeather(city: 'chicago'));
      });

      test('emits [WeatherEmpty] when weather repository throws error', () {
        when(weatherRepository.getWeather('chicago'))
            .thenThrow('Weather Error');
        expectLater(
          weatherBloc,
          emitsInOrder([WeatherEmpty()]),
        );
        weatherBloc.add(RefreshWeather(city: 'chicago'));
      });
    });
  });
}
