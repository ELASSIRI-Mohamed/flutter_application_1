enum PlayerType { human, ai }

class Player {
  final String symbol;
  final PlayerType type;
  final String name;
  
  Player({required this.symbol, required this.type, required this.name});
  
  Player copyWith({
    String? symbol,
    PlayerType? type,
    String? name,
  }) {
    return Player(
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }
}