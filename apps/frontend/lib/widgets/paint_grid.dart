import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:frontend/core/env.dart';
import 'package:types/types.dart' as types;
import 'package:web_socket_client/web_socket_client.dart';

class PlaceScreen extends StatefulWidget {
  final int gridSize;

  const PlaceScreen({super.key, required this.gridSize});

  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  Map<int, Color> gridData = {};
  double scale = 1.0;
  Offset panOffset = Offset.zero;
  Color selectedColor = Colors.red;
  late WebSocket socket;
  late StreamSubscription<ConnectionState> connectionSub;
  late StreamSubscription messagesSub;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    socket = WebSocket(Uri.parse(Env.wsBaseUrl));
    connectionSub = socket.connection.listen(
      (event) {
        isConnected = event is Connected;
      },
    );

    messagesSub = socket.messages.listen(
      (event) {
        if (event is! String) return;
        final json = jsonDecode(event) as Map<String, dynamic>;
        final typeString = json['type'] as String;
        final type =
            types.DataType.values.firstWhere((element) => element.name == typeString);

        switch (type) {
          case types.DataType.all:
            final data = types.AllResponse.fromJson(json);
            for (final List<types.Paint?> paint in data.data) {
              for (final types.Paint? p in paint) {
                if (p != null) {
                  final index = p.y * widget.gridSize + p.x;
                  updateCell(index, Color.fromARGB(255, p.r, p.g, p.b));
                }
              }
            }
            break;
          case types.DataType.update:
            final types.UpdateResponse(:data) = types.UpdateResponse.fromJson(json);
            final index = data.y * widget.gridSize + data.x;
            updateCell(index, Color.fromARGB(255, data.r, data.g, data.b));
        }
      },
    );
  }

  @override
  void dispose() {
    connectionSub.cancel();
    messagesSub.cancel();
    socket.close();
    super.dispose();
  }

  void updateCell(int index, Color color, {bool updateSocket = false}) {
    setState(() {
      gridData[index] = color;
    });

    if (updateSocket) {
      final change = types.ChangeRequest(
        x: index % widget.gridSize,
        y: index ~/ widget.gridSize,
        color: types.Color(
          r: color.red,
          g: color.green,
          b: color.blue,
        ),
      );
      socket.send(jsonEncode(change.toJson()));
    }
  }

  void onTapCell(int x, int y) {
    int index = y * widget.gridSize + x;
    updateCell(index, selectedColor, updateSocket: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('r/place Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () async {
              Color? color = await showDialog<Color>(
                context: context,
                builder: (_) => ColorPickerDialog(currentColor: selectedColor),
              );
              if (color != null) {
                setState(() {
                  selectedColor = color;
                });
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onScaleStart: (details) => panOffset -= details.focalPoint / scale,
        onScaleUpdate: (details) {
          setState(() {
            scale = (scale * details.scale).clamp(0.5, 3.0);
            panOffset += details.focalPoint / scale - panOffset;
          });
        },
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.5,
          maxScale: 3.0,
          constrained: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapUp: (details) {
                  // Translate global tap position into grid coordinates
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset localPosition =
                      box.globalToLocal(details.globalPosition);
                  double scaledCellSize = 20.0 * scale;

                  int x = ((localPosition.dx + panOffset.dx) / scaledCellSize)
                      .floor();
                  int y = ((localPosition.dy + panOffset.dy) / scaledCellSize)
                      .floor();

                  if (x >= 0 &&
                      x < widget.gridSize &&
                      y >= 0 &&
                      y < widget.gridSize) {
                    onTapCell(x, y);
                  }
                },
                child: CustomPaint(
                  size: Size(widget.gridSize * 20.0, widget.gridSize * 20.0),
                  painter: GridPainter(
                    gridSize: widget.gridSize,
                    gridData: gridData,
                    scale: scale,
                    panOffset: panOffset,
                    cellSize: 20.0,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int gridSize;
  final Map<int, Color> gridData;
  final double scale;
  final Offset panOffset;
  final double cellSize;

  GridPainter({
    required this.gridSize,
    required this.gridData,
    required this.scale,
    required this.panOffset,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scaledCellSize = cellSize * scale;

    // Calculate visible cells
    int startX = (panOffset.dx / scaledCellSize).floor().clamp(0, gridSize);
    int startY = (panOffset.dy / scaledCellSize).floor().clamp(0, gridSize);

    int endX = ((panOffset.dx + size.width / scale) / scaledCellSize)
        .ceil()
        .clamp(0, gridSize);
    int endY = ((panOffset.dy + size.height / scale) / scaledCellSize)
        .ceil()
        .clamp(0, gridSize);

    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    for (int y = startY; y < endY; y++) {
      for (int x = startX; x < endX; x++) {
        int index = y * gridSize + x;
        Rect rect = Rect.fromLTWH(
          x * scaledCellSize - panOffset.dx,
          y * scaledCellSize - panOffset.dy,
          scaledCellSize,
          scaledCellSize,
        );
        Paint cellPaint = Paint()..color = gridData[index] ?? Colors.white;

        canvas.drawRect(rect, cellPaint);
        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPickerDialog extends StatelessWidget {
  final Color currentColor;

  const ColorPickerDialog({super.key, required this.currentColor});

  @override
  Widget build(BuildContext context) {
    Color selectedColor = currentColor;

    return AlertDialog(
      title: const Text('Pick a Color'),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: currentColor,
          onColorChanged: (color) {
            selectedColor = color;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }
}
