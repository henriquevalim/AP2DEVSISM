import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rick_morty/app/store/character_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CharacterStore store = CharacterStore();

  @override
  void initState() {
    store.getCharacters();
    store.scroll.addListener(() {
      if (store.scroll.position.pixels == store.scroll.position.maxScrollExtent) {
        store.page = store.page + 1;
        store.loadingMoreCharacters();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    store.dispose();
    store.scroll.dispose();
  }

  void _showCharacterStatus(BuildContext context, String characterName, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(characterName),
          content: Text('Status: $status'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text(
          'Rick &\nMorty',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.star_rounded, color: Colors.blueAccent, size: 60),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(20),
            TextFormField(
              controller: store.searchEC,
              onChanged: (value) {
                store.searchCharacters(value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey.shade700,
                filled: true,
              ),
            ),
            const Gap(20),
            const Text(
              'Personagens',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: store,
                builder: (context, value, child) {
                  if (value is CharacterError) {
                    return Center(
                      child: Text(
                          'Erro ao carregar personagens: ${value.message}'),
                    );
                  }
                  if (value is CharacterLoaded) {
                    if (value.characters.isEmpty) {
                      return const Center(
                        child: Text('Nenhum personagem encontrado'),
                      );
                    }
                    return GridView.builder(
                      controller: store.scroll,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Exibe 3 personagens por linha
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7, // Ajuste de altura/largura para melhor aparência
                      ),
                      itemCount: value.characters.length,
                      itemBuilder: (context, index) {
                        final character = value.characters[index];
                        return GestureDetector(
                          onTap: () => _showCharacterStatus(context, character.name, character.status),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      character.image,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        character.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        character.species,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
