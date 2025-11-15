import 'package:cardmaker/app/features/admin/project_management/controller.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectManagementPage extends GetView<ProjectManagementController> {
  const ProjectManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadProjects(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isAdmin.value) {
          return const Center(child: Text('Access Denied'));
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => controller.searchQuery.value = '',
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Projects list
            Expanded(
              child: controller.filteredTemplates.isEmpty
                  ? const Center(child: Text('No projects found'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.filteredTemplates.length,
                      itemBuilder: (context, index) {
                        final template = controller.filteredTemplates[index];
                        return _ProjectCard(
                          template: template,
                          onEdit: () => _showEditDialog(context, template),
                          onDelete: () => controller.deleteProject(template.id),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  void _showEditDialog(BuildContext context, CardTemplate template) {
    final nameController = TextEditingController(text: template.name);
    final categoryController = TextEditingController(text: template.category);
    final categoryIdController = TextEditingController(
      text: template.categoryId,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryIdController,
                decoration: const InputDecoration(
                  labelText: 'Category ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.updateProject(template.id, {
                'name': nameController.text.trim(),
                'category': categoryController.text.trim(),
                'categoryId': categoryIdController.text.trim(),
              });
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final CardTemplate template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.template,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: template.thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  template.thumbnailUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    );
                  },
                ),
              )
            : Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.image),
              ),
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${template.category}'),
            Text('ID: ${template.id}'),
            Text(
              'Created: ${_formatDate(template.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
