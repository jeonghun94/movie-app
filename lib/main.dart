import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final Future<List<MovieModel>> popular = ApiService.getMovies('popular');
  final Future<List<MovieModel>> nowPlaying =
      ApiService.getMovies('now-playing');
  final Future<List<MovieModel>> commingSoon =
      ApiService.getMovies('coming-soon');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Movie App",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Popular",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: FutureBuilder(
                future: popular,
                builder: (context, popularSnapshot) {
                  if (popularSnapshot.hasData) {
                    return makeList(popularSnapshot, "popular");
                  } else if (popularSnapshot.hasError) {
                    return const Center(
                      child: Text('Failed to load popular movies.'),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Now Playing",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: FutureBuilder(
                future: nowPlaying,
                builder: (context, nowPlayingSnapshot) {
                  if (nowPlayingSnapshot.hasData) {
                    return makeList(nowPlayingSnapshot, "now-playing");
                  } else if (nowPlayingSnapshot.hasError) {
                    return const Center(
                      child: Text('Failed to load now playing movies.'),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Upcoming",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: FutureBuilder(
                future: commingSoon,
                builder: (context, commingSoonSnapshot) {
                  if (commingSoonSnapshot.hasData) {
                    return makeList(commingSoonSnapshot, "coming-soon");
                  } else if (commingSoonSnapshot.hasError) {
                    return const Center(
                      child: Text('Failed to load coming soon movies.'),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView makeList(AsyncSnapshot<List<MovieModel>> snapshot, String type) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: snapshot.data!.length,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      itemBuilder: (context, index) {
        var webtoon = snapshot.data![index];
        return Movie(
          title: webtoon.title,
          posterPath: webtoon.posterPath,
          id: webtoon.id,
          type: type,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 10),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String title, posterPath;
  final int id;

  const DetailScreen({
    super.key,
    required this.title,
    required this.posterPath,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<MovieDetailModel> movie;

  @override
  void initState() {
    super.initState();
    movie = ApiService.getMovieById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            // "Back to list",
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: widget.id,
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        offset: const Offset(10, 10),
                        color: Colors.black.withOpacity(0.03),
                      )
                    ],
                  ),
                  child: Image.network(widget.posterPath),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          FutureBuilder(
            future: movie,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        snapshot.data!.overview,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Genres',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Wrap(
                        children: snapshot.data!.genres.map((genre) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(genre.name),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }
              return const Text("...");
            },
          )
        ],
      ),
    );
  }
}

class Genre {
  int id;
  String name;
  Genre({required this.id, required this.name});
}

class MovieModel {
  final String title, posterPath;
  final int id;
  MovieModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        posterPath = json['poster_path'];
}

class MovieDetailModel {
  final String title, posterPath, overview;
  final List<Genre> genres;
  final int id;
  MovieDetailModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        posterPath = json['poster_path'],
        genres = (json['genres'] as List)
            .map((genre) => Genre(id: genre['id'], name: genre['name']))
            .toList(),
        overview = json['overview'];
}

class ApiService {
  static const String baseUrl = 'https://movies-api.nomadcoders.workers.dev';

  static Future<List<MovieModel>> getMovies(String type) async {
    final response = await http.get(Uri.parse('$baseUrl/$type'));
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      Iterable list = result['results'];
      return list.map((movie) => MovieModel.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  static Future<MovieDetailModel> getMovieById(int id) async {
    final url = Uri.parse("$baseUrl/movie?id=$id");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final webtoon = jsonDecode(response.body);
      return MovieDetailModel.fromJson(webtoon);
    }
    throw Error();
  }
}

class Movie extends StatelessWidget {
  static const String imageUrl = 'https://image.tmdb.org/t/p/w500';

  final String title, posterPath;
  final String type;
  final int id;

  const Movie({
    super.key,
    required this.posterPath,
    required this.title,
    required this.type,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              posterPath: "$imageUrl/$posterPath",
              title: title,
              id: id,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Hero(
            tag: "$id/$type",
            child: Container(
              width: 100,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    offset: const Offset(10, 10),
                    color: Colors.black.withOpacity(0.3),
                  )
                ],
              ),
              child: Image.network(
                "$imageUrl/$posterPath",
                headers: const {
                  "User-Agent":
                      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
