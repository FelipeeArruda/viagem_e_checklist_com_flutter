import 'package:flutter/material.dart';

void main() {
  runApp(const FlutterTripsApp());
}

class ItemViagem {
  final String id;
  final String nome;
  final int quantidade;
  final String categoria;

  ItemViagem({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.categoria,
  });
}

class FlutterTripsApp extends StatelessWidget {
  const FlutterTripsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Trips',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaChecklist(),
        '/detalhes': (context) => const TelaDetalhesItem(),
        '/categorias': (context) => const TelaCategorias(),
      },
    );
  }
}

class TelaChecklist extends StatefulWidget {
  const TelaChecklist({super.key});

  @override
  State<TelaChecklist> createState() => _TelaChecklistState();
}

class _TelaChecklistState extends State<TelaChecklist> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _qtdController = TextEditingController();
  String _categoriaSelecionada = 'Extras';

  static List<ItemViagem> checklistViagem = [
    ItemViagem(
      id: '1',
      nome: 'Passaporte',
      quantidade: 1,
      categoria: 'Documentos',
    ),
  ];

  final List<Map<String, String>> destinos = [
    {"city": "Paris", "country": "França", "image": "assets/images/paris.png"},
    {"city": "Orlando", "country": "EUA", "image": "assets/images/orlando.jpg"},
    {
      "city": "Lisboa",
      "country": "Portugal",
      "image": "assets/images/lisboa.jpg",
    },
  ];

  final List<String> categoriasDisponiveis = [
    'Documentos',
    'Eletrônico',
    'Roupa',
    'Higiene',
    'Calçado',
    'Extras',
  ];

  @override
  void dispose() {
    _itemController.dispose();
    _qtdController.dispose();
    super.dispose();
  }

  void _adicionarItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        checklistViagem.add(
          ItemViagem(
            id: DateTime.now().toString(),
            nome: _itemController.text,
            quantidade: int.tryParse(_qtdController.text) ?? 1,
            categoria: _categoriaSelecionada,
          ),
        );
      });
      _itemController.clear();
      _qtdController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtro = ModalRoute.of(context)?.settings.arguments as String?;
    final listaExibida = filtro == null
        ? checklistViagem
        : checklistViagem.where((i) => i.categoria == filtro).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(filtro ?? "Checklist Geral"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () => Navigator.pushNamed(context, '/categorias'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (filtro == null) ...[
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: destinos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: TravelCard(
                      city: destinos[index]["city"]!,
                      country: destinos[index]["country"]!,
                      imagePath: destinos[index]["image"]!,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _itemController,
                            decoration: const InputDecoration(
                              labelText: 'Item',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty) ? '!' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _categoriaSelecionada,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: categoriasDisponiveis
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _categoriaSelecionada = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _qtdController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Qtd',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _adicionarItem,
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: listaExibida.length,
              itemBuilder: (context, index) {
                final item = listaExibida[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => setState(
                    () => checklistViagem.removeWhere((i) => i.id == item.id),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.luggage),
                    title: Text(item.nome),
                    subtitle: Text(
                      'Qtd: ${item.quantidade} - ${item.categoria}',
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/detalhes',
                      arguments: item,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TravelCard extends StatefulWidget {
  final String city;
  final String country;
  final String imagePath;
  const TravelCard({
    super.key,
    required this.city,
    required this.country,
    required this.imagePath,
  });
  @override
  State<TravelCard> createState() => _TravelCardState();
}

class _TravelCardState extends State<TravelCard> {
  bool isFavorito = false;
  bool jaVisitou = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(widget.imagePath, fit: BoxFit.cover),
                Positioned(
                  top: 5,
                  right: 5,
                  child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: Icon(
                        isFavorito ? Icons.favorite : Icons.favorite_border,
                        color: isFavorito ? Colors.red : Colors.white,
                      ),
                      onPressed: () => setState(() => isFavorito = !isFavorito),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.city}, ${widget.country}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text('Já visitei', style: TextStyle(fontSize: 12)),
                    const Spacer(),
                    Switch.adaptive(
                      value: jaVisitou,
                      onChanged: (bool val) => setState(() => jaVisitou = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TelaDetalhesItem extends StatelessWidget {
  const TelaDetalhesItem({super.key});
  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as ItemViagem;
    return Scaffold(
      appBar: AppBar(title: Text(item.nome)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              title: const Text('Categoria'),
              subtitle: Text(item.categoria),
            ),
            ListTile(
              title: const Text('Quantidade'),
              subtitle: Text('${item.quantidade}'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaCategorias extends StatelessWidget {
  const TelaCategorias({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categorias = [
      {'n': 'Documentos', 'c': Colors.blue, 'i': Icons.file_present},
      {'n': 'Eletrônico', 'c': Colors.orange, 'i': Icons.devices},
      {'n': 'Roupa', 'c': Colors.green, 'i': Icons.checkroom},
      {'n': 'Higiene', 'c': Colors.pink, 'i': Icons.dry_cleaning},
      {'n': 'Calçado', 'c': Colors.brown, 'i': Icons.nordic_walking},
      {'n': 'Extras', 'c': Colors.purple, 'i': Icons.more_horiz},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Selecione uma Categoria')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final cat = categorias[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, '/', arguments: cat['n']),
            child: Card(
              color: cat['c'].withOpacity(0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['i'], size: 40, color: cat['c']),
                  const SizedBox(height: 10),
                  Text(
                    cat['n'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cat['c'],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
