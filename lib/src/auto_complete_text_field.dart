// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';

import 'package:map_location_picker/src/osm_place.dart';
import 'package:map_location_picker/src/osm_service.dart';

class AutoCompleteTextField extends StatefulWidget {
  final Color? topCardColor;
  final bool showBackButton;
  final Widget? backButton;
  final double borderRadius;
  final ValueChanged<OSMPlace>? onSelected;
  const AutoCompleteTextField({
    Key? key,
    this.topCardColor,
    this.showBackButton = true,
    this.backButton,
    this.borderRadius = 12,
    this.onSelected,
  }) : super(key: key);

  @override
  State<AutoCompleteTextField> createState() => _AutoCompleteTextFieldState();
}

class _AutoCompleteTextFieldState extends State<AutoCompleteTextField> {
  final OSMService osmService = OSMService();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: Colors.white,
        child: ListTile(
          minVerticalPadding: 0,
          contentPadding: const EdgeInsets.only(right: 4, left: 4),
          leading: widget.showBackButton
              ? const BackButton(
                  color: Color(0xFF7D7D7D),
                )
              : widget.backButton,
          title: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: FormBuilderTypeAhead<OSMPlace>(
              controller: _controller,
              suggestionsCallback: (query) async {
                if (query.isNotEmpty) {
                  return await osmService.searchPlaces(query);
                } else {
                  return [];
                }
              },
              name: "Search",
              itemBuilder: (context, itemData) {
                return ListTile(
                  title: Text(
                    itemData.displayName,
                    maxLines: 1,
                  ),
                );
              },
              selectionToTextTransformer: (suggestion) {
                return suggestion.displayName;
              },
              onSuggestionSelected: widget.onSelected,
              hideOnEmpty: true,
              hideOnError: true,
              hideOnLoading: true,
              textFieldConfiguration: const TextFieldConfiguration(
                textInputAction: TextInputAction.search,
              ),
              hideSuggestionsOnKeyboardHide: false,
              decoration: InputDecoration(
                hintText: "Search Places Here",
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFDFDFDF),
                  ),
                  onPressed: () => _controller.clear(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
