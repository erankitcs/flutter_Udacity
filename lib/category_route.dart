import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'api.dart';
import 'backdrop.dart';
import 'package:category_route/Category.dart';
import 'category_tile.dart';
import 'package:category_route/Unit.dart';
import 'unit_converter.dart';


final _backgroundColor=Colors.green[100] ;




class CategoryRoute extends StatefulWidget {

  const CategoryRoute();

  @override
  _CategoryRouteState createState() => _CategoryRouteState();
}

class _CategoryRouteState extends State<CategoryRoute> {
  Category _defaultCategory;
  Category _currentCategory;
  final _categories = <Category>[];
/* Removing it to load from json file
  static const _categoryNames= <String>[
    'Length',
    'Area',
    'Volume',
    'Mass',
    'Time',
    'Digital Storage',
    'Energy',
    'Currency',
  ];
  */
  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xFF6AB7A8, {
      'highlight': Color(0xFF6AB7A8),
      'splash': Color(0xFF0ABC9B),
    }),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    ColorSwatch(0xFFFFB7DE, {
      'highlight': Color(0xFFFFB7DE),
      'splash': Color(0xFFF94CBF),
    }),
    ColorSwatch(0xFF8899A8, {
      'highlight': Color(0xFF8899A8),
      'splash': Color(0xFFA9CAE8),
    }),
    ColorSwatch(0xFFEAD37E, {
      'highlight': Color(0xFFEAD37E),
      'splash': Color(0xFFFFE070),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFFCE9A9A, {
      'highlight': Color(0xFFCE9A9A),
      'splash': Color(0xFFF94D56),
      'error': Color(0xFF912D2D),
    }),
  ];


  static const _icons = <String>[
    'assets/icons/length.png',
    'assets/icons/area.png',
    'assets/icons/volume.png',
    'assets/icons/mass.png',
    'assets/icons/time.png',
    'assets/icons/digital_storage.png',
    'assets/icons/power.png',
    'assets/icons/currency.png',
  ];

/* Removing InitState instead of this. We will use didChangeDependencies
  @override
  void initState() {
    super.initState();

    for (var i=0 ; i < _categoryNames.length ; i++){
      var category = Category(
        name: _categoryNames[i],
        color: _baseColors[i],
        iconLocation: Icons.cake,
        units: _retrieveUnitList(_categoryNames[i]),
      );
      if (i == 0) {
        _defaultCategory = category;
      }
      _categories.add(category);
    }

   }
*/

@override
Future<void> didChangeDependencies() async {
  super.didChangeDependencies();
  if(_categories.isEmpty){
    await _retrieveLocalCategories();
    await _retrieveApiCategory();
  }
}

@override
Future<void> _retrieveLocalCategories() async {
  final json=DefaultAssetBundle
      .of(context)
      .loadString('assets/data/regular_units.json');

  final data=JsonDecoder().convert(await json);
  if (data is! Map) {
    throw('Data retrieve from API is not Map');
  }
  var categoryIndex=0;
  data.keys.forEach((key){
    final List<Unit> units =data[key].map<Unit>((dynamic data)=> Unit.fromJson(data)).toList();
    var category=Category(
        name: key,
        color: _baseColors[categoryIndex],
        iconLocation: _icons[categoryIndex],
        units: units);
    setState(() {
      if(categoryIndex==0){
        _defaultCategory=category;
      }
      _categories.add(category);
    });
    categoryIndex += 1;
  });

}

Future<void>  _retrieveApiCategory() async {
  setState(() {
    _categories.add(
      Category(
          name: apiCategory['name'],
          color: _baseColors.last,
          iconLocation: _icons.last,
          units: [])
    );
  });

  final api=Api();

  final jsonUnits=await api.getUnits(apiCategory['route']) ;
  if (jsonUnits != null ){
    final units=<Unit>[] ;
    for ( var unit in jsonUnits){
      units.add(Unit.fromJson(unit));
    }

    setState(() {
      _categories.removeLast();
      _categories.add(
        Category(
            name: apiCategory['name'],
            color: _baseColors.last,
            iconLocation: _icons.last,
            units: units)
      );

    });
  }

}


  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
    });
  }


   Widget _buildCategoryWidgets ( Orientation orientationDevice) {

     if (orientationDevice == Orientation.portrait){
       return( ListView.builder(
         itemBuilder: (BuildContext context, int index ) {
           return CategoryTile(
             category: _categories[index],
             onTap: _categories[index].name==apiCategory['name'] && _categories[index].units.isEmpty
                 ? null : _onCategoryTap,
           );
         },
         itemCount: _categories.length,
       ) ) ;
     }
     else {
       return GridView.count(
         crossAxisCount: 2,
         childAspectRatio: 3.0,
         children: _categories.map((Category c){
           return CategoryTile(
             category: c,
             onTap:  _onCategoryTap,
           );
         }).toList(),
       );
     }


  }
/* Commented as  Now reading units from Json
  List<Unit> _retrieveUnitList( String categoryName) {

    return List.generate(10, (int i){
      i+=1;
      return Unit(
          name: '$categoryName Unit $i',
          conversion: i.toDouble()
      );
    });
  }
*/
  @override
  Widget build(BuildContext context) {

    if(_categories.isEmpty){
      return Center(
        child: Container(
          height: 180.0,
          width: 180.0,
          child: CircularProgressIndicator(),
        ),
      );
    }

    assert(debugCheckHasMediaQuery(context));

    final listView=Container(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 48.0,
      ),

      child: _buildCategoryWidgets(MediaQuery.of(context).orientation),


    );

    return Backdrop(
      currentCategory:
      _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? UnitConverter(category: _defaultCategory)
          : UnitConverter(category: _currentCategory),
      backPanel: listView,
      frontTitle: Text('Unit Converter'),
      backTitle: Text('Select a Category'),
    );
  }


}


/* Changing to Stateful Widget
class CategoryRoute extends StatelessWidget {

  const CategoryRoute();

  static const _categoryNames= <String>[
    'Length',
    'Area',
    'Volume',
    'Mass',
    'Time',
    'Digital Storage',
    'Energy',
    'Currency',
  ];
  static const _baseColors = <Color>[
    Colors.teal,
    Colors.orange,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.yellow,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.red,
  ];



  Widget _buildCategoryWidgets ( List<Widget> categories) {
       return ListView.builder(
           itemBuilder: (BuildContext context, int index ) => categories[index],
            itemCount: categories.length,
       ) ;

  }

  List<Unit> _retrieveUnitList( String categoryName) {

    return List.generate(10, (int i){
      i+=1;
      return Unit(
        name: '$categoryName Unit $i',
        conversion: i.toDouble()
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    final categories =<Category>[];

    for (var i=0 ; i < _categoryNames.length ; i++){
      categories.add(Category(name: _categoryNames[i],
          color: _baseColors[i],
          iconLocation: Icons.cake,
          units: _retrieveUnitList(_categoryNames[i])
      ),
      );
    }

    final listView=Container(
         color: _backgroundColor,
         padding: EdgeInsets.symmetric(horizontal: 8.0),

         child: _buildCategoryWidgets(categories),


    );

    final appBar=AppBar(
      elevation: 0.0,
      title: Text(
        'Unit Converter',
        style: TextStyle(
          color: Colors.black,
          fontSize: 30.0,
        ),
      ),
      centerTitle: true,
      backgroundColor: _backgroundColor,
    );

    return Scaffold(
      appBar: appBar,
      body: listView,
    );
  }


}
*/


