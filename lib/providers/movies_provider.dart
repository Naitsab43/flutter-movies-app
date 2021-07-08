
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:peliculas_app/helpers/debouncer.dart';
import 'package:peliculas_app/models/credits_response.dart';
import 'package:peliculas_app/models/now_playing_response.dart';
import 'package:peliculas_app/models/popular_response.dart';
import 'package:peliculas_app/models/search_response.dart';

class MoviesProvider extends ChangeNotifier {

  String _baseUrl = "api.themoviedb.org";
  String _apiKey = "8b2e8ef3f8852c3be54da29b484dae24";
  String _language = "es-ES";

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Cast>> movieCast = {};

  int _popularPages = 0;

  final debouncer = Debouncer(
    duration: Duration(milliseconds: 400),
  );

  MoviesProvider(){
    print("Inicializado");
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  final StreamController<List<Movie>> _suggestionsStreamController = new StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream => this._suggestionsStreamController.stream;

  Future<String> _getJsonData(String endpoint, [int page = 1]) async{

    final url = Uri.https(_baseUrl, endpoint, {
      "api_key": _apiKey,
      "language": _language,
      "page": "$page"
    });

    final response = await http.get(url);

    return response.body;
  }

  getOnDisplayMovies() async {
    
    final response = await _getJsonData("3/movie/now_playing");

    final nowPlayingResponse = NowPlayingResponse.fromJson(response);
    this.onDisplayMovies = nowPlayingResponse.results;

    // Notifica a los otros widgets que hubo un cambio
    notifyListeners();
    
  }

  getPopularMovies() async {

    _popularPages++;

    final response = await _getJsonData("3/movie/popular", _popularPages);

    final popularResponse = PopularResponse.fromJson(response);
    this.popularMovies = [...popularMovies, ...popularResponse.results];

    // Notifica a los otros widgets que hubo un cambio
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {

    if(movieCast.containsKey(movieId)) return movieCast[movieId]!;
    
    print("pidiendo");

    final response = await _getJsonData("3/movie/$movieId/credits");
    final creditResponse = CreditResponse.fromJson(response);

    movieCast[movieId] = creditResponse.cast;

    return creditResponse.cast;

  }
  
  Future<List<Movie>> searchMovies(String query) async {

    final url = Uri.https(_baseUrl, "3/search/movie", {
      "api_key": _apiKey,
      "language": _language,
      "query": query
    });

    final response = await http.get(url);

    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;

  }

  void getSuggestionsByQuery(String searchTerm){

    debouncer.value = "";
    debouncer.onValue = (value) async {

      final results = await this.searchMovies(value);
      this._suggestionsStreamController.add(results);

    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {

      debouncer.value = searchTerm;

    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());

  }

}

