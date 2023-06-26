import 'package:flutter/material.dart';
import 'user.dart';
import 'viacep_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Contatos',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: ContactListScreen(),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<User> contacts = [];
  List<User> favorites = [];

  @override
  void initState() {
    super.initState();
    contacts = [];
  }

  void addContact() async {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController telefoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController cepController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Contato'),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                    ),
                  ),
                  TextField(
                    controller: telefoneController,
                    decoration: InputDecoration(
                      labelText: 'Telefone',
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  TextField(
                    controller: cepController,
                    decoration: InputDecoration(
                      labelText: 'CEP',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final address = await ViaCepService.getAddress(cepController.text);

                setState(() {
                  contacts.add(
                    User(
                      nome: nomeController.text,
                      telefone: telefoneController.text,
                      email: emailController.text,
                      createdDate: DateTime.now(),
                      endereco: [
                        address['logradouro'],
                        address['bairro'],
                        address['localidade'],
                        address['uf']
                      ],
                    ),
                  );
                });

                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void editContact(User contact) async {
    final TextEditingController nomeController = TextEditingController(text: contact.nome);
    final TextEditingController telefoneController = TextEditingController(text: contact.telefone);
    final TextEditingController emailController = TextEditingController(text: contact.email);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                ),
              ),
              TextField(
                controller: telefoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  contact.nome = nomeController.text;
                  contact.telefone = telefoneController.text;
                  contact.email = emailController.text;
                });

                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void deleteContact(User contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Contato'),
          content: Text('Deseja excluir o contato "${contact.nome}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  contacts.remove(contact);
                  favorites.remove(contact);
                });

                Navigator.of(context).pop();
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void toggleFavorite(User contact) {
    setState(() {
      if (favorites.contains(contact)) {
        favorites.remove(contact);
      } else {
        favorites.add(contact);
      }
    });
  }

  void navigateToProfile(User contact) async {
    final newAddresses = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(contact: contact),
      ),
    );

    if (newAddresses != null) {
      setState(() {
        contact.endereco.addAll(newAddresses);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Lista de Contatos',
            ),
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Todos'),
                Tab(text: 'Favoritos'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final isFavorite = favorites.contains(contact);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown,
                      child: Text(
                        contact.nome.substring(0, 1),
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    title: Text(contact.nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Telefone: ${contact.telefone}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => editContact(contact),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () => toggleFavorite(contact),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteContact(contact),
                        ),
                      ],
                    ),
                    onTap: () => navigateToProfile(contact),
                  );
                },
              ),
              ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final contact = favorites[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown,
                      child: Text(
                        contact.nome.substring(0, 1),
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    title: Text(contact.nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Telefone: ${contact.telefone}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => toggleFavorite(contact),
                    ),
                    onTap: () => navigateToProfile(contact),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: addContact,
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final User contact;

  ProfileScreen({required this.contact});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> addedAddresses = [];

  void addAddress(BuildContext context) async {
    final TextEditingController addressController = TextEditingController();
    final TextEditingController cepController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Endereço'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cepController,
                decoration: InputDecoration(
                  labelText: 'CEP',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final address = await ViaCepService.getAddress(cepController.text);

                  if (address != null) {
                    setState(() {
                      addedAddresses.add(address['logradouro']);
                      addedAddresses.add(address['bairro']);
                      addedAddresses.add(address['localidade']);
                      addedAddresses.add(address['uf']);
                    });
                  }

                  Navigator.of(context).pop();
                },
                child: Text('Adicionar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.nome),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nome: ${widget.contact.nome}'),
              Text('Telefone: ${widget.contact.telefone}'),
              Text('Email: ${widget.contact.email}'),
              Text('Data de inclusão: ${widget.contact.createdDate}'),
              SizedBox(height: 16.0),
              Text('Endereços:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.contact.endereco.map((address) {
                    return Text(address);
                  }),
                  ...addedAddresses.map((address) {
                    return Text(address);
                  }),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => addAddress(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 4.0),
                    Text('Adicionar Novo Endereço'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
