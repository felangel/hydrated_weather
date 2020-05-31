import 'dart:async';

import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_weather/models/models.dart';

class ThemeState extends Equatable {
  final ThemeData theme;
  final MaterialColor color;

  const ThemeState({@required this.theme, @required this.color})
      : assert(theme != null),
        assert(color != null);

  @override
  List<Object> get props => [theme, color];
}

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class WeatherChanged extends ThemeEvent {
  final WeatherCondition condition;

  const WeatherChanged({@required this.condition}) : assert(condition != null);

  @override
  List<Object> get props => [condition];
}

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  @override
  ThemeState get initialState =>
      super.initialState ??
      ThemeState(
        theme: ThemeData.light(),
        color: Colors.lightBlue,
      );

  @override
  Stream<ThemeState> mapEventToState(ThemeEvent event) async* {
    if (event is WeatherChanged) {
      yield _mapWeatherConditionToThemeData(event.condition);
    }
  }

  ThemeState _mapWeatherConditionToThemeData(WeatherCondition condition) {
    ThemeState theme;
    switch (condition) {
      case WeatherCondition.clear:
      case WeatherCondition.lightCloud:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.orangeAccent,
          ),
          color: Colors.yellow,
        );
        break;
      case WeatherCondition.hail:
      case WeatherCondition.snow:
      case WeatherCondition.sleet:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.lightBlueAccent,
          ),
          color: Colors.lightBlue,
        );
        break;
      case WeatherCondition.heavyCloud:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.blueGrey,
          ),
          color: Colors.grey,
        );
        break;
      case WeatherCondition.heavyRain:
      case WeatherCondition.lightRain:
      case WeatherCondition.showers:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.indigoAccent,
          ),
          color: Colors.indigo,
        );
        break;
      case WeatherCondition.thunderstorm:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.deepPurpleAccent,
          ),
          color: Colors.deepPurple,
        );
        break;
      case WeatherCondition.unknown:
        theme = ThemeState(
          theme: ThemeData.light(),
          color: Colors.lightBlue,
        );
        break;
    }
    return theme;
  }

  @override
  ThemeState fromJson(Map<String, dynamic> json) {
    return ThemeState(
      theme: ThemeData(primaryColor: _mapNameToColor(json['primaryColor'])),
      color: _mapNameToColor(json['color']),
    );
  }

  @override
  Map<String, dynamic> toJson(ThemeState state) {
    return {
      'primaryColor': _mapColorToName(state.theme.primaryColor),
      'color': _mapColorToName(state.color)
    };
  }

  Color _mapNameToColor(String name) {
    switch (name) {
      case 'orangeAccent':
        return Colors.orangeAccent;
      case 'yellow':
        return Colors.yellow;
      case 'lightBlueAccent':
        return Colors.lightBlueAccent;
      case 'lightBlue':
        return Colors.lightBlue;
      case 'blueGrey':
        return Colors.blueGrey;
      case 'grey':
        return Colors.grey;
      case 'indigoAccent':
        return Colors.indigoAccent;
      case 'indigo':
        return Colors.indigo;
      case 'deepPurpleAccent':
        return Colors.deepPurpleAccent;
      case 'deepPurple':
        return Colors.deepPurple;
      default:
        return Colors.lightBlue;
    }
  }

  String _mapColorToName(Color color) {
    if (color == Colors.orangeAccent) {
      return 'orangeAccent';
    } else if (color == Colors.yellow) {
      return 'yellow';
    } else if (color == Colors.lightBlueAccent) {
      return 'lightBlueAccent';
    } else if (color == Colors.blueGrey) {
      return 'blueGrey';
    } else if (color == Colors.grey) {
      return 'grey';
    } else if (color == Colors.indigoAccent) {
      return 'indigoAccent';
    } else if (color == Colors.indigo) {
      return 'indigo';
    } else if (color == Colors.deepPurpleAccent) {
      return 'deepPurpleAccent';
    } else if (color == Colors.deepPurple) {
      return 'deepPurple';
    } else {
      return 'lightBlue';
    }
  }
}
