import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  //ADNER: Retorna o arquivo para salvar os dados em json
  Future<File> _getFile() async {
    //O path_provider ajuda a pegar o caminho que o Android e iOS permitem salvar
    //arquivos, assim como ajuda nas permissões
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

//ADNER: Função para salvar os dados no arquivo json
  Future<File> _saveData() async {
    //Transformo a minha lista em um json
    String data = json.encode(_toDoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  //ADNER: Função para obter os dados do arquivo (consultar)
  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
