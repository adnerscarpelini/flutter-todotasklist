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

  //ADNER: Para saberr o item e a posição que foi removido na exclusão
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  //ADNER: Sobrescreve o método que sempre é executado ao abrir o aplicativo
  //E nele realiza a consulta do JSON com os dados salvos no arquivo JSON
  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

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
      _saveData();
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
                itemBuilder: _buildItem),
          )
        ],
      ),
    );
  }

  //ADNER: Função para construir os itens da lista
  Widget _buildItem(BuildContext context, int index) {
    //O Dismissible é o recurso que permite deslizar para a direita abrindo
    //o menu de exclusão
    return Dismissible(
      //A key é nessaria para dar um nome, porém ele exige que seja criado
      //um por execução, então pego o tempo atual em milisegundos
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          //Alinha o ícone 90% pra esquerda
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      //Direita para esquerda
      //O filho vai ser a lista (Icone de check e Texto da Tarefa)
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(
              //Se tiver "OK" coloca o icone marcado
              _toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          //ADNER: Evento ao marcar ou desmarcar o checkbox
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      //Ao deslizar efetue a exclusão do item
      onDismissed: (direction) {
        setState(() {
          //Pegar o item que está sendo removido e salvar para poder desfazer
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.remove(index);

          _saveData();

          //Mostrar o snackbar com sucesso e opção de desfazer
          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).showSnackBar(snack);
        });
      },
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
