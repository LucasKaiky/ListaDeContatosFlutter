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
  List<Contact> contacts = [];
  List<Contact> favorites = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  void fetchContacts() async {
    final contactIds = ['123456', '654321', '987654'];

    for (final id in contactIds) {
      try {
        final contact = await ViaCepService.fetchContactAddress(id);
        setState(() {
          contacts.add(contact);
        });
      } catch (e) {
        print('Falha: $e');
      }
    }

    sortContacts();
  }

  void addContact() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController cepController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Contato'),
          content: Scrollbar(
            thumbVisibility: true,
            thickness: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                    ),
                  ),
                  TextField(
                    controller: phoneController,
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
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    cepController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Campos obrigatórios'),
                        content: Text('Por favor, preencha todos os campos.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  final contact =
                      await ViaCepService.fetchContactAddress(cepController.text);
                  setState(() {
                    contacts.add(Contact(
                      name: nameController.text,
                      phone: phoneController.text,
                      email: emailController.text,
                      address: contact.address,
                      createdDate: DateTime.now(),
                    ));
                  });
                  sortContacts();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void editContact(Contact contact) async {
    final TextEditingController nameController =
        TextEditingController(text: contact.name);
    final TextEditingController phoneController =
        TextEditingController(text: contact.phone);
    final TextEditingController emailController =
        TextEditingController(text: contact.email);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Contato'),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                    ),
                  ),
                  TextField(
                    controller: phoneController,
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
              onPressed: () {
                setState(() {
                  contact.name = nameController.text;
                  contact.phone = phoneController.text;
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

  void deleteContact(Contact contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Contato'),
          content: Text('Deseja realmente excluir o contato?'),
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

  void toggleFavorite(Contact contact) {
    setState(() {
      if (favorites.contains(contact)) {
        favorites.remove(contact);
      } else {
        favorites.add(contact);
      }
    });
  }

  void sortContacts() {
    contacts.sort((a, b) => a.name.compareTo(b.name));
  }

  void navigateToProfile(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(contact: contact),
      ),
    );
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
                    title: Text(contact.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.address),
                        Text('Telefone: ${contact.phone}'),
                        Text('Email: ${contact.email}'),
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
                    title: Text(contact.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.address),
                        Text('Telefone: ${contact.phone}'),
                        Text('Email: ${contact.email}'),
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
                            Icons.favorite,
                            color: Colors.red,
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

class ProfileScreen extends StatelessWidget {
  final Contact contact;

  const ProfileScreen({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Endereço: ${contact.address}'),
            SizedBox(height: 16.0),
            Text('Telefone: ${contact.phone}'),
            SizedBox(height: 16.0),
            Text('Email: ${contact.email}'),
            SizedBox(height: 16.0),
            Text('Data de inclusão: ${contact.createdDate}'),
          ],
        ),
      ),
    );
  }
}