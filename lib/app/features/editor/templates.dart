import 'dart:convert';

import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemplateListPage extends StatefulWidget {
  const TemplateListPage({super.key});

  @override
  _TemplateListPageState createState() => _TemplateListPageState();
}

class _TemplateListPageState extends State<TemplateListPage> {
  List<CardTemplate> templates = [];
  String selectedCategory = 'all';
  final List<String> categories = [
    'all',
    'general',
    'birthday',
    'wedding',
    'anniversary',
    'invitation',
  ];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? templatesJson = prefs.getString('templates');
    if (templatesJson != null) {
      setState(() {
        templates = (jsonDecode(templatesJson) as List)
            .map((e) => CardTemplate.fromJson(e))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTemplates = selectedCategory == 'all'
        ? templates
        : templates.where((t) => t == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditorPage()),
              );
            },
            tooltip: 'Create New Template',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.capitalize ?? category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: filteredTemplates.isEmpty
                ? const Center(
                    child: Text(
                      'No templates available. Create a new one!',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = filteredTemplates[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditorPage(),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: template.thumbnailPath != null
                                    ? Image.asset(
                                        template.thumbnailPath!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                  ),
                                                ),
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          size: 50,
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      template.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      template.category.capitalize ??
                                          template.category,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (template.isPremium)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Premium',
                                          style: TextStyle(
                                            color: Colors.amber[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (template.tags.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          template.tags.join(', '),
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'template_list_fab', // Unique heroTag
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditorPage()),
          );
        },
        backgroundColor: Colors.teal[600],
        tooltip: 'Create New Template',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
