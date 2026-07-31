import 'package:budget_book_app/UI/screens/itemDataScreen.dart';
import 'package:budget_book_app/blocs/budgets/budget_bloc.dart';
import 'package:budget_book_app/blocs/budgets/models/budget_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Customsearchdelegate extends SearchDelegate {
  final List<dynamic> displayList;

  Customsearchdelegate({required this.displayList});

  List<BudgetItem> get _itemsOnly {
    return displayList.whereType<BudgetItem>().toList();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);

    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: GoogleFonts.manrope(
          color: theme.colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  // @override
  // TextStyle? get searchFieldStyle => TextStyle(
  //             color: myThemeVar.colorScheme.primary,
  //             fontSize: 14,
  //             fontWeight: FontWeight.w700,
  //             fontFamily: GoogleFonts.manrope().fontFamily,
  //           ),

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _itemsOnly.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase().trim());
    }).toList();

    final unique = {
      for (var item in results) item.name.toLowerCase(): item,
    }.values.toList();

    return _buildList(unique, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = _itemsOnly.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase().trim());
    }).toList();

    final unique = {
      for (var item in suggestions) item.name.toLowerCase(): item,
    }.values.toList();

    return _buildList(unique, context);
  }

  Widget _buildList(List<BudgetItem> items, BuildContext context) {
    final myThemeVar = Theme.of(context);
    if (items.isEmpty) {
      return Center(child: Text("No Result Found"));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return ListTile(
          title: Text(
            item.name,
            style: TextStyle(
              color: myThemeVar.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: GoogleFonts.manrope().fontFamily,
            ),
          ),
          // subtitle: Text(item.price.toString()),
          onTap: () {
            close(context, null);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Itemdatascreen(
                  containerHeight: MediaQuery.of(context).size.height,
                  containerWidth: MediaQuery.of(context).size.width,
                  itemName: item.name,
                  itemType: item.category ?? "Other",
                ),
              ),
            );
          },
        );
      },
    );
  }
}
