import 'package:flutter/material.dart';

import 'components/body.dart';

class SearchResultScreen extends StatelessWidget {
  final String searchQuery;
  final String searchIn;
  final List<String> searchResultDoctorsId;

  const SearchResultScreen({
    Key key,
    @required this.searchQuery,
    @required this.searchResultDoctorsId,
    @required this.searchIn,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Body(
        searchQuery: searchQuery,
        searchResultDoctorsId: searchResultDoctorsId,
        searchIn: searchIn,
      ),
    );
  }
}
