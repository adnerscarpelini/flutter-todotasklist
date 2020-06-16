import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
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
  final _toDoController = TextEditingController();

  List _toDoList = [];

  //ADNER: FUNÇÃO PARA ADICIONAR O TEXTO DO CAMPO NA LISTA
  void _addToDo() {
    //O setState atualiza o estado da tela (refresh)
    setState(() {
      //Map é o tipo de registros JSON no Dart
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;

      _toDoList.add(newToDo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  //ADNER: Pra poder ter um tamanho no botão
                  child: TextField(
                    //Controlador para pegar o texto digiitado
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo, //Chama a função no clique
                )
              ],
            ),
          ),
          Expanded(
            //ADNER: O Builder faz contruir a lista somente quando rola a tela
            //Ou seja, se tiver 1000 itens, ele vai construindo a lista durante a
            //rolagem, economizando recursos do aparelho
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                //Passo quantos itens vai ter a lista
                itemCount: _toDoList.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_toDoList[index]["title"]),
                    value: _toDoList[index]["ok"],
                    secondary: CircleAvatar(
                      child: Icon(
                          //Se tiver "OK" coloca o icone marcado
                          _toDoList[index]["ok"] ? Icons.check : Icons.error),
                    ),
                    onChanged: (c) {
                      setState(() {
                        _toDoList[index]["ok"] = c;
                      });
                    },
                  );
                }),
          )
        ],
      ),
    );
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
