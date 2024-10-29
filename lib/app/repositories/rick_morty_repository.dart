import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rick_morty/app/errors/http_exception.dart';
import 'package:rick_morty/app/http_client/http_client.dart';
import 'package:rick_morty/app/model/character.dart';
import 'package:rick_morty/core/utils/urls.dart';

abstract interface class RickMortyRepository {
  Future<Either<HttpExceptions, List<Character>>> getCharacters({
    int page = 1,
  });
}

class IRickMortyRepository implements RickMortyRepository {
  IHttpClient client = IHttpClient();

  @override
  Future<Either<HttpExceptions, List<Character>>> getCharacters({
    int page = 1,
  }) async {
    final response = await client.get(
      url: '$baseUrl/character/?page=$page',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['results'];

      final List<Character> characters = data
          .map((dynamic character) =>
              Character.fromMap(character as Map<String, dynamic>))
          .toList();

      return Right(characters);
    } else {
      return Left(HttpExceptions('Status code: ${response.statusCode}'));
    }
  }
}
