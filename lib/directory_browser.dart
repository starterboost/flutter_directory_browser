library directory_browser;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// A Directory Browser.
class DirectoryBrowser extends StatefulWidget {

  @override
  _DirectoryBrowserState createState() => _DirectoryBrowserState();
}

class _DirectoryBrowserState extends State<DirectoryBrowser> {
  Directory _rootDirectory;
  Directory _currentDirectory;
  List<DirectoryItem> _directoryItems = [];

  @override
  initState(){
    super.initState();

    initDirectory();
    _getDirectoryContents( '/' );
  }

  initDirectory() async {
    _rootDirectory = await getApplicationDocumentsDirectory();
    _getDirectoryContents( _rootDirectory.path );
  }

  _getDirectoryContents( String pathDirectory ) async {
    setState((){
      //set the current location
      _currentDirectory = Directory( pathDirectory );
      //empty the list
      _directoryItems = [];
      //list the items
      _currentDirectory.list(recursive:false,followLinks:false)
      .listen( (FileSystemEntity entity) async {
          FileStat stat = await entity.stat();
          setState((){
            _directoryItems.add( DirectoryItem(stat:stat,entity:entity) );
          });
      } );
    });


  }

  _openParentDirectory(){
    _getDirectoryContents( _currentDirectory.parent.path );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            alignment: Alignment.centerLeft,
            child: Text( path.relative( _currentDirectory.path, from: _rootDirectory.path )  )
          ),
          (_currentDirectory.path != _rootDirectory.path ? BasicButton('Back',icon:Icons.arrow_left,onPress:_openParentDirectory) : Container()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _directoryItems.map( ( DirectoryItem item ){
                    return BasicButton( path.basename( item.entity.path ), 
                      icon: getFileTypeIcon(item.stat.type), 
                      color: Colors.grey,
                      onPress: (){
                      _getDirectoryContents( item.entity.path );
                    } );
                  } ).toList()
                )
              )
            ]
          )
        ]
      )
    );
  }
}


//HELPERS
typedef Callback = void Function();

class BasicTitle extends StatelessWidget{
  final String label;
  
  BasicTitle(this.label,{Key key}): super(key:key);

  @override
  Widget build( BuildContext context ){
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Text(
        label,
        style: Theme.of( context ).textTheme.display1,
        textAlign: TextAlign.center,
      )
    );
  }
}

class BasicButton extends StatelessWidget{
  final Callback onPress;
  final String label;
  final IconData icon;
  final Color color;

  BasicButton(this.label,{Key key,this.onPress,this.icon,this.color = Colors.orange}): super(key:key);

  @override
  Widget build( BuildContext context ){
    return FlatButton(
      onPressed: onPress,
      color: color,
      padding: EdgeInsets.all(10.0),
      
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon( icon ),
          Text( label )
        ]
      )
    );
  }
}

class DirectoryItem{
  final FileStat stat;
  final FileSystemEntity entity;

  DirectoryItem({this.stat, this.entity}): super();
}

IconData getFileTypeIcon( FileSystemEntityType type ){
  switch( type ){
    case FileSystemEntityType.directory:
    return Icons.archive;
    break;
    case FileSystemEntityType.file:
    return Icons.attach_file;
    break;
    default:
    return null;
    break;
  }
}