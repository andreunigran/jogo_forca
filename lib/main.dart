import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ForcaApp());
}

class ForcaApp extends StatelessWidget {
  const ForcaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo de Forca',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ForcaGame(),
    );
  }
}

class ForcaGame extends StatefulWidget {
  const ForcaGame({Key? key}) : super(key: key);

  @override
  _ForcaGameState createState() => _ForcaGameState();
}

class _ForcaGameState extends State<ForcaGame> {
  // Lista de palavras e dicas para o jogo
  final List<Map<String, String>> palavrasEDicas = [
    {"palavra": "FLUTTER", "dica": "Framework de UI da Google"},
    {"palavra": "DART", "dica": "Linguagem de programação do Flutter"},
    {"palavra": "WIDGET", "dica": "Elemento básico da interface do Flutter"},
    {
      "palavra": "ANDROID",
      "dica": "Sistema operacional para dispositivos móveis"
    },
    {"palavra": "LINUX", "dica": "Sistema operacional de código aberto"}
  ];
  late String palavraSecreta;
  late String dicaPalavra;
  List<String> letrasCorretas = [];
  List<String> letrasErradas = [];
  int tentativas = 0;
  final int maxErros = 6;
  bool jogoFinalizado = false;

  @override
  void initState() {
    super.initState();
    _sortearPalavra(); // Inicia o jogo com uma palavra e dica aleatória
  }

  // Função para sortear uma nova palavra e dica
  void _sortearPalavra() {
    final random = Random();
    final sorteio = palavrasEDicas[random.nextInt(palavrasEDicas.length)];
    palavraSecreta = sorteio["palavra"]!;
    dicaPalavra = sorteio["dica"]!;
    letrasCorretas.clear();
    letrasErradas.clear();
    tentativas = 0;
    jogoFinalizado = false;
  }

  // Função para adivinhar uma letra
  void _adivinharLetra(String letra) {
    if (jogoFinalizado) return;

    setState(() {
      if (palavraSecreta.contains(letra)) {
        letrasCorretas.add(letra);
      } else {
        letrasErradas.add(letra);
        if (tentativas < maxErros) {
          tentativas++;
        }
      }

      // Verifica se o jogador venceu ou perdeu
      if (tentativas >= maxErros || _todasLetrasCorretas()) {
        jogoFinalizado = true;
      }
    });
  }

  // Função para reiniciar o jogo
  void _reiniciarJogo() {
    setState(() {
      _sortearPalavra();
    });
  }

  // Verifica se o jogador acertou todas as letras
  bool _todasLetrasCorretas() {
    return palavraSecreta
        .split('')
        .every((letra) => letrasCorretas.contains(letra));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo de Forca'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Título do jogo
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Adivinhe a palavra!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Exibição da dica
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Dica: $dicaPalavra',
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          // Boneco da forca com partes do corpo animadas
          Stack(
            alignment: Alignment.center,
            children: [
              _buildPart(tentativas > 0, Icons.circle, 50, Colors.red,
                  dx: 0, dy: -40), // Cabeça
              _buildPart(tentativas > 1, Icons.remove, 80, Colors.blue,
                  dx: 0, dy: 10), // Tronco
              _buildPart(tentativas > 2, Icons.remove, 40, Colors.blue,
                  dx: -40, dy: 10, rotation: -0.5), // Braço esquerdo
              _buildPart(tentativas > 3, Icons.remove, 40, Colors.blue,
                  dx: 40, dy: 10, rotation: 0.5), // Braço direito
              _buildPart(tentativas > 4, Icons.remove, 50, Colors.green,
                  dx: -20, dy: 80, rotation: 0.3), // Perna esquerda
              _buildPart(tentativas > 5, Icons.remove, 50, Colors.green,
                  dx: 20, dy: 80, rotation: -0.3), // Perna direita
            ],
          ),
          const SizedBox(height: 20),
          // Exibição das letras da palavra secreta
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: palavraSecreta.split('').map((letra) {
              return AnimatedOpacity(
                opacity: letrasCorretas.contains(letra) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  letra,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Botões das letras
          Wrap(
            spacing: 10,
            children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letra) {
              return ElevatedButton(
                onPressed: letrasCorretas.contains(letra) ||
                        letrasErradas.contains(letra) ||
                        jogoFinalizado
                    ? null
                    : () => _adivinharLetra(letra),
                child: Text(letra),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Erros: $tentativas / $maxErros',
            style: const TextStyle(fontSize: 18),
          ),
          // Mensagens de vitória ou derrota e botão de reinício
          if (jogoFinalizado)
            Column(
              children: [
                Text(
                  _todasLetrasCorretas()
                      ? 'Parabéns! Você venceu!'
                      : 'Você perdeu! A palavra era "$palavraSecreta".',
                  style: TextStyle(
                      fontSize: 24,
                      color:
                          _todasLetrasCorretas() ? Colors.green : Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _reiniciarJogo,
                  child: const Text('Tente Novamente'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Função auxiliar para construir uma parte do corpo animada
  Widget _buildPart(bool visible, IconData icon, double size, Color color,
      {double dx = 0, double dy = 0, double rotation = 0.0}) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Transform.rotate(
          angle: rotation,
          child: Icon(
            icon,
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }
}
