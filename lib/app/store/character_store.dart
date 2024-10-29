import 'package:flutter/material.dart';
import 'package:rick_morty/app/model/character.dart';
import 'package:rick_morty/app/repositories/rick_morty_repository.dart';

class CharacterStore extends ValueNotifier<CharacterState> {
  List<Character> originalCharacters = [];
  final searchEC = TextEditingController();
  final scroll = ScrollController();

  int page = 1;

  CharacterStore() : super(CharacterLoading());

  RickMortyRepository repository = IRickMortyRepository();

  void getCharacters() async {
    await repository.getCharacters(page: page).then((resposta) {
      resposta.fold(
        (left) => value = CharacterError(left.message),
        (rigth) {
          originalCharacters = rigth;
          value = CharacterLoaded(rigth);
        },
      );
    });
  }

  void loadingMoreCharacters() {
    if (value is CharacterLoaded) {
      var characters = (value as CharacterLoaded).characters;
      //var page = characters.length ~/ 20 + 1;
      //page = page++;

      print(page);

      repository.getCharacters(page: page).then((resposta) {
        resposta.fold(
          (left) => value = CharacterError(left.message),
          (rigth) {
            originalCharacters.addAll(rigth);
            value = CharacterLoaded(originalCharacters);
          },
        );
      });
    }
  }

  void searchCharacters(String name) {
    if (value is CharacterLoaded) {
      var filteredCharacters = originalCharacters
          .where((element) =>
              element.name.toLowerCase().contains(name.toLowerCase()))
          .toList();

      value = CharacterLoaded(filteredCharacters);
    }
  }
}

abstract class CharacterState {}

class CharacterLoading extends CharacterState {}

class CharacterLoaded extends CharacterState {
  final List<Character> characters;

  CharacterLoaded(this.characters);
}

class CharacterError extends CharacterState {
  final String message;

  CharacterError(this.message);
}
