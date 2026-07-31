import 'package:budget_book_app/blocs/budgets/budget_bloc.dart';
import 'package:budget_book_app/blocs/budgets/budget_event.dart';
import 'package:budget_book_app/blocs/budgets/models/budget_item.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

/// ============================================================================
/// ➕ ADD ITEM DIALOG BOX
/// ----------------------------------------------------------------------------
/// This dialog is used for BOTH:
///   • Adding a new budget item
///   • Editing an existing one (via isEditing flag)
///
/// Features:
///  - Autocomplete for item name (based on Hive data)
///  - Auto-fill quantity & price when selecting an existing item
///  - Pre-fills fields when editing
///  - Returns a map of details back to the caller
///
/// NOTHING has been changed. Only comments added.
/// ============================================================================
class AddItemDialogBox extends StatefulWidget {
  final BudgetItem? existingItem; // ← ADD THIS
  final String? existingName;
  final String? existingQuantity;
  final String? existingPrice;
  final String? existingType;
  final bool isEditing;
  final bool isRenamingItem;
  final Function(BudgetItem)? onItemAdded;

  const AddItemDialogBox({
    super.key,
    this.existingItem, // ← ADD THIS
    this.existingName,
    this.existingQuantity,
    this.existingPrice,
    this.existingType,
    this.isEditing = false,
    this.isRenamingItem = false,
    this.onItemAdded,
  });

  @override
  State<AddItemDialogBox> createState() => _AddItemDialogBoxState();
}

class _AddItemDialogBoxState extends State<AddItemDialogBox> {
  /// Hive box reference for stored items
  final itemsBox = Hive.box<BudgetItem>('itemsBox');

  /// Text controllers for input fields
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController quantityCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();

  //For dropdown menu
  String ItemTypeLabel = "Other";

  final ItemType = [
    "Food",
    "Shopping",
    "Loans",
    "Lifestyle",
    "Utilities",
    "Other",
  ];

  /// ==========================================================================
  /// initState()
  /// --------------------------------------------------------------------------
  /// Preloads values based on whether user is editing or adding.
  /// When adding: default quantity = "1"
  /// ==========================================================================
  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      // Pre-fill values when editing item
      nameCtrl.text = widget.existingName ?? "";
      quantityCtrl.text = widget.existingQuantity ?? "";
      priceCtrl.text = widget.existingPrice ?? "";
      ItemTypeLabel = widget.existingType?.isNotEmpty == true
          ? widget.existingType!
          : "Other";
    } else {
      // Default quantity for new item
      quantityCtrl.text = "1"; // by default quantity text field has 1
    }
    if (widget.isRenamingItem) {
      nameCtrl.text = widget.existingName ?? "";
      ItemTypeLabel = widget.existingType?.isNotEmpty == true
          ? widget.existingType!
          : "Other";
    }
  }

  /// ==========================================================================
  /// dispose()
  /// --------------------------------------------------------------------------
  /// Controller cleanup
  /// ==========================================================================
  @override
  void dispose() {
    nameCtrl.dispose();
    quantityCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  /// ==========================================================================
  /// build()
  /// --------------------------------------------------------------------------
  /// Creates the dialog UI:
  ///   • Autocomplete field for item name
  ///   • Quantity + Price fields
  ///   • Cancel / Add or Save buttons
  /// ==========================================================================
  @override
  Widget build(BuildContext context) {
    final myThemeVar = Theme.of(context);

    /// Suggestions list (unique item names)
    final List<String> suggestions = itemsBox.values
        .map((e) => e.name)
        .toSet()
        .toList();

    return AlertDialog(
      // backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      backgroundColor: myThemeVar.cardColor,
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Title
            Text(
              widget.isEditing
                  ? 'Edit Item'
                  : widget.isRenamingItem
                  ? 'Rename Item'
                  : 'Add Item',
              style: TextStyle(
                color: myThemeVar.colorScheme.primary,
                // fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: GoogleFonts.manrope().fontFamily,
              ),
            ),

            Row(
              children: [
                // ==================================================================
                // ITEM NAME FIELD — USING AUTOCOMPLETE
                // ==================================================================
                Expanded(
                  child: Autocomplete<String>(
                    // optionsBuilder: (TextEditingValue value) {
                    //   // No input? No suggestions.
                    //   if (value.text.isEmpty) return const Iterable<String>.empty();

                    //   // Case-insensitive matching
                    //   return suggestions.where(
                    //     (name) =>
                    //         name.toLowerCase().contains(value.text.toLowerCase()),
                    //   );
                    // },
                    optionsBuilder: (TextEditingValue value) {
                      if (value.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }

                      final query = value.text.toLowerCase();

                      final startsWithMatches = suggestions.where(
                        (name) => name.toLowerCase().startsWith(query),
                      );

                      final containsMatches = suggestions.where(
                        (name) =>
                            !name.toLowerCase().startsWith(query) &&
                            name.toLowerCase().contains(query),
                      );

                      return [...startsWithMatches, ...containsMatches];
                    },

                    onSelected: (selection) {
                      nameCtrl.text = selection;

                      BudgetItem? existingItem;

                      final items = itemsBox.values.toList();

                      // Iterate BACKWARDS to get latest entry
                      for (int i = items.length - 1; i >= 0; i--) {
                        if (items[i].name.toLowerCase() ==
                            selection.toLowerCase()) {
                          existingItem = items[i];
                          break;
                        }
                      }

                      if (existingItem != null && !widget.isEditing) {
                        priceCtrl.text = existingItem.price.toString();
                        quantityCtrl.text = existingItem.quantity.toString();
                        setState(() {
                          ItemTypeLabel = existingItem!.category ?? "Other";
                        });
                      }
                    },

                    // onSelected: (selection) {
                    //   // Set selected name
                    //   nameCtrl.text = selection;

                    //   /// Try to auto-fill based on previously saved item
                    //   BudgetItem? existing;

                    //   try {
                    //     // existing = itemsBox.values.firstWhere(
                    //     //   (item) => item.name == selection,
                    //     // );
                    //     final items = itemsBox.values.toList();

                    //     for (int i = items.length - 1; i >= 0; i--) {
                    //       if (items[i].name == selection) {
                    //         existing = items[i];
                    //         break;
                    //       }
                    //     }
                    //   } catch (e) {
                    //     existing = null;
                    //   }

                    //   if (existing != null) {
                    //     priceCtrl.text = existing.price.toString();
                    //     quantityCtrl.text = existing.quantity.toString();
                    //   }

                    //   // Additional loop-based match (kept exactly as written)
                    //   BudgetItem? matchedItem;

                    //   for (var item in itemsBox.values) {
                    //     if (item.name.toLowerCase() == selection.toLowerCase()) {
                    //       matchedItem = item;
                    //       break;
                    //     }
                    //   }

                    //   if (matchedItem != null) {
                    //     priceCtrl.text = matchedItem.price.toString();
                    //     quantityCtrl.text = matchedItem.quantity.toString();
                    //   }
                    // },

                    // ==================================================================
                    // FIELD VIEW BUILDER — Custom handling of TextField
                    // ==================================================================
                    fieldViewBuilder:
                        (
                          context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          // Sync internal Autocomplete controller ONCE
                          if (textEditingController.text.isEmpty) {
                            textEditingController.text = nameCtrl.text;
                          }

                          return TextField(
                            controller:
                                nameCtrl, // YOUR BASE CONTROLLER (respected)
                            focusNode: focusNode,
                            textCapitalization: TextCapitalization.sentences,

                            style: myThemeVar.textTheme.bodyMedium,
                            decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: myThemeVar.textTheme.bodySmall,
                            ),

                            // Sync internal Autocomplete controller on every change
                            onChanged: (value) {
                              textEditingController.value = TextEditingValue(
                                text: value,
                                selection: TextSelection.collapsed(
                                  offset: value.length,
                                ),
                              );
                            },
                          );
                        },

                    // ==================================================================
                    // OPTIONS LIST (Dropdown suggestions UI)
                    // ==================================================================
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          color: myThemeVar.cardColor,
                          elevation: 6,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            constraints: BoxConstraints(maxHeight: 180),

                            child: ListView.builder(
                              itemCount: options.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);

                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Text(
                                      option,
                                      style: myThemeVar.textTheme.bodyMedium,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                //Expense Type
                DropdownButton2<String>(
                  alignment: Alignment.center,
                  value: ItemTypeLabel,

                  selectedItemBuilder: (context) {
                    return ItemType.map((item) {
                      return SizedBox(
                        //width: 120, //  MUST match button width
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // const SizedBox(width: 1),
                            const Icon(Icons.arrow_drop_down, size: 20),
                          ],
                        ),
                      );
                    }).toList();
                  },

                  items: ItemType.map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  ).toList(),

                  iconStyleData: const IconStyleData(
                    // iconSize: 42,
                    // iconEnabledColor: Colors.transparent,
                    // icon: Icon(Icons.keyboard_arrow_down_rounded),
                    icon: SizedBox.shrink(), // 👈 removes arrow + spacing
                  ),
                  // onChanged: (value) {
                  //   setState(() => ItemTypeLabel = value!);
                  // },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        ItemTypeLabel = value;
                      });
                    }
                  },

                  // BUTTON STYLE
                  buttonStyleData: ButtonStyleData(
                    elevation: 1,
                    height: 20,
                    //width: 120,
                    // width: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      // color: myThemeVar.cardColor,
                      color: Colors.transparent,
                      // borderRadius: BorderRadius.only(
                      //   bottomLeft: Radius.circular(5),
                      // ),

                      // border: Border.all(
                      //   color: myThemeVar.dividerColor,
                      //   width: 1,
                      // ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            12,
                            51,
                            51,
                            51,
                          ), // ✅ REAL control
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(9, 4),
                        ),
                      ],
                    ),
                  ),

                  // DROPDOWN MENU STYLE (THIS IS WHAT YOU WANT)
                  dropdownStyleData: DropdownStyleData(
                    padding: EdgeInsets.only(left: 0, right: 0),
                    elevation: 6,

                    decoration: BoxDecoration(
                      color: myThemeVar.cardColor,
                      // color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                      ),
                      // border: Border.all(
                      //   color: myThemeVar.dividerColor,
                      //   width: 1,
                      // ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            33,
                            0,
                            0,
                            0,
                          ), // ✅ REAL control
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  underline: const SizedBox(), // remove underline
                ),
              ],
            ),

            SizedBox(height: 20),

            // =================================================================
            // QUANTITY + PRICE FIELDS
            // =================================================================
            if (!widget.isRenamingItem)
              Row(
                children: [
                  /// QUANTITY FIELD
                  Expanded(
                    child: TextField(
                      controller: quantityCtrl,
                      onTap: () {
                        // Auto-select full text for quick editing
                        quantityCtrl.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: quantityCtrl.text.length,
                        );
                      },
                      style: myThemeVar.textTheme.bodyMedium,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "quantity",
                        labelStyle: myThemeVar.textTheme.bodySmall,
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  /// PRICE FIELD
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      onTap: () {
                        // Auto-select full text
                        priceCtrl.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: priceCtrl.text.length,
                        );
                      },
                      style: myThemeVar.textTheme.bodyMedium,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Price",
                        labelStyle: myThemeVar.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),

            if (widget.isEditing || !widget.isRenamingItem)
              SizedBox(height: 20),
            // SizedBox(height: 20),

            // ==================================================================
            // ACTION BUTTONS — CANCEL & ADD/SAVE
            // ==================================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// CANCEL BUTTON
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: myThemeVar.colorScheme.primary),
                  ),
                ),

                /// ADD / SAVE BUTTON
                MaterialButton(
                  onPressed: () async {
                    // ============================================================
                    // RENAME ALL ITEMS WITH SAME NAME
                    // ============================================================
                    if (widget.isRenamingItem) {
                      final oldName =
                          widget.existingName?.trim().toLowerCase() ?? "";
                      final newName = nameCtrl.text.trim();

                      if (newName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Name cannot be empty",
                              style: TextStyle(
                                color: myThemeVar.colorScheme.onPrimary,
                              ),
                            ),
                            backgroundColor: myThemeVar.colorScheme.primary,
                          ),
                        );
                        return;
                      }

                      // for (final item in itemsBox.values) {
                      //   if (item.name.toLowerCase() == oldName) {
                      //     item.name = newName;
                      //     item.category = ItemTypeLabel ?? "Other";
                      //     await item.save();
                      //   }
                      // }

                      context.read<BudgetBloc>().add(
                        RenameBudgetItems(
                          oldName: oldName,
                          newName: newName,
                          category: ItemTypeLabel,
                        ),
                      );

                      Navigator.pop(context);
                      return;
                    }

                    // ============================================================
                    // VALIDATION
                    // ============================================================
                    if (nameCtrl.text.trim().isEmpty ||
                        quantityCtrl.text.trim().isEmpty ||
                        priceCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Please fill all fields",
                            style: TextStyle(
                              color: myThemeVar.colorScheme.onPrimary,
                            ),
                          ),
                          backgroundColor: myThemeVar.colorScheme.primary,
                        ),
                      );

                      return;
                    }

                    // ============================================================
                    // GENERATE ID
                    // ============================================================
                    final id = widget.isEditing && widget.existingItem != null
                        ? widget.existingItem!.id
                        : DateTime.now().millisecondsSinceEpoch.toString();

                    final item = BudgetItem(
                      id: id,
                      name: nameCtrl.text.trim(),
                      quantity: int.parse(quantityCtrl.text.trim()),
                      price: int.parse(priceCtrl.text.trim()),
                      dateTime: widget.isEditing && widget.existingItem != null
                          ? widget.existingItem!.dateTime
                          : DateTime.now(),
                      imagePath: "",
                      category: ItemTypeLabel,
                    );

                    // ============================================================
                    // EDIT EXISTING ITEM
                    // ============================================================
                    if (widget.isEditing) {
                      Navigator.pop(context, item);
                    }
                    // ============================================================
                    // ADD NEW ITEM
                    // ============================================================
                    else {
                      widget.onItemAdded?.call(item);

                      nameCtrl.clear();
                      quantityCtrl.text = "1";
                      priceCtrl.clear();

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }
                  },

                  child: Text(
                    widget.isEditing
                        ? 'Save'
                        : widget.isRenamingItem
                        ? 'Rename'
                        : 'Add',
                    style: TextStyle(color: myThemeVar.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
