import 'package:flutter/material.dart';
import 'widget/form_field.dart';

class TollPlazaSearchField extends StatefulWidget {
  final List<Map<String, dynamic>> tollStations;
  final Function(String)? onSelected;

  const TollPlazaSearchField({
    super.key,
    required this.tollStations,
    this.onSelected,
  });

  @override
  State<TollPlazaSearchField> createState() => _TollPlazaSearchFieldState();
}

class _TollPlazaSearchFieldState extends State<TollPlazaSearchField> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _fromKey = GlobalKey();
  final GlobalKey _toKey = GlobalKey();

  OverlayEntry? _fromOverlayEntry;
  OverlayEntry? _toOverlayEntry;
  List<Map<String, dynamic>> _filteredFromStations = [];
  List<Map<String, dynamic>> _filteredToStations = [];
  bool _isUpdatingController = false; // Flag to prevent reopening overlay

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    _fromOverlayEntry?.remove();
    _toOverlayEntry?.remove();
    super.dispose();
  }

  void _updateSuggestions(String query, GlobalKey key, TextEditingController controller, bool isFromField) {
    if (_isUpdatingController) return; // Skip if updating controller

    if (query.isEmpty) {
      if (isFromField) {
        _hideOverlay(_fromOverlayEntry);
      } else {
        _hideOverlay(_toOverlayEntry);
      }
      return;
    }

    final filteredStations = widget.tollStations
        .where((plaza) {
          var cities = plaza['cities'];
          if (cities is String) {
            var cityList = cities.split(',');
            return cityList.any((city) => city.toLowerCase().contains(query.toLowerCase()));
          }
          return false;
        })
        .toList();

    if (isFromField) {
      _filteredFromStations = filteredStations;
      if (_filteredFromStations.isNotEmpty) {
        _showOverlay(key, controller, isFromField);
      } else {
        _hideOverlay(_fromOverlayEntry);
      }
    } else {
      _filteredToStations = filteredStations;
      if (_filteredToStations.isNotEmpty) {
        _showOverlay(key, controller, isFromField);
      } else {
        _hideOverlay(_toOverlayEntry);
      }
    }
  }

  void _showOverlay(GlobalKey key, TextEditingController controller, bool isFromField) {
    if (isFromField) {
      _fromOverlayEntry?.remove();
      _fromOverlayEntry = _createOverlayEntry(key, controller, isFromField);
      Overlay.of(context).insert(_fromOverlayEntry!);
    } else {
      _toOverlayEntry?.remove();
      _toOverlayEntry = _createOverlayEntry(key, controller, isFromField);
      Overlay.of(context).insert(_toOverlayEntry!);
    }
  }

  void _hideOverlay(OverlayEntry? overlayEntry) {
    overlayEntry?.remove();
    if (overlayEntry == _fromOverlayEntry) {
      _fromOverlayEntry = null;
    } else if (overlayEntry == _toOverlayEntry) {
      _toOverlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(GlobalKey key, TextEditingController controller, bool isFromField) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + renderBox.size.height,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (isFromField ? _filteredFromStations : _filteredToStations).map((e) => InkWell(
                  onTap: () {
                    _isUpdatingController = true; // Disable onChanged
                    _hideOverlay(isFromField ? _fromOverlayEntry : _toOverlayEntry); // Close overlay
                    controller.text = e['name']; // Update controller text
                    widget.onSelected?.call(e['name']); // Call callback
                    _isUpdatingController = false; // Re-enable onChanged
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(e['name']),
                  ),
                )).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateStations(String? value) {
    if (_fromController.text.isNotEmpty && _toController.text.isNotEmpty) {
      if (_fromController.text == _toController.text) {
        return 'Entry and Exit stations cannot be the same';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildStationField(
            key: _fromKey,
            controller: _fromController,
            focusNode: _fromFocusNode,
            validator: _validateStations,
            labelText: "Search Entry Station",
            hintText: "Islamabad interchange",
            icon: Icons.location_on,
            iconColor: Colors.green,
            onEditingComplete: () => _hideOverlay(_fromOverlayEntry),
            onChanged: (query) => _updateSuggestions(query, _fromKey, _fromController, true),
          ),
          const SizedBox(width: 10),
          buildStationField(
            key: _toKey,
            controller: _toController,
            focusNode: _toFocusNode,
            validator: _validateStations,
            labelText: "Search Exit Station",
            hintText: "Hyderabad",
            icon: Icons.location_on,
            iconColor: Colors.red,
            onEditingComplete: () => _hideOverlay(_toOverlayEntry),
            onChanged: (query) => _updateSuggestions(query, _toKey, _toController, false),
          ),
        ],
      ),
    );
  }
}