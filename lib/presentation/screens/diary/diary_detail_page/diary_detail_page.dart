import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/diary/diary_model.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/diary/diary_detail_page/diary_search_bar.dart';
import 'package:intl/intl.dart';

class DiaryDetailPage extends StatefulWidget {
  final DiaryModel diary;
  const DiaryDetailPage({super.key, required this.diary});

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  String _searchQuery = "";
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Filtra as entradas baseado na busca (Título da sessão ou conteúdo)
  // Nota: Você também pode mover esta lógica para uma extension no DiaryModel como sugerido anteriormente
  List<DiaryEntry> get _filteredEntries {
    final entries = widget.diary.entries.where((entry) {
      final matchesText = entry.text.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesSession = entry.session?.toString() == _searchQuery;
      return matchesText || matchesSession;
    }).toList();

    return entries..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      // MUDANÇA AQUI: Controle do AppBar
      appBar: _isSearching
          ? DiarySearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              onClose: () => setState(() {
                _isSearching = false;
                _searchQuery = "";
                _searchController.clear();
              }),
            )
          : AppBar(
              backgroundColor: const Color(0xFF131313),
              elevation: 0,
              title: Text(
                widget.diary.title,
                style: const TextStyle(
                  fontFamily: 'Noto Serif',
                  color: Color(0xFFF1C97D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFFF1C97D)),
                  onPressed: () => setState(() => _isSearching = true),
                ),
              ],
              iconTheme: const IconThemeData(color: Color(0xFFF1C97D)),
            ),
      body: Stack(
        children: [
          // Linha da Timeline
          Positioned(
            left: 27,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF1C97D).withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          _filteredEntries.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhuma crônica encontrada",
                    style: TextStyle(color: Colors.white24),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 20,
                    bottom: 100,
                  ),
                  itemCount: _filteredEntries.length,
                  itemBuilder: (context, index) {
                    return _buildTimelineEntry(
                      _filteredEntries[index],
                      index == 0,
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFF1C97D),
        onPressed: () => _addEntry(),
        icon: const Icon(Icons.edit_note, color: Color(0xFF412D00)),
        label: const Text(
          "NOVA MEMÓRIA",
          style: TextStyle(
            color: Color(0xFF412D00),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Color(0xFFF1C97D)),
      decoration: const InputDecoration(
        hintText: "Buscar por texto ou sessão...",
        hintStyle: TextStyle(color: Colors.white24),
        border: InputBorder.none,
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildTimelineEntry(DiaryEntry entry, bool isLatest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bolinha da Timeline
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isLatest
                  ? const Color(0xFFF1C97D)
                  : const Color(0xFF2A2A2A),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF131313), width: 4),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1B1B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLatest
                      ? const Color(0xFFF1C97D).withOpacity(0.3)
                      : const Color(0xFF353534),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho com Sessão
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "SESSÃO ${entry.session ?? '—'} • ${DateFormat('dd MMM yyyy').format(entry.date)}"
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFD0C5AF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.auto_stories,
                          size: 14,
                          color: Color(0xFFF1C97D),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      entry.text,
                      style: const TextStyle(
                        color: Color(0xFFE5E2E1),
                        fontSize: 15,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addEntry() {
    final textController = TextEditingController();
    final sessionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1B1B),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Nova Crônica",
                    style: TextStyle(
                      color: Color(0xFFF1C97D),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: sessionController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Sessão #",
                      labelStyle: TextStyle(color: Colors.white24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Relate os fatos...",
                fillColor: const Color(0xFF131313),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1C97D),
                foregroundColor: const Color(0xFF412D00),
              ),
              onPressed: () {
                if (textController.text.isEmpty) return;
                setState(() {
                  widget.diary.entries.add(
                    DiaryEntry(
                      text: textController.text,
                      date: DateTime.now(),
                      session: int.tryParse(sessionController.text),
                    ),
                  );
                  widget.diary.save();
                });
                Navigator.pop(context);
              },
              child: const Text("REGISTRAR"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
