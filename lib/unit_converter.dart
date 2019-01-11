import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'api.dart';
import 'package:category_route/Category.dart';
import 'package:category_route/Unit.dart';

const _padding = EdgeInsets.all(16.0) ;

class UnitConverter extends StatefulWidget {

 final Category category;

  const UnitConverter({
   @required this.category,
  })
      : assert(category != null)
       ;

  @override
  _UnitConverterState createState() => _UnitConverterState();

}

class _UnitConverterState extends State<UnitConverter> {

  Unit _fromValue;
  Unit _toValue ;

  double _inputValue ;
  String _convertedValue ='';
  List<DropdownMenuItem> _unitMenuItems ;
  bool _showValidaterError =false ;
  final _inputkey=GlobalKey(
    debugLabel: 'inputText'
  );    /// to pass this into input text field to persist input value// //
  bool _showErrorUI = false;

  @override
  void initState() {
    super.initState();
    _createDropdownMenuItems();
    _setDefaults();
  }

  @override
  void didUpdateWidget(UnitConverter old) {
    super.didUpdateWidget(old);
    // We update our [DropdownMenuItem] units when we switch [Categories].
    if (old.category != widget.category) {
      _createDropdownMenuItems();
      _setDefaults();
    }
  }

  /// creating fresh dropdown
  void _createDropdownMenuItems() {

    var newItems=<DropdownMenuItem>[];
    for (var unit in widget.category.units) {
      newItems.add(DropdownMenuItem(
          value: unit.name,
          child: Container(
            child: Text(
              unit.name,
              softWrap: true,
            ),
          ),
      )) ;
    }
    setState(() {
      _unitMenuItems = newItems;
    });
    }


    void _setDefaults(){
    setState(() {
      _fromValue =widget.category.units[0];
      _toValue=widget.category.units[1] ;
    });

    }


    /// Input format to number
    String _format(double conversion) {
     var outputNum=conversion.toStringAsPrecision(7);
     if (outputNum.contains('.') && outputNum.endsWith('0') ){
       var i= outputNum.length -1 ;
       while(outputNum[i]=='0') {
         i -=1;
       }
       outputNum=outputNum.substring(0,i+1);
     }
     if ( outputNum.endsWith('.')) {
       return outputNum.substring(0,outputNum.length -1);
     }
     return outputNum ;
    }

    Future<void> _updateConversion() async {

      ///API call for Currency
      if (widget.category.name == apiCategory['name']) {
        final api = Api();
        final conversion = await api.convert(
            apiCategory['route'],
            _inputValue.toString(),
            _fromValue.name,
            _toValue.name);
        if (conversion == null) {
          setState(() {
            _showErrorUI = true;
          });
        }
        else {
          setState(() {
            _convertedValue = _format(conversion);
          });
        }
      }
      else {
        setState(() {
          _convertedValue = _format(
              _inputValue * (_toValue.conversion / _fromValue.conversion));
        });
      }
    }
    void _updateInputValue(String input){
    setState(() {
      if ( input == null || input.isEmpty){
        _convertedValue='';
      }
      else {
        try {
          final inputDouble = double.parse(input);
          _showValidaterError = false;
          _inputValue = inputDouble;
          _updateConversion();
        } on Exception catch(e){
          print('Error : $e');
          _showValidaterError=true;
        }
      }
    });
    }

    Unit _getUnit(String unitname) {
    return widget.category.units.firstWhere(
        (Unit unit) {
          return unit.name==unitname;
        },
      orElse: null,
    );
    }


    void _updateFromConversion(dynamic unitname){
     setState(() {
       _fromValue=_getUnit(unitname);

     });
     if ( _inputValue !=null ) {
       _updateConversion();
     }
    }

  void _updateToConversion(dynamic unitname){
    setState(() {
      _toValue=_getUnit(unitname);

    });
    if ( _inputValue !=null ) {
      _updateConversion();
    }
  }


    Widget _createDropdown( String currentValue , ValueChanged<dynamic> onChanged) {

    return Container(
      margin: EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(
          color: Colors.grey[400],
          width: 1.0,
        )
      ),
       padding: EdgeInsets.symmetric(vertical: 8.0),
       child: Theme(
           data: Theme.of(context).copyWith(
             canvasColor: Colors.grey[50],
           )
           ,
           child: DropdownButtonHideUnderline(
               child: ButtonTheme(
                 alignedDropdown: true,
                 child: DropdownButton(
                     value: currentValue,
                     items: _unitMenuItems,
                     onChanged: onChanged,
                     style: Theme.of(context).textTheme.title,
                 ),
               ),
           ),
       ),

    );
    }
  @override
  Widget build(BuildContext context) {

    if (widget.category.units == null ||(
    widget.category.name==apiCategory['name'] && _showErrorUI) ) {
      return SingleChildScrollView(
        child: Container(
          margin: _padding,
          padding: _padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: widget.category.color['error'],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 180.0,
                color: Colors.white,
              ),
              Text(
                'Oh no! We cant connect right now !',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline.copyWith(
                  color: Colors.white ,
                ),
              )
            ],
          ),
        ),
      );
    }

    final input=Padding(

      padding: _padding,
      child: Column(
        crossAxisAlignment : CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            key: _inputkey,
            style: Theme.of(context).textTheme.display1,
            decoration: InputDecoration(
              labelStyle: Theme.of(context).textTheme.display1,
              labelText: 'Input',
              errorText: _showValidaterError ? 'Invalid Number entered !!!' : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0)
              )
            ),
            keyboardType: TextInputType.number,
            onChanged: _updateInputValue,

          )
          ,
          _createDropdown(_fromValue.name,_updateFromConversion) ,
        ],
      ),
    );

    final arrows= RotatedBox(quarterTurns: 1 ,
      child:Icon(
        Icons.compare_arrows,
        size: 40.0,)
      ,
    );

    final output=Padding(
        padding: _padding ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            InputDecorator(
              child: Text(
                _convertedValue,
                style: Theme.of(context).textTheme.display1,
              ),
              decoration: InputDecoration(
                labelText: 'Output',
                labelStyle: Theme.of(context).textTheme.display1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
            ),
          _createDropdown(_toValue.name,_updateToConversion),
          ],
         ),
    );

    final converter=
   /// SingleChildScrollView(
    ///  child:
    ListView(
     /// crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        input,
        arrows,
        output,
      ],
    );
 ///   ) ;
    return Padding(
      padding: _padding,
      child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation){
            if (orientation ==Orientation.portrait) {
              return converter;
            } else {
              return Center(
                child: Container(
                  width: 450.0,
                  child: converter,
                ),
              );
            }

    }),
    );

  }

   /* Removing static widgets and creating a dropdown
   final unitWidget = widget.units.map((Unit unit){
      return Container(
        color: widget.color,
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(unit.name,
              style: Theme.of(context).textTheme.headline,
            ),
            Text(
            'Conversion : ${unit.conversion}',
              style: Theme.of(context).textTheme.subhead,
            )
          ],
        ),
      );
    }).toList() ;

    return ListView(
      children: unitWidget,
    ) ;
  }*/


}